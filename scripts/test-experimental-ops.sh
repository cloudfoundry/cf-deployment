#!/bin/bash

test_experimental_ops() {
  suite_name="EXPERIMENTAL"

  pushd ${home} > /dev/null
    pushd operations/experimental > /dev/null
      check_interpolation "name: add-credhub-lb.yml" "enable-instance-identity-credentials.yml" "-o secure-service-credentials.yml" "-o add-credhub-lb.yml"
      check_interpolation "name: bits-service-local.yml" "bits-service.yml" "-o bits-service-local.yml"
      check_interpolation "name: enable-bits-service-consul.yml" "bits-service.yml" "-o bits-service-local.yml" "-o enable-bits-service-consul.yml"
      check_interpolation "name: bits-service-s3.yml" "${home}/operations/use-s3-blobstore.yml" "-o bits-service.yml" "-o bits-service-s3.yml" "-l ${home}/operations/example-vars-files/vars-use-s3-blobstore.yml"
      check_interpolation "name: bits-service-webdav.yml" "bits-service.yml" "-o bits-service-webdav.yml"
      check_interpolation "name: bits-service-local.yml" "bits-service.yml" "-o enable-bits-service-https.yml" "-o bits-service-local.yml"
      check_interpolation "name: bits-service-s3.yml" "${home}/operations/use-s3-blobstore.yml" "-o bits-service.yml" "-o enable-bits-service-https.yml" "-o bits-service-s3.yml" "-l ${home}/operations/example-vars-files/vars-use-s3-blobstore.yml"
      check_interpolation "name: bits-service-webdav.yml" "bits-service.yml" "-o enable-bits-service-https.yml" "-o bits-service-webdav.yml"
      check_interpolation "disable-consul-service-registrations-locket.yml"
      check_interpolation "name: disable-consul-service-registrations-windows.yml" "${home}/operations/windows-cell.yml" "-o disable-consul-service-registrations-windows.yml"
      check_interpolation "disable-consul-service-registrations.yml"
      check_interpolation "disable-consul.yml"
      check_interpolation "name: disable-consul-bosh-lite.yml" "disable-consul.yml" "-o ${home}/operations/bosh-lite.yml" "-o disable-consul-bosh-lite.yml"
      check_interpolation "name: disable-consul-windows.yml" "${home}/operations/windows-cell.yml" "-o disable-consul.yml" "-o disable-consul-windows.yml"
      check_interpolation "name: disable-consul-windows2016.yml" "windows2016-cell.yml" "-o disable-consul.yml" "-o disable-consul-windows2016.yml"
      check_interpolation "disable-interpolate-service-bindings.yml"
      check_interpolation "enable-traffic-to-internal-networks.yml"
      check_interpolation "enable-backup-restore.yml"
      check_interpolation "name: enable-backup-restore-credhub.yml" "enable-backup-restore.yml" "-o enable-instance-identity-credentials.yml" "-o secure-service-credentials.yml" "-o enable-backup-restore-credhub.yml"
      check_interpolation "name: enable-backup-restore-s3.yml" "enable-backup-restore.yml" "-o ${home}/operations/use-s3-blobstore.yml" "-o enable-backup-restore-s3.yml" "-l ${home}/operations/example-vars-files/vars-use-s3-blobstore.yml"
      check_interpolation "enable-bpm.yml"
      check_interpolation "name: enable-nfs-broker-backup.yml" "enable-backup-restore.yml -o enable-nfs-broker-backup.yml -v nfs-broker-database-password=i_am_a_password"
      check_interpolation "name: enable-instance-identity-credentials-windows.yml" "enable-instance-identity-credentials.yml" "-o ${home}/operations/windows-cell.yml" "-o enable-instance-identity-credentials-windows.yml"
      check_interpolation "name: enable-instance-identity-credentials-windows2016.yml" "enable-instance-identity-credentials.yml" "-o windows2016-cell.yml" "-o enable-instance-identity-credentials-windows2016.yml"
      check_interpolation "rootless-containers.yml"
      check_interpolation "enable-iptables-logger.yml"
      check_interpolation "enable-prefer-declarative-healthchecks.yml"
      check_interpolation "name: enable-prefer-declarative-healthchecks-windows.yml" "${home}/operations/windows-cell.yml" "-o enable-prefer-declarative-healthchecks-windows.yml"
      check_interpolation "name: enable-prefer-declarative-healthchecks-windows2016.yml" "windows2016-cell.yml" "-o enable-prefer-declarative-healthchecks-windows2016.yml"
      check_interpolation "name: secure-service-credentials.yml" "enable-instance-identity-credentials.yml" "-o secure-service-credentials.yml"
      check_interpolation "name: secure-service-credentials-windows-cell.yml" "enable-instance-identity-credentials.yml" "-o ${home}/operations/windows-cell.yml" "-o enable-instance-identity-credentials-windows.yml" "-o secure-service-credentials.yml" "-o secure-service-credentials-windows-cell.yml"
      check_interpolation "name: secure-service-credentials-windows2016-cell.yml" "enable-instance-identity-credentials.yml" "-o windows2016-cell.yml" "-o enable-instance-identity-credentials-windows2016.yml" "-o secure-service-credentials.yml" "-o secure-service-credentials-windows2016-cell.yml"
      check_interpolation "name: secure-service-credentials-external-db.yml" "enable-instance-identity-credentials.yml" "-o secure-service-credentials.yml" "-o ${home}/operations/use-external-dbs.yml" "-l ${home}/operations/example-vars-files/vars-use-external-dbs.yml" "-o secure-service-credentials-external-db.yml" "-l example-vars-files/vars-secure-service-credentials-external-db.yml"
      check_interpolation "name: secure-service-credentials-postgres.yml" "enable-instance-identity-credentials.yml" "-o secure-service-credentials.yml" "-o ${home}/operations/use-external-dbs.yml" "-l ${home}/operations/example-vars-files/vars-use-external-dbs.yml" "-o secure-service-credentials-external-db.yml" "-l example-vars-files/vars-secure-service-credentials-external-db.yml"
      check_interpolation "skip-consul-cell-registrations.yml"
      check_interpolation "skip-consul-locks.yml"
      check_interpolation "use-bosh-dns.yml"
      check_interpolation "use-bosh-dns-for-containers.yml"
      check_interpolation "name: use-bosh-dns-for-windows2016-containers.yml" "windows2016-cell.yml" "-o use-bosh-dns.yml" "-o use-bosh-dns-for-windows2016-containers.yml"
      check_interpolation "use-shed.yml"
      check_interpolation "use-grootfs.yml"
      check_interpolation "enable-oci-phase-1.yml"
      version=$(bosh interpolate ${home}/cf-deployment.yml -o windows2016-cell.yml -o use-latest-windows2016-stemcell.yml --path=/stemcells/alias=windows2016/version)
      if [ "${version}" == "latest" ]; then
        pass "use-latest-windows2016-stemcell.yml"
      else
        fail "use-latest-windows2016-stemcell.yml, expected 'latest' but got '${version}'"
      fi
      check_interpolation "name: use-offline-windows2016fs.yml" "windows2016-cell.yml" "-o use-offline-windows2016fs.yml"
      check_interpolation "windows2016-cell.yml"
      check_interpolation "name: operations/windows-cell.yml windows2016-cell.yml" "${home}/operations/windows-cell.yml" "-o windows2016-cell.yml"
      check_interpolation "name: enable-routing-integrity.yml" "enable-routing-integrity.yml" "-o enable-instance-identity-credentials.yml"
      check_interpolation "name: enable-service-discovery.yml" "use-bosh-dns-for-containers.yml" "-o enable-service-discovery.yml"
    popd > /dev/null # operations/experimental
  popd > /dev/null
  exit $exit_code
}
