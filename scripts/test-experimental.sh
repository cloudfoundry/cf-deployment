#!/bin/bash

test_experimental_ops() {
  # Padded for pretty output
  suite_name="EXPERIMENTAL      "

  pushd ${home} > /dev/null
    pushd operations/experimental > /dev/null
      check_interpolation "add-credhub-lb.yml"
      check_interpolation "add-cflinuxfs3.yml"

      check_interpolation "bits-service.yml"
      check_interpolation "name: bits-service-local.yml" "bits-service.yml" "-o bits-service-local.yml"
      check_interpolation "name: bits-service-s3.yml" "${home}/operations/use-external-blobstore.yml" "-o ${home}/operations/use-s3-blobstore.yml" "-o bits-service.yml" "-o bits-service-s3.yml" "-l ${home}/operations/example-vars-files/vars-use-s3-blobstore.yml"
      check_interpolation "name: bits-service-webdav.yml" "bits-service.yml" "-o bits-service-webdav.yml"

      check_interpolation "disable-consul.yml"
      check_interpolation "name: disable-consul-bosh-lite.yml" "disable-consul.yml" "-o ${home}/operations/bosh-lite.yml" "-o disable-consul-bosh-lite.yml"
      check_interpolation "name: disable-consul-windows.yml" "${home}/operations/windows2012R2-cell.yml" "-o disable-consul.yml" "-o disable-consul-windows.yml"
      check_interpolation "name: disable-consul-windows2016.yml" "${home}/operations/windows2016-cell.yml" "-o disable-consul.yml" "-o disable-consul-windows2016.yml"
      check_interpolation "name: disable-consul-windows1803.yml" "windows1803-cell.yml" "-o disable-consul.yml" "-o disable-consul-windows1803.yml"
      check_interpolation "disable-interpolate-service-bindings.yml"

      check_interpolation "name: enable-bits-service-consul.yml" "bits-service.yml" "-o bits-service-local.yml" "-o enable-bits-service-consul.yml"
      check_interpolation "enable-iptables-logger.yml"
      check_interpolation "enable-mysql-tls.yml"
      check_interpolation "enable-oci-phase-1.yml"
      check_interpolation "enable-routing-integrity.yml"
      check_interpolation "enable-suspect-actual-lrp-generation.yml"
      check_interpolation "enable-traffic-to-internal-networks.yml"
      check_interpolation "name: enable-tls-cloud-controller-postgres.yml" "${home}/operations/use-postgres.yml" "-o enable-tls-cloud-controller-postgres.yml"
      check_interpolation "use-create-swap-delete-vm-strategy.yml"

      check_interpolation "enable-nfs-volume-service-credhub.yml"
      check_interpolation "name: migrate-nfsbroker-mysql-to-credhub.yml" "${home}/operations/enable-nfs-volume-service.yml" "-o migrate-nfsbroker-mysql-to-credhub.yml" -l "${home}/operations/example-vars-files/vars-migrate-nfsbroker-mysql-to-credhub.yml"
      check_interpolation "enable-smb-volume-service.yml"
      check_interpolation "name: use-pxc-for-smb-volume-service.yml" "enable-smb-volume-service.yml" "-o use-pxc.yml" "-o use-pxc-for-smb-volume-service.yml"

      check_interpolation "fast-deploy-with-downtime-and-danger.yml"

      check_interpolation "infrastructure-metrics.yml"
      check_interpolation "migrate-cf-mysql-to-pxc.yml"
      check_interpolation "name: migrate-nfsbroker-mysql-to-credhub.yml" "${home}/operations/enable-nfs-volume-service.yml" "-o enable-nfs-volume-service-credhub.yml" "-o migrate-nfsbroker-mysql-to-credhub.yml" -l "${home}/operations/example-vars-files/vars-migrate-nfsbroker-mysql-to-credhub.yml"

      check_interpolation "name: perm-service.yml" "enable-mysql-tls.yml" "-o perm-service.yml -v perm_uaa_clients_cc_perm_secret=perm_secret -v perm_uaa_clients_perm_monitor_secret=perm_monitor_secret"
      check_interpolation "name: perm-service-with-pxc-release.yml" "perm-service.yml" "-o use-pxc.yml" "-o perm-service-with-pxc-release.yml -v perm_uaa_clients_cc_perm_secret=perm_secret -v perm_uaa_clients_perm_monitor_secret=perm_monitor_secret"
      check_interpolation "name: perm-service-with-tcp-routing.yml" "perm-service.yml" "-o use-pxc.yml" "-o perm-service-with-pxc-release.yml -v perm_uaa_clients_cc_perm_secret=perm_secret -v perm_uaa_clients_perm_monitor_secret=perm_monitor_secret" "-o perm-service-with-tcp-routing.yml"

      check_interpolation "rootless-containers.yml"

      check_interpolation "name: use-compiled-releases-xenial-stemcell.yml" "use-xenial-stemcell.yml" "-o use-compiled-releases-xenial-stemcell.yml"
      check_interpolation "name: use-compiled-releases-windows.yml" "${home}/operations/use-compiled-releases.yml" "-o ${home}/operations/windows-cell.yml" "-o use-compiled-releases-windows.yml"
      check_interpolation "use-garden-containerd.yml"
      check_interpolation "enable-bpm-garden.yml"
      check_interpolation "use-logcache-for-cloud-controller-app-stats.yml"
      check_interpolation "use-pxc.yml"
      check_interpolation "use-xenial-stemcell.yml"
      check_interpolation "set-cpu-weight.yml"

      check_interpolation "add-deployment-updater.yml"
      check_interpolation "name: add-deployment-updater-postgres.yml" "add-deployment-updater.yml" "-o add-deployment-updater-postgres.yml"
      check_interpolation "name: add-deployment-updater-external-db.yml" "${home}/operations/use-external-dbs.yml" "-o add-deployment-updater.yml" "-o add-deployment-updater-external-db.yml" "-l ${home}/operations/example-vars-files/vars-use-external-dbs.yml"
      check_interpolation "windows1803-cell.yml"
      version=$(bosh interpolate ${home}/cf-deployment.yml -o windows1803-cell.yml -o use-latest-windows1803-stemcell.yml --path=/stemcells/alias=windows1803/version)
      if [ "${version}" == "latest" ]; then
        pass "use-latest-windows1803-stemcell.yml"
      else
        fail "use-latest-windows1803-stemcell.yml, expected 'latest' but got '${version}'"
      fi
      check_interpolation "name: windows-component-syslog-ca.yml" "windows-enable-component-syslog.yml" "-o windows-component-syslog-ca.yml" "-l ${home}/operations/addons/example-vars-files/vars-enable-component-syslog.yml"
      check_interpolation "name: windows-enable-component-syslog.yml" "windows-enable-component-syslog.yml" "-l ${home}/operations/addons/example-vars-files/vars-enable-component-syslog.yml"
    popd > /dev/null # operations/experimental
  popd > /dev/null
  exit $exit_code
}
