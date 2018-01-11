#!/bin/bash

semantic_tests() {
  # Padded for pretty output
  suite_name="SEMANTIC    "

  pushd ${home} > /dev/null
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
  popd > /dev/null
  exit $exit_code
}

