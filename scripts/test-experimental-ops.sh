#!/bin/bash

test_experimental_ops() {
  # Padded for pretty output
  suite_name="EXPERIMENTAL      "

  pushd ${home} > /dev/null
    pushd operations/experimental > /dev/null
      check_interpolation "name: add-credhub-lb.yml" "enable-instance-identity-credentials.yml" "-o secure-service-credentials.yml" "-o add-credhub-lb.yml"
      check_interpolation "name: bits-service-local.yml" "bits-service.yml" "-o bits-service-local.yml"
      check_interpolation "name: enable-bits-service-consul.yml" "bits-service.yml" "-o bits-service-local.yml" "-o enable-bits-service-consul.yml"
      check_interpolation "name: bits-service-webdav.yml" "bits-service.yml" "-o bits-service-webdav.yml"
      check_interpolation "name: bits-service-local.yml" "bits-service.yml" "-o enable-bits-service-https.yml" "-o bits-service-local.yml"
      check_interpolation "name: bits-service-webdav.yml" "bits-service.yml" "-o enable-bits-service-https.yml" "-o bits-service-webdav.yml"
      check_interpolation "disable-consul-service-registrations-locket.yml"
      check_interpolation "name: disable-consul-service-registrations-windows.yml" "${home}/operations/windows-cell.yml" "-o disable-consul-service-registrations-windows.yml"
      check_interpolation "disable-consul-service-registrations.yml"
      check_interpolation "disable-consul.yml"
      check_interpolation "name: disable-consul-bosh-lite.yml" "disable-consul.yml" "-o ${home}/operations/bosh-lite.yml" "-o disable-consul-bosh-lite.yml"
      check_interpolation "name: disable-consul-windows.yml" "${home}/operations/windows-cell.yml" "-o disable-consul.yml" "-o disable-consul-windows.yml"
      check_interpolation "name: disable-consul-windows2016.yml" "${home}/operations/windows2016-cell.yml" "-o disable-consul.yml" "-o disable-consul-windows2016.yml"
      check_interpolation "disable-interpolate-service-bindings.yml"
      check_interpolation "enable-traffic-to-internal-networks.yml"
      check_interpolation "enable-bpm.yml"
      check_interpolation "name: enable-instance-identity-credentials-windows.yml" "enable-instance-identity-credentials.yml" "-o ${home}/operations/windows-cell.yml" "-o enable-instance-identity-credentials-windows.yml"
      check_interpolation "name: enable-instance-identity-credentials-windows2016.yml" "enable-instance-identity-credentials.yml" "-o ${home}/operations/windows2016-cell.yml" "-o enable-instance-identity-credentials-windows2016.yml"
      check_interpolation "rootless-containers.yml"
      check_interpolation "enable-iptables-logger.yml"
      check_interpolation "enable-prefer-declarative-healthchecks.yml"
      check_interpolation "name: enable-prefer-declarative-healthchecks-windows.yml" "${home}/operations/windows-cell.yml" "-o enable-prefer-declarative-healthchecks-windows.yml"
      check_interpolation "name: enable-prefer-declarative-healthchecks-windows2016.yml" "${home}/operations/windows2016-cell.yml" "-o enable-prefer-declarative-healthchecks-windows2016.yml"
      check_interpolation "secure-service-credentials.yml"
      check_interpolation "name: secure-service-credentials-windows-cell.yml" "${home}/operations/windows-cell.yml" "-o secure-service-credentials.yml" "-o secure-service-credentials-windows-cell.yml"
      check_interpolation "name: secure-service-credentials-windows2016-cell.yml" "${home}/operations/windows2016-cell.yml" "-o secure-service-credentials.yml" "-o secure-service-credentials-windows2016-cell.yml"
      check_interpolation "name: secure-service-credentials-external-db.yml" "secure-service-credentials.yml" "-o ${home}/operations/use-external-dbs.yml" "-l ${home}/operations/example-vars-files/vars-use-external-dbs.yml" "-o secure-service-credentials-external-db.yml" "-l example-vars-files/vars-secure-service-credentials-external-db.yml"
      check_interpolation "name: secure-service-credentials-postgres.yml" "secure-service-credentials.yml" "-o ${home}/operations/use-external-dbs.yml" "-l ${home}/operations/example-vars-files/vars-use-external-dbs.yml" "-o secure-service-credentials-external-db.yml" "-l example-vars-files/vars-secure-service-credentials-external-db.yml"
      check_interpolation "name: secure-service-credentials-with-pxc-release.yml" "secure-service-credentials.yml" "-o use-pxc.yml" "-o secure-service-credentials-with-pxc-release.yml"
      check_interpolation "skip-consul-cell-registrations.yml"
      check_interpolation "skip-consul-locks.yml"
      check_interpolation "use-bosh-dns.yml"
      check_interpolation "use-bosh-dns-for-containers.yml"
      check_interpolation "name: use-bosh-dns-for-windows2016-containers.yml" "${home}/operations/windows2016-cell.yml" "-o use-bosh-dns.yml" "-o use-bosh-dns-for-windows2016-containers.yml"
      check_interpolation "use-bosh-dns-rename-network-and-deployment.yml" "-v network_name=new-network" "-v deployment_name=new-deployment"
      check_interpolation "use-shed.yml"
      check_interpolation "use-pxc.yml"
      check_interpolation "migrate-cf-mysql-to-pxc.yml"
      check_interpolation "use-grootfs.yml"
      check_interpolation "enable-oci-phase-1.yml"
      check_interpolation "name: enable-routing-integrity.yml" "enable-routing-integrity.yml" "-o enable-instance-identity-credentials.yml"
      check_interpolation "name: enable-service-discovery.yml" "use-bosh-dns-for-containers.yml" "-o enable-service-discovery.yml"
      check_interpolation "use-log-cache.yml"
      check_interpolation "fast-deploy-with-downtime-and-danger.yml"
      check_interpolation "name: enable-tls-cloud-controller-postgres" "${home}/operations/use-postgres.yml" "-o enable-tls-cloud-controller-postgres.yml"
      check_interpolation "name: windows-enable-component-syslog.yml" "windows-enable-component-syslog.yml" "-l ${home}/operations/addons/example-vars-files/vars-enable-component-syslog.yml"
      check_interpolation "improve-diego-log-format.yml"
      check_interpolation "name: improve-diego-log-format-windows.yml" "${home}/operations/windows-cell.yml" "-o improve-diego-log-format-windows.yml"
      check_interpolation "enable-mysql-tls.yml"
      check_interpolation "name: perm-service.yml" "use-bosh-dns.yml" "-o enable-mysql-tls.yml" "-o perm-service.yml"
      check_interpolation "name: perm-service-with-pxc-release.yml" "use-bosh-dns.yml" "-o perm-service.yml" "-o use-pxc.yml" "-o perm-service-with-pxc-release.yml"

    popd > /dev/null # operations/experimental
  popd > /dev/null
  exit $exit_code
}
