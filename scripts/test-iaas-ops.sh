#!/bin/bash

test_iaas_ops() {
  # Padded for pretty output
  suite_name="IaaS      "

  pushd ${home} > /dev/null
    pushd iaas-support/softlayer > /dev/null
      check_interpolation "name: add-system-domain-dns-alias.yml" "${home}/operations/experimental/use-bosh-dns.yml -v system_domain=my.domain"
    popd > /dev/null
  popd > /dev/null
  exit $exit_code
}
