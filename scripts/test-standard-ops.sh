#!/bin/bash

test_standard_ops() {
  # Padded for pretty output
  suite_name="STANDARD          "

  pushd ${home} > /dev/null
    pushd operations > /dev/null
      if interpolate ""; then
        pass "cf-deployment.yml"
      else
        fail "cf-deployment.yml"
      fi
      check_interpolation "aws.yml"
      check_interpolation "azure.yml"
      check_interpolation "bosh-lite.yml"
      check_interpolation "cf-syslog-skip-cert-verify.yml"
      check_interpolation "configure-confab-timeout.yml" "-v confab_timeout=60"
      check_interpolation "configure-default-router-group.yml" "-v default_router_group_reservable_ports=1234-2024"
      check_interpolation "disable-router-tls-termination.yml"
      check_interpolation "disable-log-cache.yml"
      check_interpolation "enable-cc-rate-limiting.yml" "-v cc_rate_limiter_general_limit=blah" "-v cc_rate_limiter_unauthenticated_limit=something"
      check_interpolation "enable-privileged-container-support.yml"
      check_interpolation "name: enable-nfs-ldap.yml" "enable-nfs-volume-service.yml -o enable-nfs-ldap.yml -l example-vars-files/vars-enable-nfs-ldap.yml"
      check_interpolation "enable-nfs-volume-service.yml"
      check_interpolation "enable-uniq-consul-node-name.yml"
      check_interpolation "enable-service-discovery.yml"
      check_interpolation "openstack.yml"
      check_interpolation "override-app-domains.yml" "-l example-vars-files/vars-override-app-domains.yml"
      check_interpolation "rename-network-and-deployment.yml" "-v deployment_name=renamed_deployment -v network_name=renamed_network"
      check_interpolation "scale-database-cluster.yml"
      check_interpolation "scale-to-one-az.yml"
      check_interpolation "set-bbs-active-key.yml" "-v diego_bbs_active_key_label=my_key_name"
      check_interpolation "set-router-static-ips.yml" "-v router_static_ips=[10.0.16.4,10.0.47.5]"
      check_interpolation "stop-skipping-tls-validation.yml"
      check_interpolation "name: use-azure-storage-blobstore.yml" "use-external-blobstore.yml -o use-azure-storage-blobstore.yml -l example-vars-files/vars-use-azure-storage-blobstore.yml"
      check_interpolation "use-blobstore-cdn.yml" "-l example-vars-files/vars-use-blobstore-cdn.yml"
      check_interpolation "use-compiled-releases.yml"
      check_interpolation "use-external-blobstore.yml" "-l example-vars-files/vars-use-external-blobstore.yml"
      check_interpolation "use-external-dbs.yml" "-l example-vars-files/vars-use-external-dbs.yml"
      check_interpolation "use-haproxy.yml" "-v haproxy_private_ip=10.0.10.10"
      check_interpolation "name: use-haproxy-public-network.yml" "use-haproxy.yml" "-o use-haproxy-public-network.yml -v haproxy_public_network_name=public -v haproxy_public_ip=6.7.8.9"
      version=$(bosh interpolate ${home}/cf-deployment.yml -o use-latest-stemcell.yml --path=/stemcells/alias=default/version)
      if [ "${version}" == "latest" ]; then
        pass "use-latest-stemcell.yml"
      else
        fail "use-latest-stemcell.yml, expected 'latest' but got '${version}'"
      fi
      version=$(bosh interpolate ${home}/cf-deployment.yml -o windows-cell.yml -o use-latest-windows-stemcell.yml --path=/stemcells/alias=windows2012R2/version)
      if [ "${version}" == "latest" ]; then
        pass "use-latest-windows-stemcell.yml"
      else
        fail "use-latest-windows-stemcell.yml, expected 'latest' but got '${version}'"
      fi
      check_interpolation "use-postgres.yml"
      check_interpolation "name: use-alicloud-oss-blobstore.yml" "use-external-blobstore.yml -o use-alicloud-oss-blobstore.yml -l example-vars-files/vars-use-alicloud-oss-blobstore.yml"
      check_interpolation "name: use-s3-blobstore.yml" "use-external-blobstore.yml -o use-s3-blobstore.yml -l example-vars-files/vars-use-s3-blobstore.yml"
      check_interpolation "name: use-gcs-blobstore-access-key.yml" "use-external-blobstore.yml -o use-gcs-blobstore-access-key.yml
      -v blobstore_access_key_id=TEST_ACCESS_KEY -v blobstore_secret_access_key=TEST_SECRET_ACCESS_KEY -l example-vars-files/vars-use-gcs-blobstore-access-key.yml"
      check_interpolation "name: use-gcs-blobstore-service-account.yml" "use-external-blobstore.yml -o use-gcs-blobstore-service-account.yml -l example-vars-files/vars-use-gcs-blobstore-service-account.yml"
      check_interpolation "name: use-swift-blobstore.yml" "use-external-blobstore.yml -o use-swift-blobstore.yml -l example-vars-files/vars-use-swift-blobstore.yml"
      check_interpolation "use-trusted-ca-cert-for-apps.yml" "-l example-vars-files/vars-use-trusted-ca-cert-for-apps.yml"
      check_interpolation "windows-cell.yml"
      version=$(bosh interpolate ${home}/cf-deployment.yml -o windows2016-cell.yml -o use-latest-windows2016-stemcell.yml --path=/stemcells/alias=windows2016/version)
      if [ "${version}" == "latest" ]; then
        pass "use-latest-windows2016-stemcell.yml"
      else
        fail "use-latest-windows2016-stemcell.yml, expected 'latest' but got '${version}'"
      fi
      check_interpolation "name: use-offline-windows2016fs.yml" "windows2016-cell.yml" "-o use-offline-windows2016fs.yml"
      check_interpolation "windows2016-cell.yml"
      check_interpolation "name: windows-cell.yml windows2016-cell.yml" "windows-cell.yml" "-o windows2016-cell.yml"
      # These files should exist for "backwards compatibility" but should always fail to interpolate (with a special error message)
      pass "use-bosh-dns.yml"
      pass "use-bosh-dns-for-containers.yml"
      pass "use-bosh-dns-for-windows2016-containers.yml"
      pass "use-bosh-dns-rename-network-and-deployment.yml"
      check_interpolation "use-log-cache.yml"
    popd > /dev/null # operations
  popd > /dev/null
  exit $exit_code
}

