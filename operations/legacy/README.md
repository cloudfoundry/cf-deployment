# cf-deployment Legacy Ops-files

The ops files in this directory
are meant to enable operators of `cf-deployment`
who have migrated from `cf-release`.

Operators who never migrated from `cf-release`
to `cf-deployment`
need not concern themselves with this directory.

This is the README for Legacy Ops-files. To learn more about `cf-deployment`, go to the main [README](../README.md). 

- For general Ops-files, check out the [Ops-file README](../README.md).
- For experimental Ops-files, check out the [Experimental Ops-file README](../experimental/README.md).
- For Community Ops-files, check out the [Community Ops-file README](../community/README.md).
- For Addons Ops-files that can be applied to manifests or runtime configs, check out the [Addons Ops-file README](addons/README.md).

| Name | Purpose | Notes |
|:---  |:---     |:---   |
| [`keep-original-internal-usernames.yml`](keep-original-internal-usernames.yml) | Maintains operator-provided usernames | Provides ability to set values for `properties.nats.user`, `properties.cc.staging_upload_user`, `properties.router.status.user` |
| [`keep-static-ips.yml`](keep-static-ips.yml) | Holds `consul` and `nats` instances at a static IP address for transition between `cf-release` and `cf-deployment`. | Deployers must provide the IP addresses |
| [`old-droplet-mitigation.yml`](old-droplet-mitigation.yml) | Mitigates against old droplets that may still have a legacy security vulnerability. | See comment in the ops file for more details. |