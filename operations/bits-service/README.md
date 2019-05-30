# Bits Service Ops-files

This is the README for Bits Service Ops-files. Use these to configure your deployment for use with [Bits Service](https://github.com/cloudfoundry-incubator/bits-service).
To learn more about `cf-deployment`, go to the main [README](../../README.md).

- For General Ops-files, check out the [Ops-file README](../README.md).
- For Addons Ops-files that can be applied to manifests or runtime configs, check out the [Addons Ops-file README](../addons/README.md).
- For Backup and Restore Ops-files (for configuring your deployment for use with [BBR](https://github.com/cloudfoundry-incubator/bosh-backup-and-restore)), checkout the [Backup and Restore Ops-files README](../backup-and-restore/README.md).
- For Community Ops-files, check out the [Community Ops-file README](../community/README.md).
- For Experimental Ops-files, check out the [Experimental Ops-file README](../experimental/README.md).

## Ops-Files

| Name | Purpose | Notes | Validated in our Pipelines? |
|:---  |:---     |:---   | :---                        |
| [`use-bits-service.yml`](use-bits-service.yml) | Adds the [bits-service](https://github.com/cloudfoundry-incubator/bits-service) job and enables it in the cloud-controller. | | Yes |
| [`configure-bits-service-alicloud-oss.yml`](configure-bits-service-alicloud-oss.yml) | Use Alicloud for the [bits-service](https://github.com/cloudfoundry-incubator/bits-service). | `use-alicloud-oss-blobstore.yml` from the root `operations` directory is also required. | No |
| [`configure-bits-service-azure-storage.yml`](configure-bits-service-azure-storage.yml) | Use Azure Storage for the [bits-service](https://github.com/cloudfoundry-incubator/bits-service). | `use-azure-storage-blobstore.yml` from the root `operations` directory is also required. | No |
| [`configure-bits-service-gcs-access-key.yml`](configure-bits-service-gcs-access-key.yml) | Use Google storage with access key credentials for the [bits-service](https://github.com/cloudfoundry-incubator/bits-service). | `use-gcs-blobstore-access-key.yml` from the root `operations` directory is also required. | No |
| [`configure-bits-service-gcs-service-account.yml`](configure-bits-service-gcs-service-account.yml) | Use Google storage with a service account credentials for the [bits-service](https://github.com/cloudfoundry-incubator/bits-service). | `use-gcs-blobstore-service-account.yml` from the root `operations` directory is also required. | Yes |
| [`configure-bits-service-s3.yml`](configure-bits-service-s3.yml) | Use s3 storage for the [bits-service](https://github.com/cloudfoundry-incubator/bits-service). | `use-s3-blobstore.yml` from the root `operations` directory is also required. | Yes |
| [`configure-bits-service-swift.yml`](configure-bits-service-swift.yml) | Use Openstack/Swift for the [bits-service](https://github.com/cloudfoundry-incubator/bits-service). | `use-swift-blobstore.yml` from the root `operations` directory is also required. | No |
