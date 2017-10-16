# cf-deployment Experimental Ops-files

This is the README for Experimental Ops-files. To learn more about `cf-deployment`, go to the main [README](../README.md). 

- For general Ops-files, check out the [Ops-file README](../README.md).
- For Legacy Ops-files, check out the [Legacy Ops-file README](../legacy/README.md).
- For Community Ops-files, checkout the [Community Ops-file README](../community/README.md).

"Experimental" ops-files represent configurations
that we expect to promote to blessed configuration eventually,
meaning that,
once the configurations have been sufficiently validated,
they will become part of cf-deployment.yml
and the ops-files will be removed.

| Name | Purpose | Notes |
|:---  |:---     |:---   |
| [`bits-service.yml`](bits-service.yml) | Adds the [bits-service](https://github.com/cloudfoundry-incubator/bits-service) job and enables it in the cloud-controller. | Also requires one of `bits-service-{local,webdav,s3}.yml` from the same directory. |
| [`bits-service-local.yml`](bits-service-local.yml) | Use local storage for the [bits-service](https://github.com/cloudfoundry-incubator/bits-service). | |
| [`bits-service-s3.yml`](bits-service-s3.yml) | Use s3 storage for the [bits-service](https://github.com/cloudfoundry-incubator/bits-service). | `use-s3-blobstore.yml` from the root `operations` directory is also required. |
| [`bits-service-webdav.yml`](bits-service-webdav.yml) | Use the `blobstore`'s webdav storage for the [bits-service](https://github.com/cloudfoundry-incubator/bits-service). | Requires the `blobstore` job. |
| [`enable-bpm.yml`](enable-bpm.yml) | Enables the [BOSH Process Manager](https://github.com/cloudfoundry-incubator/bpm-release) as a BOSH addon. | |
| [`disable-consul.yml`](disable-consul.yml) | Removes `consul` jobs and instance_group | |
| [`disable-consul-windows.yml`](disable-consul-windows.yml) | Removes `consul` job from `windows-cell` instance_group | |
| [`disable-consul-service-registrations-locket.yml`](disable-consul-service-registrations-locket.yml) | Prevents the `locket` server from registering itself as a service with Consul | |
| [`disable-consul-service-registrations-windows.yml`](disable-consul-service-registrations-windows.yml) | Prevents the Windows Cell `rep` from registering itself as a service with Consul | Requires `windows-cell.yml` |
| [`disable-consul-service-registrations.yml`](disable-consul-service-registrations.yml) | Prevents the `auctioneer`, `ssh_proxy`, `file_server`, `rep`, and `bbs` jobs from registering as a service with Consul | |
| [`enable-backup-restore.yml`](enable-backup-restore.yml) | Deploy BOSH backup and restore instance and enable release level backup. | |
| [`enable-container-proxy.yml`](enable-container-proxy.yml) | Enables container proxy on the Diego Cell `rep`. | Generates a templating error during deployment if [instance identity credentials](enable-instance-identity-credentials.yml) are not set. |
| [`enable-instance-identity-credentials.yml`](enable-instance-identity-credentials.yml) | Enables identity credentials on Diego Cell `rep`. | |
| [`enable-instance-identity-credentials-windows.yml`](enable-instance-identity-credentials-windows.yml) | Enables identity credentials on the `rep` for Windows 2012 cells. | Requires `enable-instance-identity-credentials.yml` and `windows-cell.yml`|
| [`enable-iptables-logger.yml`](enable-iptables-logger.yml) | Enables iptables logger. | |
| [`enable-prefer-declarative-healthchecks.yml`](enable-prefer-declarative-healthchecks.yml) | Configure the Rep on the diego cells to prefer LRP CheckDefinition (a.k.a declarative healthchecks) over the old Monitor action | |
| [`enable-prefer-declarative-healthchecks-windows.yml`](enable-prefer-declarative-healthchecks-windows.yml) | Configure the Rep on the windows 2012 cells to prefer LRP CheckDefinition (a.k.a declarative healthchecks) over the old Monitor action | |
| [`enable-prefer-declarative-healthchecks-windows2016.yml`](enable-prefer-declarative-healthchecks-windows2016.yml) | Configure the Rep on the windows 2016 cells to prefer LRP CheckDefinition (a.k.a declarative healthchecks) over the old Monitor action | |
| [`secure-service-credentials.yml`](secure-service-credentials.yml) | Use CredHub for service credentials. | Requires `enable-instance-identity-credentials.yml`. |
| [`secure-service-credentials-add-load-balancer.yml`](secure-service-credentials-add-load-balancer.yml) | Use load balancer to expose external address for CredHub. | Requires `secure-service-credentials.yml`. |
| [`secure-service-credentials-external-db.yml`](secure-service-credentials-external-db.yml) | Use external database for CredHub data store. | Requires `secure-service-credentials.yml` and `use-external-dbs.yml`. |
| [`secure-service-credentials-postgres.yml`](secure-service-credentials-postgres.yml) | Use local postgres database for CredHub data store. | Requires `secure-service-credentials.yml` and `use-postgres.yml`. |
| [`skip-consul-cell-registrations.yml`](skip-consul-cell-registrations.yml) | Configure the BBS to only use locket to find cells in the deployment | |
| [`skip-consul-locks.yml`](skip-consul-locks.yml) | Don't use consul locks in several jobs. | |
| [`use-bosh-dns.yml`](use-bosh-dns.yml) | Adds `bosh-dns` job to all instance groups running ubuntu-trusty via Bosh Addon. | Aliases `service.cf.internal` urls to their `bosh-dns` equivalents. |
| [`use-bosh-dns-for-containers.yml`](use-bosh-dns-for-containers.yml) | Sets the DNS server of application containers to the address of the local `bosh-dns` job. | Requires `use-bosh-dns.yml` |
| [`use-grootfs.yml`](use-grootfs.yml) | Enable grootfs on diego cells. | |
| [`use-latest-windows2016-stemcell.yml`](use-latest-windows2016-stemcell.yml) | Use the latest `windows2016` stemcell available on your BOSH director instead of the one in `windows2016-cell.yml` | Requires `windows2016-cell.yml` |
| [`windows2016-cell.yml`](windows2016-cell.yml) | Deploys a windows 2016 diego cell, adds releases necessary for windows. |  |
