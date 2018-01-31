#!/bin/bash

test_legacy_ops() {
  # Padded for pretty output
  suite_name="LEGACY      "

  pushd ${home} > /dev/null
    pushd operations/legacy > /dev/null
      check_interpolation "name: keep-haproxy-ssl-pem.yml" "${home}/operations/use-haproxy.yml -o keep-haproxy-ssl-pem.yml -v haproxy_ssl_pem=i-am-a-pem -v haproxy_private_ip=1.2.3.4"
      check_interpolation "old-droplet-mitigation.yml"
      check_interpolation "keep-original-blobstore-directory-keys.yml" "-l example-vars-files/vars-keep-original-blobstore-directory-keys.yml"
      check_interpolation "name: keep-original-postgres-configuration.yml" "${home}/operations/use-postgres.yml -o keep-original-postgres-configuration.yml -l example-vars-files/vars-keep-original-postgres-configuration.yml"
      check_interpolation "name: keep-original-routing-postgres-configuration.yml" "${home}/operations/use-postgres.yml -o keep-original-routing-postgres-configuration.yml -v routing_api_database_name=routing-api-db -v routing_api_database_username=routing-api-user"
      check_interpolation "keep-original-internal-usernames.yml" "-l example-vars-files/vars-keep-original-internal-usernames.yml"
      check_interpolation "keep-static-ips.yml" "-l example-vars-files/vars-keep-static-ips.yml"
    popd > /dev/null # operations/legacy
  popd > /dev/null
  exit $exit_code
}
