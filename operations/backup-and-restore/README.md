# Backup and Restore ops-files

This is the README for Backup and Restore Ops-files. Use these to configure your deployment for use with [BBR](https://github.com/cloudfoundry-incubator/bosh-backup-and-restore).
For more information about using these ops-files, see [the Cloud Foundry docs](https://docs.cloudfoundry.org/bbr/cf-backup.html).
To learn more about `cf-deployment`, go to the main [README](../README.md).

- For general Ops-files, check out the [Ops-file README](../README.md).
- For experimental Ops-files, check out the [Experimental Ops-file README](../experimental/README.md).
- For Community Ops-files, check out the [Community Ops-file README](../community/README.md).
- For Legacy Ops-files, checkout the [Legacy Ops-file README](../legacy/README.md).
- For Addons Ops-files that can be applied to manifests or runtime configs, check out the [Addons Ops-file README](addons/README.md).

## Ops-Files

| Name | Purpose | Notes |
|:---  |:---     |:---   |
| [`enable-backup-restore.yml`](enable-backup-restore.yml) | Deploy BOSH backup and restore instance and enable release level backup. | |
| [`enable-backup-restore-credhub.yml`](enable-backup-restore-credhub.yml) | Collocate database-backup-restorer job on the credhub instance. Should be applied after `secure-service-credentials.yml` Ops-file. | |
| [`enable-backup-restore-s3-versioned.yml`](enable-backup-restore-s3-versioned.yml) | Enables the backup and restore of versioned S3 blobstores. | Requires `enable-backup-restore.yml` and `use-s3-blobstore.yml` |
| [`enable-backup-restore-s3-unversioned.yml`](enable-backup-restore-s3-unversioned.yml) | Enables the backup and restore of unversioned S3 blobstores. | Requires `enable-backup-restore.yml` and `use-s3-blobstore.yml` |
| [`enable-backup-restore-nfs-broker.yml`](enable-backup-restore-nfs-broker.yml) | Deploy BOSH backup and restore scripts for the NFS service broker. | Requires `enable-backup-restore.yml` and `operations/enable-nfs-volume-service.yml`. |
