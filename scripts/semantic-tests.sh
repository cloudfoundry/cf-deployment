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
      fail "expected to find the same network name for all instance groups"
    elif [ $interpolated_network_names != $new_network ]; then
      fail "expected network name to be changed to ${new_network}"
    else
      pass "rename-network.yml"
    fi
}

test_scale_to_one_az() {
    local manifest_file=$(mktemp)

    bosh int cf-deployment.yml \
      -o operations/scale-to-one-az.yml > $manifest_file

    local interpolated_instance_counts=$(yq r $manifest_file -j | jq -r .instance_groups[].instances | uniq)
    local interpolated_azs=$(yq r $manifest_file -j | jq -r .instance_groups[].azs[] | uniq)

    if [ "$interpolated_instance_counts" != "1" ]; then
      fail "expected all instance counts to be 1"
    elif [ "$interpolated_azs" != "z1" ]; then
      fail "expected to find a single AZ for all instance groups"
    else
      pass "scale-to-one-az.yml"
    fi
}

semantic_tests() {
  # Padded for pretty output
  suite_name="SEMANTIC    "

  pushd ${home} > /dev/null
    test_rename_network_opsfile
    test_scale_to_one_az
  popd > /dev/null
  exit $exit_code
}

