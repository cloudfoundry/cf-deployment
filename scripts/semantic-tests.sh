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
      missing_releases=$(yq r $manifest_file -j | jq -r .releases[].url | grep 'github.com')

      local non_recently_added_releases=""
      for r in $missing_releases; do
        git show | grep "+  url: $r" > /dev/null
        local is_recently_added=$?
        if [[ $is_recently_added -ne 0 ]]; then
          non_recently_added_releases="$non_recently_added_releases $r"
        fi
      done
    set -e

    if [ -z "$non_recently_added_releases" ]; then
       pass "use-compiled-releases.yml"
    else
      fail "use-compiled-releases.yml: expected not to find the following releases urls on bosh.io or github.com: $non_recently_added_releases"
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
    -o operations/use-bosh-dns.yml > $manifest_file

  set +e
    local bosh_dns_aliases=$(yq r $manifest_file -j | jq .addons[2].jobs[].properties.aliases)
    local windows2012_bosh_dns_aliases=$(yq r $manifest_file -j | jq .addons[3].jobs[].properties.aliases)
    local windows2016_bosh_dns_aliases=$(yq r $manifest_file -j | jq .addons[4].jobs[].properties.aliases)
  set -e

  if [[ "$bosh_dns_aliases" != "$windows2012_bosh_dns_aliases" ]]; then
    fail "use-bosh-dns.yml: bosh-dns aliases have diverged"
    diff <(echo $bosh_dns_aliases | jq .) <(echo $windows2012_bosh_dns_aliases | jq .)
  elif [[ "$bosh_dns_aliases" != "$windows2016_bosh_dns_aliases" ]]; then
    fail "use-bosh-dns.yml: bosh-dns aliases have diverged"
    diff <(echo $bosh_dns_aliases | jq .) <(echo $windows2016_bosh_dns_aliases | jq .)
  else
    pass "use-bosh-dns.yml is consistent"
  fi
}

test_bosh_dns_aliases_consistent_between_files() {
  local manifest_file=$(mktemp)
  local manifest_file_renamed=$(mktemp)

  bosh int cf-deployment.yml \
    -o operations/use-bosh-dns.yml > $manifest_file

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
    pass "experimental/use-bosh-dns-with-renamed-network-and-deployment is consistent with use-bosh-dns.yml"
  fi
}

test_use_trusted_ca_cert_for_apps_includes_diego_instance_ca() {
  local trusted_app_cas=$(bosh int cf-deployment.yml -o operations/use-trusted-ca-cert-for-apps.yml --path /instance_groups/name=diego-cell/jobs/name=cflinuxfs2-rootfs-setup/properties/cflinuxfs2-rootfs/trusted_certs)

  if [[ $trusted_app_cas != $'((application_ca.certificate))\n((trusted_cert_for_apps.ca))' ]]; then
    fail "experimental/use-trusted-ca-cert-for-apps.yml [ $trusted_app_cas ] doesn't include diego_instance_identity_ca from cf-deployment.yml"
  else
    pass "experimental/use-trusted-ca-cert-for-apps.yml"
  fi
}

test_add_persistent_isolation_segment_diego_cell() {
  local diego_cell_rep_properties=$(bosh int cf-deployment.yml --path /instance_groups/name=diego-cell/jobs/name=rep/properties)
  local iso_seg_diego_cell_rep_properties=$(bosh int cf-deployment.yml -o operations/test/add-persistent-isolation-segment-diego-cell.yml \
    --path /instance_groups/name=isolated-diego-cell/jobs/name=rep/properties | grep -v placement_tags | grep -v persistent_isolation_segment)

  set +e
    diff <(echo "$diego_cell_rep_properties") <(echo "$iso_seg_diego_cell_rep_properties")
    local rep_diff_exit_code=$?
  set -e

  if [[ $rep_diff_exit_code != 0 ]]; then
    fail "rep properties on diego-cell have diverged between cf-deployment.yml and test/add-persistent-isolation-segment-diego-cell.yml"
  else
    pass "test/add-persistent-isolation-segment-diego-cell.yml is consistent with cf-deployment.yml"
  fi
}

test_use_log_cache() {
  local log_cache_release_version
  log_cache_release_version=$(bosh int cf-deployment.yml -o operations/experimental/use-log-cache.yml \
    --path /releases/name=log-cache/version)
  local reverse_log_proxy_link
  reverse_log_proxy_link=$(bosh int cf-deployment.yml -o operations/experimental/use-log-cache.yml \
    --path /instance_groups/name=doppler/jobs/name=log-cache-nozzle/consumes/reverse_log_proxy/deployment?)

  if [ ${log_cache_release_version} = "latest" ]; then
    fail "experimental/use-log-cache.yml: log-cache release should have specific version, not 'latest'"
  elif [ ${reverse_log_proxy_link} != "null" ]; then
    fail "experimental/use-log-cache.yml: expected to not find cross-deployment links"
  else
    pass "experimental/use-log-cache.yml"
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
    test_use_trusted_ca_cert_for_apps_includes_diego_instance_ca
    test_add_persistent_isolation_segment_diego_cell
    test_use_log_cache
  popd > /dev/null
  exit $exit_code
}
