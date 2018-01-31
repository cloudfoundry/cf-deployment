# cf-deployment Experimental Ops-files

This is the README for Experimental Ops-files. To learn more about `cf-deployment`, go to the main [README](../README.md). 

- For general Ops-files, check out the [Ops-file README](../README.md).
- For Legacy Ops-files, check out the [Legacy Ops-file README](../legacy/README.md).
- For Community Ops-files, checkout the [Community Ops-file README](../community/README.md).
- For Addons Ops-files that can be applied to manifests or runtime configs, check out the [Addons Ops-file README](addons/README.md).

"Experimental" ops-files represent configurations
that we expect to promote to blessed configuration eventually,
meaning that,
once the configurations have been sufficiently validated,
they will become part of cf-deployment.yml
and the ops-files will be removed.

| Name | Purpose | Notes |
|:---  |:---     |:---   |
| [`add-credhub-lb.yml`](add-credhub-lb.yml) | Use load balancer to expose external address for CredHub. | Requires `secure-service-credentials.yml`. |
| [`bits-service.yml`](bits-service.yml) | Adds the [bits-service](https://github.com/cloudfoundry-incubator/bits-service) job and enables it in the cloud-controller. | Also requires one of `bits-service-{local,webdav,s3}.yml` from the same directory. |
| [`bits-service-local.yml`](bits-service-local.yml) | Use local storage for the [bits-service](https://github.com/cloudfoundry-incubator/bits-service). | |
| [`bits-service-s3.yml`](bits-service-s3.yml) | Use s3 storage for the [bits-service](https://github.com/cloudfoundry-incubator/bits-service). | `use-s3-blobstore.yml` from the root `operations` directory is also required. |
| [`bits-service-webdav.yml`](bits-service-webdav.yml) | Use the `blobstore`'s webdav storage for the [bits-service](https://github.com/cloudfoundry-incubator/bits-service). | Requires the `blobstore` job. |
| [`disable-interpolate-service-bindings.yml`](disable-interpolate-service-bindings.yml) | Disables the interpolation of CredHub service credentials by Cloud Controller. |
| [`enable-bits-service-consul.yml`](enable-bits-service-consul.yml) | Registers the bits-service [bits-service](https://github.com/cloudfoundry-incubator/bits-service) job via consul | Requires `bits-service.yml` from the same directory. |
| [`enable-bits-service-https.yml`](enable-bits-service-https.yml) | Deprecated and left intentionally blank - the bits service is now `https` only | |
| [`enable-bpm.yml`](enable-bpm.yml) | Enables the [BOSH Process Manager](https://github.com/cloudfoundry-incubator/bpm-release) as a BOSH addon. | |
| [`disable-consul.yml`](disable-consul.yml) | Removes `consul` instance group and `consul_agent` jobs and prevents the `auctioneer`, `ssh_proxy`, `file_server`, `rep`, `locket`, and `bbs` jobs from registering as a service with Consul | Requires `skip-consul-cell-registrations.yml`, `skip-consul-locks.yml`, and `use-bosh-dns.yml` |
| [`disable-consul-bosh-lite.yml`](disable-consul-bosh-lite.yml) | Compatibility shim for disabling Consul on BOSH-Lite. | Apply `disable-consul.yml`, `bosh-lite.yml`, and then `disable-consul-bosh-lite.yml`, in that order. |
| [`disable-consul-windows.yml`](disable-consul-windows.yml) | Removes `consul` job from `windows-cell` instance group and prevents the Windows cell rep from registering itself as a service with Consul | Requires `use-bosh-dns.yml` and `windows-cell.yml` |
| [`disable-consul-windows2016.yml`](disable-consul-windows2016.yml) | Removes `consul` job from `windows2016-cell` instance group and prevents the Windows 2016 cell rep from registering itself as a service with Consul | Requires `use-bosh-dns.yml` and `windows2016-cell.yml` |
| [`disable-consul-service-registrations-locket.yml`](disable-consul-service-registrations-locket.yml) | This file is a no-op and should not be used, but kept for backward compatabilty. Please use `disable-consul.yml` instead. | Previously: Prevents the `locket` server from registering itself as a service with Consul |
| [`disable-consul-service-registrations-windows.yml`](disable-consul-service-registrations-windows.yml) | This file is a no-op and should not be used, but kept for backward compatabilty. Please use `disable-consul-windows.yml` instead. | Requires `windows-cell.yml` |
| [`disable-consul-service-registrations.yml`](disable-consul-service-registrations.yml) | This file is a no-op and should not be used, but kept for backward compatabilty. Please use `disable-consul.yml` instead. | Previously: Prevents the `auctioneer`, `ssh_proxy`, `file_server`, `rep`, `locket`, and `bbs` jobs from registering as a service with Consul |
| [`enable-backup-restore.yml`](enable-backup-restore.yml) | Deploy BOSH backup and restore instance and enable release level backup. | |
| [`enable-backup-restore-credhub.yml`](enable-backup-restore-credhub.yml) | Collocate database-backup-restorer job on the credhub instance. Should be applied after `secure-service-credentials.yml` Ops-file. | |
| [`enable-backup-restore-s3.yml`](enable-backup-restore-s3.yml) | Enables the backup and restore of S3 blobstores. | Requires `enable-backup-restore.yml` and `use-s3-blobstore.yml` |
| [`enable-instance-identity-credentials.yml`](enable-instance-identity-credentials.yml) | Enables identity credentials on Diego Cell `rep`. | |
| [`enable-instance-identity-credentials-windows.yml`](enable-instance-identity-credentials-windows.yml) | Enables identity credentials on the `rep_windows` for Windows 2012 cells. | Requires `enable-instance-identity-credentials.yml` and `windows-cell.yml`|
| [`enable-instance-identity-credentials-windows2016.yml`](enable-instance-identity-credentials-windows2016.yml) | Enables identity credentials on the `rep_windows` for Windows 2016 cells. | Requires `enable-instance-identity-credentials.yml` and `windows2016-cell.yml`|
| [`enable-iptables-logger.yml`](enable-iptables-logger.yml) | Enables iptables logger. | |
| [`enable-nfs-broker-backup.yml`](enable-nfs-broker-backup.yml) | Deploy BOSH backup and restore scripts for the NFS service broker. | Requires `enable-backup-restore.yml` and `operations/enable-nfs-volume-service.yml`. |
| [`enable-prefer-declarative-healthchecks.yml`](enable-prefer-declarative-healthchecks.yml) | Configure the Rep on the diego cells to prefer LRP CheckDefinition (a.k.a declarative healthchecks) over the old Monitor action | |
| [`enable-prefer-declarative-healthchecks-windows.yml`](enable-prefer-declarative-healthchecks-windows.yml) | Configure the Rep on the windows 2012 cells to prefer LRP CheckDefinition (a.k.a declarative healthchecks) over the old Monitor action | |
| [`enable-prefer-declarative-healthchecks-windows2016.yml`](enable-prefer-declarative-healthchecks-windows2016.yml) | Configure the Rep on the windows 2016 cells to prefer LRP CheckDefinition (a.k.a declarative healthchecks) over the old Monitor action | |
| [`enable-routing-integrity.yml`](enable-routing-integrity.yml) | Enables container proxy on the Diego Cell `rep` and configures gorouter to opt into TLS-enabled connections to the backend. | Requires `enable-instance-identity-credentials.yml` |
| [`enable-service-discovery.yml`](enable-service-discovery.yml) | Enables application service discovery | Requires bosh-dns-release >= 0.2.0, capi-release >= 1.47.0, and `use-bosh-dns-for-containers.yml` |
| [`enable-traffic-to-internal-networks.yml`](enable-traffic-to-internal-networks.yml) | Allows traffic from app containers to internal networks. Required to allow applications to communicate with the running CredHub in non-assisted mode. | |
| [`rootless-containers.yml`](rootless-containers.yml) | Enable rootless garden-runc containers. | Requires garden-runc 1.9.5 or later and grootfs 0.27.0 or later. |
| [`secure-service-credentials.yml`](secure-service-credentials.yml) | Use CredHub for service credentials. | Requires `enable-instance-identity-credentials.yml`. BOSH DNS is required if not using a credhub load balancer. You can add a credhub load balancer with `add-credhub-lb.yml`. |
| [`secure-service-credentials-windows-cell.yml`](secure-service-credentials-windows-cell.yml) | Adds CredHub TLS CA as a trusted cert to the Windows Cell. | Requires `secure-service-credentials.yml`, `enable-instance-identity-credentials.yml`, and `enable-instance-identity-credentials-windows.yml`. |
| [`secure-service-credentials-windows2016-cell.yml`](secure-service-credentials-windows2016-cell.yml) | Adds CredHub TLS CA as a trusted cert to the Windows 2016 Cell. | Requires `secure-service-credentials.yml`, `enable-instance-identity-credentials.yml`, and `enable-instance-identity-credentials-windows2016.yml`. |
| [`secure-service-credentials-external-db.yml`](secure-service-credentials-external-db.yml) | Use external database for CredHub data store. | Requires `secure-service-credentials.yml` and `use-external-dbs.yml`. |
| [`secure-service-credentials-postgres.yml`](secure-service-credentials-postgres.yml) | Use local postgres database for CredHub data store. | Requires `secure-service-credentials.yml` and `use-postgres.yml`. |
| [`skip-consul-cell-registrations.yml`](skip-consul-cell-registrations.yml) | Configure the BBS to only use Locket to find registered Diego cells | |
| [`skip-consul-locks.yml`](skip-consul-locks.yml) | Prevent several components from also attempting to claim a lock in Consul | |
| [`use-bosh-dns.yml`](use-bosh-dns.yml) | Adds `bosh-dns` job to all instance groups running ubuntu-trusty via Bosh Addon. | Aliases `service.cf.internal` domains to their `bosh-dns` equivalents. |
| [`use-bosh-dns-for-containers.yml`](use-bosh-dns-for-containers.yml) | Sets the DNS server of application containers to the address of the local `bosh-dns` job. | Requires `use-bosh-dns.yml` |
| [`use-bosh-dns-for-windows2016-containers.yml`](use-bosh-dns-for-windows2016-containers.yml) | Sets the DNS server of application containers (on windows2016 cell) to the address of the local `bosh-dns` job. | Requires `use-bosh-dns.yml` |
| [`use-shed.yml`](use-shed.yml) | Enable deprecated garden-shed on diego cells. | |
| [`use-grootfs.yml`](use-grootfs.yml) | Groot is enabled by default. This file is blank to avoid breaking deployment scripts. | |
| [`enable-oci-phase-1.yml`](enable-oci-phase-1.yml) | Configure Garden to create OCI compatible images. | |
| [`use-latest-windows2016-stemcell.yml`](use-latest-windows2016-stemcell.yml) | Use the latest `windows2016` stemcell available on your BOSH director instead of the one in `windows2016-cell.yml` | Requires `windows2016-cell.yml` |
| [`use-offline-windows2016fs.yml`](use-offline-windows2016fs.yml) | Use the offline version of [windows2016fs-release](https://github.com/cloudfoundry-incubator/windows2016fs-release) | Requires `windows2016-cell.yml`. Suitable for environments without internet access. Follow instructions [here](https://github.com/cloudfoundry-incubator/windows2016fs-release/blob/master/README.md) to upload the release prior to deploying. |
| [`windows2016-cell.yml`](windows2016-cell.yml) | Deploys a windows 2016 diego cell, adds releases necessary for windows. |  |
