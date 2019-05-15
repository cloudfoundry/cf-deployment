#!/bin/bash

test_rename_network_and_deployment_opsfile() {
    local new_network="test_network"
    local new_deployment="test_deployment"
    local manifest_file=$(mktemp)

    bosh int cf-deployment.yml \
      -o operations/rename-network-and-deployment.yml \
      -v network_name=$new_network \
      -v deployment_name=$new_deployment > $manifest_file

    local interpolated_network_names=$(yq r $manifest_file -j | jq -r .instance_groups[].networks[].name | uniq)
    local num_uniq_networks=$(echo "$interpolated_network_names" | wc -l)

    if [ $num_uniq_networks != "1" ]; then
      fail "rename-network-and-deployment.yml: expected to find the same network name for all instance groups"
    elif [ $interpolated_network_names != $new_network ]; then
      fail "rename-network-and-deployment.yml: expected network name to be changed to ${new_network}"
    else
      pass "rename-network-and-deployment.yml"
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
    missing_releases=$(yq r $manifest_file -j | jq -r .releases[].url | grep -E '(github\.com|bosh\.io)')

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
      fail "use-compiled-releases.yml: the following releases were not compiled releases and use a github.com or bosh.io url: $non_recently_added_releases."
    fi
}

test_use_trusted_ca_cert_for_apps_doesnt_overwrite_existing_trusted_cas() {
  local existing_trusted_cas
  existing_trusted_app_cas=$(bosh int cf-deployment.yml --path /instance_groups/name=diego-cell/jobs/name=cflinuxfs3-rootfs-setup/properties/cflinuxfs3-rootfs/trusted_certs)

  local new_trusted_app_cas
  new_trusted_app_cas=$(bosh int cf-deployment.yml -o operations/use-trusted-ca-cert-for-apps.yml --path /instance_groups/name=diego-cell/jobs/name=cflinuxfs3-rootfs-setup/properties/cflinuxfs3-rootfs/trusted_certs)

  if [[ $existing_trusted_app_cas$'\n- ((trusted_cert_for_apps.ca))' != $new_trusted_app_cas ]]; then
    fail "use-trusted-ca-cert-for-apps.yml overwrites existing trusted CAs from cf-deployment.yml.\nTrusted CAs before applying the ops file:\n\n$existing_trusted_app_cas\n\nTrusted CAs after applying the ops file:\n\n$new_trusted_app_cas"
  else
    pass "use-trusted-ca-cert-for-apps.yml"
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

test_all_cas_references_from_cert_variables() {
  local invalid_ca_references
  local exit_code

  set +e
    invalid_ca_references=$(grep -E '\(\(.*ca\.certificate\)\)' cf-deployment.yml | grep -v diego_instance_identity_ca)
    exit_code=$?
  set -e

  if [[ $exit_code == 0 ]]; then
    fail "CAs should be referenced from their certificate variables: $invalid_ca_references"
  else
    pass "All CAs are referenced from certificate variables in cf-deployment.yml"
  fi
}

test_ops_files_dont_have_double_question_marks() {
  local invalid_question_marks
  local exit_code

  set +e
    invalid_question_marks=$(grep -rE '.*\?.*\?.*' operations)
    exit_code=$?
  set -e

  if [[ $exit_code == 0 ]]; then
    fail "Ops files should not contain double '?' in paths: $invalid_question_marks"
  else
    pass "Ops files don't have double '?' in paths"
  fi
}

semantic_tests() {
  # padded for pretty output
  suite_name="semantic    "

  pushd ${home} > /dev/null
    test_rename_network_and_deployment_opsfile
    test_aws_opsfile
    test_scale_to_one_az
    test_use_compiled_releases
    test_use_trusted_ca_cert_for_apps_doesnt_overwrite_existing_trusted_cas
    test_add_persistent_isolation_segment_diego_cell
    test_all_cas_references_from_cert_variables
    test_ops_files_dont_have_double_question_marks
  popd > /dev/null
}
