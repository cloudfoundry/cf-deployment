#!/bin/bash

test_backup_and_restore_ops() {
  # Padded for pretty output
  suite_name="BACKUP AND RESTORE"

  pushd ${home} > /dev/null
    pushd operations/backup-and-restore > /dev/null
      check_interpolation "name: enable-backup-restore.yml" "enable-backup-restore.yml"

      # s3 versioned & unversioned
      check_interpolation "name: enable-backup-restore-s3-versioned.yml"   "enable-backup-restore.yml" "-o ${home}/operations/use-external-blobstore.yml" "-o ${home}/operations/use-s3-blobstore.yml" "-o enable-backup-restore-s3-versioned.yml"   "-l ${home}/operations/example-vars-files/vars-use-s3-blobstore.yml"
      check_interpolation "name: enable-backup-restore-s3-unversioned.yml" "enable-backup-restore.yml" "-o ${home}/operations/use-external-blobstore.yml" "-o ${home}/operations/use-s3-blobstore.yml" "-o enable-backup-restore-s3-unversioned.yml" "-l ${home}/operations/example-vars-files/vars-use-s3-blobstore.yml" "-l example-vars-files/vars-enable-backup-restore-s3-unversioned.yml"

      # s3 versioned & unversioned, skip-droplets & skip-droplets-and-packages
      check_interpolation "name: skip-backup-restore-droplets.yml"   "enable-backup-restore.yml" "-o ${home}/operations/use-external-blobstore.yml" "-o ${home}/operations/use-s3-blobstore.yml" "-o enable-backup-restore-s3-versioned.yml" "-o skip-backup-restore-droplets.yml"  "-l ${home}/operations/example-vars-files/vars-use-s3-blobstore.yml"
      check_interpolation "name: skip-backup-restore-droplets-and-packages.yml"   "enable-backup-restore.yml" "-o ${home}/operations/use-external-blobstore.yml" "-o ${home}/operations/use-s3-blobstore.yml" "-o enable-backup-restore-s3-versioned.yml" "-o skip-backup-restore-droplets-and-packages.yml"  "-l ${home}/operations/example-vars-files/vars-use-s3-blobstore.yml"

      check_interpolation "name: skip-backup-restore-droplets.yml"   "enable-backup-restore.yml" "-o ${home}/operations/use-external-blobstore.yml" "-o ${home}/operations/use-s3-blobstore.yml" "-o enable-backup-restore-s3-unversioned.yml" "-o skip-backup-restore-droplets.yml"  "-l ${home}/operations/example-vars-files/vars-use-s3-blobstore.yml" "-l example-vars-files/vars-enable-backup-restore-s3-unversioned.yml"
      check_interpolation "name: skip-backup-restore-droplets-and-packages.yml"   "enable-backup-restore.yml" "-o ${home}/operations/use-external-blobstore.yml" "-o ${home}/operations/use-s3-blobstore.yml" "-o enable-backup-restore-s3-unversioned.yml" "-o skip-backup-restore-droplets-and-packages.yml"  "-l ${home}/operations/example-vars-files/vars-use-s3-blobstore.yml" "-l example-vars-files/vars-enable-backup-restore-s3-unversioned.yml"

      # azure
      check_interpolation "name: enable-backup-restore-azure.yml" "enable-backup-restore.yml" "-o ${home}/operations/use-external-blobstore.yml" "-o ${home}/operations/use-azure-storage-blobstore.yml" "-o enable-backup-restore-azure.yml" "-l ${home}/operations/example-vars-files/vars-use-azure-storage-blobstore.yml"
      check_interpolation "name: enable-restore-azure-clone.yml"  "enable-backup-restore.yml" "-o ${home}/operations/use-external-blobstore.yml" "-o ${home}/operations/use-azure-storage-blobstore.yml" "-o enable-restore-azure-clone.yml"  "-l ${home}/operations/example-vars-files/vars-use-azure-storage-blobstore.yml" "-l example-vars-files/vars-enable-restore-azure-clone.yml"

      # azure skip-droplets & skip-droplets-and-packages
      check_interpolation "name: skip-backup-restore-droplets.yml" "enable-backup-restore.yml" "-o ${home}/operations/use-external-blobstore.yml" "-o ${home}/operations/use-azure-storage-blobstore.yml" "-o enable-backup-restore-azure.yml" "-o skip-backup-restore-droplets.yml" "-l ${home}/operations/example-vars-files/vars-use-azure-storage-blobstore.yml"
      check_interpolation "name: skip-backup-restore-droplets-and-packages.yml" "enable-backup-restore.yml" "-o ${home}/operations/use-external-blobstore.yml" "-o ${home}/operations/use-azure-storage-blobstore.yml" "-o enable-backup-restore-azure.yml" "-o skip-backup-restore-droplets-and-packages.yml" "-l ${home}/operations/example-vars-files/vars-use-azure-storage-blobstore.yml"

      check_interpolation "name: skip-backup-restore-droplets.yml"  "enable-backup-restore.yml" "-o ${home}/operations/use-external-blobstore.yml" "-o ${home}/operations/use-azure-storage-blobstore.yml" "-o enable-restore-azure-clone.yml" "-o skip-backup-restore-droplets.yml" "-l ${home}/operations/example-vars-files/vars-use-azure-storage-blobstore.yml" "-l example-vars-files/vars-enable-restore-azure-clone.yml"
      check_interpolation "name: skip-backup-restore-droplets-and-packages.yml"  "enable-backup-restore.yml" "-o ${home}/operations/use-external-blobstore.yml" "-o ${home}/operations/use-azure-storage-blobstore.yml" "-o enable-restore-azure-clone.yml" "-o skip-backup-restore-droplets-and-packages.yml" "-l ${home}/operations/example-vars-files/vars-use-azure-storage-blobstore.yml" "-l example-vars-files/vars-enable-restore-azure-clone.yml"

      # gcs
      check_interpolation "name: enable-backup-restore-gcs.yml" "enable-backup-restore.yml" "-o ${home}/operations/use-external-blobstore.yml" "-o ${home}/operations/use-gcs-blobstore-service-account.yml" "-o enable-backup-restore-gcs.yml" "-l ${home}/operations/example-vars-files/vars-use-gcs-blobstore-service-account.yml" "-l ${home}/operations/backup-and-restore/example-vars-files/vars-enable-backup-restore-gcs.yml"

      # gcs skip-droplets & skip-droplets-and-packages
      check_interpolation "name: skip-backup-restore-droplets.yml" "enable-backup-restore.yml" "-o ${home}/operations/use-external-blobstore.yml" "-o ${home}/operations/use-gcs-blobstore-service-account.yml" "-o enable-backup-restore-gcs.yml" "-o skip-backup-restore-droplets.yml" "-l ${home}/operations/example-vars-files/vars-use-gcs-blobstore-service-account.yml" "-l ${home}/operations/backup-and-restore/example-vars-files/vars-enable-backup-restore-gcs.yml"
      check_interpolation "name: skip-backup-restore-droplets-and-packages.yml" "enable-backup-restore.yml" "-o ${home}/operations/use-external-blobstore.yml" "-o ${home}/operations/use-gcs-blobstore-service-account.yml" "-o enable-backup-restore-gcs.yml" "-o skip-backup-restore-droplets-and-packages.yml" "-l ${home}/operations/example-vars-files/vars-use-gcs-blobstore-service-account.yml" "-l ${home}/operations/backup-and-restore/example-vars-files/vars-enable-backup-restore-gcs.yml"

      # nfs
      check_interpolation "name: enable-backup-restore-nfs-broker.yml" "enable-backup-restore.yml" "-o enable-backup-restore-nfs-broker.yml" "-v nfs-broker-database-password=i_am_a_password"
      check_interpolation "name: enable-backup-restore-nfs-broker.yml" "enable-backup-restore.yml -o enable-backup-restore-nfs-broker.yml -v nfs-broker-database-password=i_am_a_password"
    popd > /dev/null
  popd > /dev/null
  exit $exit_code
}
