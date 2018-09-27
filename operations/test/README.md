# cf-deployment Test Ops-files

This is the README for Test Ops-files. To learn more about `cf-deployment`, go to the main [README](../../README.md). 

The opsfile in this directory are meant for testing and are **not meant for production environments**.

They may change without notice.

- For general Ops-files, check out the [Ops-file README](../README.md).
- For experimental Ops-files, check out the [Experimental Ops-file README](../experimental/README.md)
- For Community Ops-files, check out the [Community Ops-file README](../community/README.md).
- For Addons Ops-files that can be applied to manifests or runtime configs, check out the [Addons Ops-file README](../addons/README.md).
- For Backup and Restore Ops-files (for configuring your deployment for use with [BBR](https://github.com/cloudfoundry-incubator/bosh-backup-and-restore)), checkout the [Backup and Restore Ops-files README](../backup-and-restore/README.md).

| Name | Purpose | Notes |
|:---  |:---     |:---   |
| [`add-oidc-provider.yml `](add-oidc-provider.yml) | Allows testing of UAA with users authenticated via an OIDC provider | Creates a second UAA instance group that acts as the OIDC provider |

