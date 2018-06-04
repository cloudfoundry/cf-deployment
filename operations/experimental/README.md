# cf-deployment Experimental Ops-files

This is the README for Experimental Ops-files. To learn more about `cf-deployment`, go to the main [README](../README.md). 

- For general Ops-files, check out the [Ops-file README](../README.md).
- For Legacy Ops-files, check out the [Legacy Ops-file README](../legacy/README.md).
- For Community Ops-files, checkout the [Community Ops-file README](../community/README.md).
- For Addons Ops-files that can be applied to manifests or runtime configs, check out the [Addons Ops-file README](../addons/README.md).
- For Backup and Restore Ops-files (for configuring your deployment for use with [BBR](https://github.com/cloudfoundry-incubator/bosh-backup-and-restore)), checkout the [Backup and Restore Ops-files README](../backup-and-restore/README.md).

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
| [`disable-consul.yml`](disable-consul.yml) | Removes `consul` instance group and `consul_agent` jobs and prevents the `auctioneer`, `ssh_proxy`, `file_server`, `rep`, `locket`, and `bbs` jobs from registering as a service with Consul | Requires `skip-consul-cell-registrations.yml`, `skip-consul-locks.yml`, and `use-bosh-dns.yml` |
| [`disable-consul-bosh-lite.yml`](disable-consul-bosh-lite.yml) | Compatibility shim for disabling Consul on BOSH-Lite. | Apply `disable-consul.yml`, `bosh-lite.yml`, and then `disable-consul-bosh-lite.yml`, in that order. |
| [`disable-consul-windows.yml`](disable-consul-windows.yml) | Removes `consul` job from `windows-cell` instance group and prevents the Windows cell rep from registering itself as a service with Consul | Requires `use-bosh-dns.yml` and `windows-cell.yml` |
| [`disable-consul-windows2016.yml`](disable-consul-windows2016.yml) | Removes `consul` job from `windows2016-cell` instance group and prevents the Windows 2016 cell rep from registering itself as a service with Consul | Requires `use-bosh-dns.yml` and `operations/windows2016-cell.yml` |
| [`disable-consul-service-registrations-locket.yml`](disable-consul-service-registrations-locket.yml) | This file is a no-op and should not be used, but kept for backward compatabilty. Please use `disable-consul.yml` instead. | Previously: Prevents the `locket` server from registering itself as a service with Consul |
| [`disable-consul-service-registrations-windows.yml`](disable-consul-service-registrations-windows.yml) | This file is a no-op and should not be used, but kept for backward compatabilty. Please use `disable-consul-windows.yml` instead. | Requires `windows-cell.yml` |
| [`disable-consul-service-registrations.yml`](disable-consul-service-registrations.yml) | This file is a no-op and should not be used, but kept for backward compatabilty. Please use `disable-consul.yml` instead. | Previously: Prevents the `auctioneer`, `ssh_proxy`, `file_server`, `rep`, `locket`, and `bbs` jobs from registering as a service with Consul |
| [`enable-backup-restore.yml`](enable-backup-restore.yml) | Deprecated, use equivalent file in `operations/backup-and-restore`. | |
| [`enable-backup-restore-credhub.yml`](enable-backup-restore-credhub.yml) | Deprecated, use equivalent file in `operations/backup-and-restore`.  | |
| [`enable-backup-restore-s3.yml`](enable-backup-restore-s3.yml) | Deprecated, use equivalent file in `operations/backup-and-restore`. | |
| [`enable-bits-service-consul.yml`](enable-bits-service-consul.yml) | Registers the bits-service [bits-service](https://github.com/cloudfoundry-incubator/bits-service) job via consul | Requires `bits-service.yml` from the same directory. |
| [`enable-bits-service-https.yml`](enable-bits-service-https.yml) | Deprecated and left intentionally blank - the bits service is now `https` only | |
| [`enable-bpm.yml`](enable-bpm.yml) | Enables the [BOSH Process Manager](https://github.com/cloudfoundry-incubator/bpm-release) for several BOSH jobs. | |
| [`enable-instance-identity-credentials.yml`](enable-instance-identity-credentials.yml) | Deprecated and left intentionally blank for backward compatibility. | Identity credentials are enabled in `cf-deployment.yml` by default. |
| [`enable-instance-identity-credentials-windows.yml`](enable-instance-identity-credentials-windows.yml) | Deprecated and left intentionally blank for backward compatibility. | Identity credentials for `windows2012R2` cells are enabled in `windows-cell.yml` ops file by default. |
| [`enable-instance-identity-credentials-windows2016.yml`](enable-instance-identity-credentials-windows2016.yml) | Enables identity credentials on the `rep_windows` for Windows 2016 cells. | Requires `operations/windows2016-cell.yml`|
| [`enable-iptables-logger.yml`](enable-iptables-logger.yml) | Enables iptables logger. | |
| [`enable-mysql-tls.yml`](enable-mysql-tls.yml) | Enables TLS on the database job | |
| [`enable-nfs-broker-backup.yml`](enable-nfs-broker-backup.yml) | Deprecated, use equivalent file in `operations/backup-and-restore` | |
| [`enable-oci-phase-1.yml`](enable-oci-phase-1.yml) | Configure Garden to create OCI compatible images. | |
| [`enable-prefer-declarative-healthchecks.yml`](enable-prefer-declarative-healthchecks.yml) | Deprecated and left intentionally blank for backward compatibility. | Preferring declarative healthchecks is enabled in `cf-deployment.yml` by default. | |
| [`enable-prefer-declarative-healthchecks-windows.yml`](enable-prefer-declarative-healthchecks-windows.yml) | Deprecated and left intentionally blank for backward compatibility. | Preferring declarative healthchecks for `windows2012R2` cells is enabled in `windows-cell.yml` ops file by default. | |
| [`enable-prefer-declarative-healthchecks-windows2016.yml`](enable-prefer-declarative-healthchecks-windows2016.yml) | Deprecated and left intentionally blank for backward compatibility. | Preferring declarative healthchecks for `windows2016` cells is enabled in `windows2016-cell.yml` ops file by default. | |
| [`enable-routing-integrity.yml`](enable-routing-integrity.yml) | Enables container proxy on the Diego Cell `rep` and configures gorouter to opt into TLS-enabled connections to the backend. | |
| [`enable-service-discovery.yml`](enable-service-discovery.yml) | Enables application service discovery | Requires bosh-dns-release >= 0.2.0, capi-release >= 1.47.0, and `use-bosh-dns-for-containers.yml` |
| [`enable-tls-cloud-controller-postgres.yml`](enable-tls-cloud-controller-postgres.yml) | Enables the usage of TLS to secure the connection between Cloud Controller and its Postgres database | Requires capi-release >= 1.41.0 and `use-postgres.yml` |
| [`enable-traffic-to-internal-networks.yml`](enable-traffic-to-internal-networks.yml) | Allows traffic from app containers to internal networks. Required to allow applications to communicate with the running CredHub in non-assisted mode. | |
| [`fast-deploy-with-downtime-and-danger.yml`](fast-deploy-with-downtime-and-danger.yml) | Risky, but fast. Disable canaries, increase the max number of vms bosh will update simultaneously, and remove `serial: true` from most instance groups to enable faster, but probably downtimeful, deploys. | |
| [`improve-diego-log-format.yml`](improve-diego-log-format.yml) | Enable human readable format for timestamp (rfc3339) and log level in linux component logs. | Incompatible with `bosh-lite.yml`, which enables this already. |
| [`improve-diego-log-format-windows.yml`](improve-diego-log-format-windows.yml) | Enable human readable format for timestamp (rfc3339) and log level in Windows 2012 component logs. | Requires `windows-cell.yml` |
| [`improve-diego-log-format-windows2016.yml`](improve-diego-log-format-windows2016.yml) | Enable human readable format for timestamp (rfc3339) and log level in Windows 2016 component logs. | Requires `windows2016-cell.yml` |
| [`migrate-cf-mysql-to-pxc.yml`](migrate-cf-mysql-to-pxc.yml) | Migrates from an existing cf-mysql database to [pxc-release](https://github.com/cloudfoundry-incubator/pxc-release). After the migration is complete, switch to the `use-pxc.yml` operations file. | |
| [`perm-service.yml`](perm-service.yml) | Deploy CF with [Perm Service](https://github.com/cloudfoundry-incubator/perm) | Requires `use-bosh-dns.yml` and `enable-mysql-tls.yml`. See the [deployment section of perm-release's README file](https://github.com/cloudfoundry-incubator/perm-release/blob/master/README.md#deploying-perm-with-cf-deployment) for more information|
| [`perm-service-with-pxc-release.yml`](perm-service-with-pxc-release.yml) | Use [pxc-release](https://github.com/cloudfoundry-incubator/pxc-release) as data store for Perm Service. | Requires `perm-service.yml` and `use-pxc.yml`. |
| [`rootless-containers.yml`](rootless-containers.yml) | Enable rootless garden-runc containers. | Requires garden-runc 1.9.5 or later and grootfs 0.27.0 or later. |
| [`secure-service-credentials.yml`](secure-service-credentials.yml) | Use CredHub for service credentials. | BOSH DNS is required if not using a credhub load balancer. You can add a credhub load balancer with `add-credhub-lb.yml`. |
| [`secure-service-credentials-windows-cell.yml`](secure-service-credentials-windows-cell.yml) | Adds CredHub TLS CA as a trusted cert to the Windows Cell. | Requires `secure-service-credentials.yml`. |
| [`secure-service-credentials-windows2016-cell.yml`](secure-service-credentials-windows2016-cell.yml) | Adds CredHub TLS CA as a trusted cert to the Windows 2016 Cell. | Requires `secure-service-credentials.yml`, `operations/windows2016-cell.yml` and `enable-instance-identity-credentials-windows2016.yml`. |
| [`secure-service-credentials-external-db.yml`](secure-service-credentials-external-db.yml) | Use external database for CredHub data store. | Requires `secure-service-credentials.yml` and `use-external-dbs.yml`. |
| [`secure-service-credentials-postgres.yml`](secure-service-credentials-postgres.yml) | Use local postgres database for CredHub data store. | Requires `secure-service-credentials.yml` and `use-postgres.yml`. |
| [`secure-service-credentials-with-pxc-release.yml`](secure-service-credentials-with-pxc-release.yml) | Use [pxc-release](https://github.com/cloudfoundry-incubator/pxc-release) for CredHub data store. | Requires `secure-service-credentials.yml` and `use-pxc.yml`. |
| [`skip-consul-cell-registrations.yml`](skip-consul-cell-registrations.yml) | Configure the BBS to only use Locket to find registered Diego cells | |
| [`skip-consul-locks.yml`](skip-consul-locks.yml) | Prevent several components from also attempting to claim a lock in Consul | |
| [`use-bosh-dns.yml`](use-bosh-dns.yml) | Adds `bosh-dns` job to all instance groups running ubuntu-trusty via Bosh Addon. | Aliases `service.cf.internal` domains to their `bosh-dns` equivalents. |
| [`use-bosh-dns-for-containers.yml`](use-bosh-dns-for-containers.yml) | Sets the DNS server of application containers to the address of the local `bosh-dns` job. | Requires `use-bosh-dns.yml` |
| [`use-bosh-dns-for-containers-with-silk-release.yml`](use-bosh-dns-for-containers-with-silk-release.yml) | Sets the DNS server of application containers to the address of the local `bosh-dns` job in case you are using silk-release plugin. | Requires `use-bosh-dns.yml` and `use-silk-release.yml` |
| [`use-bosh-dns-for-windows2016-containers.yml`](use-bosh-dns-for-windows2016-containers.yml) | Sets the DNS server of application containers (on windows2016 cell) to the address of the local `bosh-dns` job. | Requires `use-bosh-dns.yml` and `operations/windows2016-cell.yml` |
| [`use-bosh-dns-rename-network-and-deployment.yml`](use-bosh-dns-rename-network-and-deployment.yml) | Adds `bosh-dns` job to all instance groups running ubuntu-trusty via Bosh Addon, and renames network and deployment in domain aliases. | |
| [`use-cf-networking-2.yml`](use-cf-networking-2.yml) | Use `cf-networking` and `silk-cni` 2.x with `cf-deployment` 1.x. | |
| [`use-bosh-dns-for-containers-with-networking-2.yml`](use-bosh-dns-for-containers-with-networking-2.yml) | Sets the DNS server of application containers to the address of the local `bosh-dns` job when using cf-networking 2.x. | Requires `use-bosh-dns.yml` and `use-cf-networking-2.yml` |
| [`enable-iptables-logger-with-networking-2.yml`](enable-iptables-logger-with-networking-2.yml) | Enable iptables logger when using cf-networking 2.x. | Requires `use-cf-networking-2.yml` |
| [`use-external-dbs-with-networking-2.yml`](use-external-dbs-with-networking-2.yml) | Updates policy-server and silk-controller to use external dbs when using cf-networking 2.x. | Requires `use-external-dbs.yml` and `use-cf-networking-2.yml` |
| [`use-postgres-with-networking-2.yml`](use-postgres-with-networking-2.yml) | Updates policy-server and silk-controller to use postgres db when using cf-networking 2.x. | Requires `use-postgres.yml` and `use-cf-networking-2.yml` |
| [`use-garden-containerd.yml`](use-garden-containerd.yml) | Configure Garden to create containers via containerd. | |
| [`use-grootfs.yml`](use-grootfs.yml) | Groot is enabled by default. This file is blank to avoid breaking deployment scripts. | |
| [`use-log-cache.yml`](use-log-cache.yml) | Adds the [Log Cache Release](https://github.com/cloudfoundry/log-cache-release) for logs and metrics. | |
| [`use-pxc.yml`](use-pxc.yml) | Uses the [pxc-release](https://github.com/cloudfoundry-incubator/pxc-release) instead of the [cf-mysql-release](https://github.com/cloudfoundry/cf-mysql-release/) as the internal mysql database. This ops-file is for clean-installs of cf or for redeploying cf already running pxc. It's not for migrating from cf-mysql-release. | | 
| [`use-shed.yml`](use-shed.yml) | Enable deprecated garden-shed on diego cells. | |
| [`use-silk-release.yml`](use-silk-release.yml) | Use [Silk Release](https://github.com/cloudfoundry/silk-release) as the container networking plugin. |  |
| [`use-silk-release-external-db.yml`](use-silk-release-external-db.yml) | Use [Silk Release](https://github.com/cloudfoundry/silk-release) with an external database. | Requires `use-external-dbs.yml` and `use-silk-release.yml`. The required order is `use-external-dbs.yml`, `use-silk-release.yml`, and finally `use-silk-release-external-db.yml`|
| [`use-silk-release-postgres.yml`](use-silk-release-postgres.yml) | Use [Silk Release](https://github.com/cloudfoundry/silk-release) with postgres as its data store. | Requires `use-postgres.yml` and `use-silk-release.yml`.|
| [`use-latest-windows2016-stemcell.yml`](use-latest-windows2016-stemcell.yml) | **DEPRECATED** Please use `operations/use-latest-windows2016-stemcell.yml` instead. This file is kept as a symlink for backwards compatibility. | |
| [`use-offline-windows2016fs.yml`](use-offline-windows2016fs.yml) | **DEPRECATED** Please use `operations/use-offline-windows2016fs.yml` instead. This file is kept as a symlink for backwards compatibility. | |
| [`use-xenial-stemcell.yml`](use-xenial-stemcell.yml) | Use Ubuntu Xenial as the default stemcell | |
| [`windows-enable-component-syslog.yml`](windows-enable-component-syslog.yml) | Collocates a job from windows-syslog-release on all windows-based instances to forward job logs in syslog format. | Compatible with both `windows2016` and `windows2012R2` instances, even at the same time. Can also be applied to runtime config, in the manner of `operations/addons/enable-component-syslog.yml`. The operations in this file are intended to be merged into that one when they graduate from experimental status. This ops file gets all its variables from the same place as that one, though not all are used. |
| [`windows2016-cell.yml`](windows2016-cell.yml) | **DEPRECATED** Please use `operations/windows2016-cell.yml` instead. This file is kept as a symlink for backwards compatibility. |  |
