#!/bin/bash

test_rename_network_opsfile() {
    local new_network="test_network"
    local manifest_file=$(mktemp)

    bosh int cf-deployment.yml \
      -o operations/rename-network.yml \
      -v network_name=$new_network > $manifest_file

    local interpolated_network_names=$(yq r $manifest_file -j | jq -r .instance_groups[].networks[].name | uniq)
    local num_uniq_networks=$(echo "$interpolated_network_names" | wc -l)

    if [ $num_uniq_networks != "1" ]; then
      fail "rename-network.yml: expected to find the same network name for all instance groups"
    elif [ $interpolated_network_names != $new_network ]; then
      fail "rename-network.yml: expected network name to be changed to ${new_network}"
    else
      pass "rename-network.yml"
    fi
}

test_aws_opsfile() {
    local aws_doppler_port="4443"
    local manifest_file=$(mktemp)

    bosh int cf-deployment.yml \
      -o operations/aws.yml > $manifest_file

    local interpolated_doppler_ports=$( yq r $manifest_file -j | jq -r '.instance_groups[].jobs[].properties.doppler.port|numbers')
    for i in $interpolated_doppler_ports; do
      if [ $i != $aws_doppler_port ]; then
        fail "Not all doppler ports are $aws_doppler_port"
      fi
    done
    pass "aws.yml"
}

test_scale_to_one_az() {
    local manifest_file=$(mktemp)

    bosh int cf-deployment.yml \
      -o operations/scale-to-one-az.yml > $manifest_file

    local interpolated_instance_counts=$(yq r $manifest_file -j | jq -r .instance_groups[].instances | uniq)
    local interpolated_azs=$(yq r $manifest_file -j | jq -r .instance_groups[].azs[] | uniq)

    if [ "$interpolated_instance_counts" != "1" ]; then
      fail "scale-to-one-az.yml: expected all instance counts to be 1"
    elif [ "$interpolated_azs" != "z1" ]; then
      fail "scale-to-one-az.yml: expected to find a single AZ for all instance groups"
    else
      pass "scale-to-one-az.yml"
    fi
}

test_use_compiled_releases() {
    local manifest_file=$(mktemp)

    bosh int cf-deployment.yml \
      -o operations/use-compiled-releases.yml > $manifest_file

    set +e
      yq r $manifest_file -j | jq -r .releases[].url | grep 'github.com'
      local non_compiled_interpolated_releases_on_github=$?
    set -e

    if [[ $non_compiled_interpolated_releases_on_github -eq 0 ]]; then
      fail "use-compiled-releases.yml: expected to find no release urls from bosh.io or github.com"
    else
      pass "use-compiled-releases.yml"
    fi
}

test_disable_consul() {
    local manifest_file=$(mktemp)

    bosh int cf-deployment.yml \
      -o operations/experimental/disable-consul.yml > $manifest_file

    set +e
      yq r $manifest_file -j | jq -r .instance_groups[].jobs[].name | grep 'consul_agent' > /dev/null
      local has_consul_agent=$?
    set -e

    if [[ $has_consul_agent -eq 0 ]]; then
      fail "experimental/disable-consul.yml: expected to find no 'consul_agent' jobs"
    else
      pass "experimental/disable-consul.yml"
    fi
}

test_bosh_dns_aliases_consistent() {
  local manifest_file=$(mktemp)

  bosh int cf-deployment.yml \
    -o operations/experimental/use-bosh-dns.yml > $manifest_file

  set +e
    local bosh_dns_aliases=$(yq r $manifest_file -j | jq .addons[1].jobs[].properties.aliases)
    local windows2012_bosh_dns_aliases=$(yq r $manifest_file -j | jq .addons[2].jobs[].properties.aliases)
    local windows2016_bosh_dns_aliases=$(yq r $manifest_file -j | jq .addons[3].jobs[].properties.aliases)
  set -e

  if [[ "$bosh_dns_aliases" != "$windows2012_bosh_dns_aliases" ]]; then
    fail "experimental/use-bosh-dns.yml: bosh-dns aliases have diverged"
    diff <(echo $bosh_dns_aliases | jq .) <(echo $windows2012_bosh_dns_aliases | jq .)
  elif [[ "$bosh_dns_aliases" != "$windows2016_bosh_dns_aliases" ]]; then
    fail "experimental/use-bosh-dns.yml: bosh-dns aliases have diverged"
    diff <(echo $bosh_dns_aliases | jq .) <(echo $windows2016_bosh_dns_aliases | jq .)
  else
    pass "experimental/use-bosh-dns.yml is consistent"
  fi
}

test_bosh_dns_aliases_consistent_between_files() {
  local manifest_file=$(mktemp)
  local manifest_file_renamed=$(mktemp)

  bosh int cf-deployment.yml \
    -o operations/experimental/use-bosh-dns.yml > $manifest_file

  bosh int cf-deployment.yml \
    -o operations/experimental/use-bosh-dns-rename-network-and-deployment.yml \
    -v deployment_name=cf \
    -v network_name=default > $manifest_file_renamed

  set +e
    diff $manifest_file $manifest_file_renamed
    local diff_exit_code=$?
  set -e

  if [[ $diff_exit_code != 0 ]]; then
    fail "bosh-dns aliases have diverged between use-bosh-dns.yml and use-bosh-dns-with-renamed-network-and-deployment.yml"
  else
    pass "experimental/use-bosh-dns-with-renamed-network-and-deployment is consistent with experimental/use-bosh-dns.yml"
  fi
}

semantic_tests() {
  # padded for pretty output
  suite_name="semantic    "

  pushd ${home} > /dev/null
    test_rename_network_opsfile
    test_aws_opsfile
    test_scale_to_one_az
    test_use_compiled_releases
    test_disable_consul
    test_bosh_dns_aliases_consistent
    test_bosh_dns_aliases_consistent_between_files
  popd > /dev/null
  exit $exit_code
}
