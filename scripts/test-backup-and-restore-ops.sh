#!/bin/bash

test_backup_and_restore_ops() {
  # Padded for pretty output
  suite_name="BACKUP AND RESTORE"

  pushd ${home} > /dev/null
    pushd operations/backup-and-restore > /dev/null
      check_interpolation "enable-backup-restore.yml"
      check_interpolation "name: enable-backup-restore-credhub.yml" "enable-backup-restore.yml" "-o ${home}/operations/experimental/enable-instance-identity-credentials.yml" "-o ${home}/operations/experimental/secure-service-credentials.yml" "-o enable-backup-restore-credhub.yml"
      check_interpolation "name: enable-backup-restore-credhub-postgres.yml" "enable-backup-restore.yml" "-o ${home}/operations/experimental/enable-instance-identity-credentials.yml" "-o ${home}/operations/experimental/secure-service-credentials.yml" "-o ${home}/operations/use-postgres.yml" "-o ${home}/operations/experimental/secure-service-credentials-postgres.yml" "-o enable-backup-restore-credhub-postgres.yml"
      check_interpolation "name: enable-backup-restore-credhub-external-db.yml" "enable-backup-restore.yml" "-o ${home}/operations/experimental/enable-instance-identity-credentials.yml" "-o ${home}/operations/experimental/secure-service-credentials.yml" "-o ${home}/operations/experimental/secure-service-credentials-external-db.yml" "-o enable-backup-restore-credhub-external-db.yml"
      check_interpolation "name: enable-backup-restore-s3-versioned.yml" "enable-backup-restore.yml" "-o ${home}/operations/use-s3-blobstore.yml" "-o enable-backup-restore-s3-versioned.yml" "-l ${home}/operations/example-vars-files/vars-use-s3-blobstore.yml"
      check_interpolation "name: enable-backup-restore-s3-unversioned.yml" "enable-backup-restore.yml" "-o ${home}/operations/use-s3-blobstore.yml" "-o enable-backup-restore-s3-unversioned.yml" "-l ${home}/operations/example-vars-files/vars-use-s3-blobstore.yml" "-l  example-vars-files/vars-enable-backup-restore-s3-unversioned.yml"
      check_interpolation "name: enable-backup-restore-nfs-broker.yml" "enable-backup-restore.yml -o enable-backup-restore-nfs-broker.yml -v nfs-broker-database-password=i_am_a_password"
    popd > /dev/null
  popd > /dev/null
  exit $exit_code
}
