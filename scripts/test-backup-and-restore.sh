#!/bin/bash

test_backup_and_restore_ops() {
  # Padded for pretty output
  suite_name="BACKUP AND RESTORE"

  pushd ${home} > /dev/null
    pushd operations/backup-and-restore > /dev/null
      check_interpolation "enable-backup-restore.yml"

      check_interpolation "name: enable-backup-restore-s3-versioned.yml"   "enable-backup-restore.yml" "-o ${home}/operations/use-external-blobstore.yml" "-o ${home}/operations/use-s3-blobstore.yml" "-o enable-backup-restore-s3-versioned.yml"   "-l ${home}/operations/example-vars-files/vars-use-s3-blobstore.yml"
      check_interpolation "name: enable-backup-restore-s3-unversioned.yml" "enable-backup-restore.yml" "-o ${home}/operations/use-external-blobstore.yml" "-o ${home}/operations/use-s3-blobstore.yml" "-o enable-backup-restore-s3-unversioned.yml" "-l ${home}/operations/example-vars-files/vars-use-s3-blobstore.yml" "-l example-vars-files/vars-enable-backup-restore-s3-unversioned.yml"

      check_interpolation "name: enable-backup-restore-azure.yml" "enable-backup-restore.yml" "-o ${home}/operations/use-external-blobstore.yml" "-o ${home}/operations/use-azure-storage-blobstore.yml" "-o enable-backup-restore-azure.yml" "-l ${home}/operations/example-vars-files/vars-use-azure-storage-blobstore.yml"
      check_interpolation "name: enable-restore-azure-clone.yml"  "enable-backup-restore.yml" "-o ${home}/operations/use-external-blobstore.yml" "-o ${home}/operations/use-azure-storage-blobstore.yml" "-o enable-restore-azure-clone.yml" "-l ${home}/operations/example-vars-files/vars-use-azure-storage-blobstore.yml" "-l example-vars-files/vars-enable-restore-azure-clone.yml"

      check_interpolation "name: enable-backup-restore-nfs-broker.yml" "enable-backup-restore.yml -o enable-backup-restore-nfs-broker.yml -v nfs-broker-database-password=i_am_a_password"

      check_interpolation "name: enable-backup-restore-smb-broker.yml" "enable-backup-restore.yml -o enable-backup-restore-smb-broker.yml -v azurefile-broker-database-password=i_am_a_password"
    popd > /dev/null
  popd > /dev/null
  exit $exit_code
}
