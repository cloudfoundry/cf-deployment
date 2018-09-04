# cf-deployment Experimental Ops-files

This is the README for Experimental Ops-files. To learn more about `cf-deployment`, go to the main [README](../../README.md).

- For General Ops-files, check out the [Ops-file README](../README.md).
- For Addons Ops-files that can be applied to manifests or runtime configs, check out the [Addons Ops-file README](../addons/README.md).
- For Backup and Restore Ops-files (for configuring your deployment for use with [BBR](https://github.com/cloudfoundry-incubator/bosh-backup-and-restore)), checkout the [Backup and Restore Ops-files README](../backup-and-restore/README.md).
- For Bits Service Ops-files (for configuring your deployment for use with [Bits Service](https://github.com/cloudfoundry-incubator/bits-service)), checkout the [Bits Service Ops-files README](../bits-service/README.md).
- For Community Ops-files, check out the [Community Ops-file README](../community/README.md).
- For Legacy Ops-files, checkout the [Legacy Ops-file README](../legacy/README.md).

"Experimental" ops-files represent configurations
that we expect to promote to blessed configuration eventually,
meaning that,
once the configurations have been sufficiently validated,
they will become part of cf-deployment.yml
and the ops-files will be removed.

| Name | Purpose | Notes |
|:---  |:---     |:---   |
| [`add-credhub-lb.yml`](add-credhub-lb.yml) | Use load balancer to expose external address for CredHub. | |
| [`add-deployment-updater.yml`](add-deployment-updater.yml) | Add `cc_deployment_updater` job to `scheduler` vm, which enables zero downtime app deployments. | |
| [`add-deployment-updater-external-db.yml`](add-deployment-updater-external-db.yml) | Use an external database for the `cc_deployment_updater` job. | Requires `add-deployment-updater.yml` and `use-external-dbs.yml` |
| [`add-deployment-updater-postgres.yml`](add-deployment-updater-postgres.yml) | Use a postgres database for the `cc_deployment_updater` job. | Requires `add-deployment-updater.yml` |
| [`add-cflinuxfs3.yml`](add-cflinuxfs3.yml) | Add the cflinuxfs3 [stack](https://docs.cloudfoundry.org/devguide/deploy-apps/stacks.html) and buildpacks | Use this opsfile for testing component and app compatibility with cflinuxfs3 in advance of changing the default rootfs. |
| [`bits-service.yml`](bits-service.yml) | **DEPRECATED: Promoted to `operations/bits-service/use-bits-service.yml` and will be removed in the next major release** Adds the [bits-service](https://github.com/cloudfoundry-incubator/bits-service) job and enables it in the cloud-controller. | Also requires one of `bits-service-{local,webdav,s3}.yml` from the same directory. |
| [`bits-service-local.yml`](bits-service-local.yml) | **DEPRECATED: `cf-deployment` doesn't support local NFS storage. This file will be removed in the next major release** Use local storage for the [bits-service](https://github.com/cloudfoundry-incubator/bits-service). | |
| [`bits-service-s3.yml`](bits-service-s3.yml) | **DEPRECATED: Promoted to `operations/bits-service/configure-bits-service-s3.yml` and will be removed in the next major release** Use s3 storage for the [bits-service](https://github.com/cloudfoundry-incubator/bits-service). | `use-s3-blobstore.yml` from the root `operations` directory is also required. |
| [`bits-service-webdav.yml`](bits-service-webdav.yml) | **DEPRECATED: Inlined into `operations/bits-service/use-bits-service.yml` and will be removed in the next major release** Use the `blobstore`'s webdav storage for the [bits-service](https://github.com/cloudfoundry-incubator/bits-service). | Requires the `blobstore` job. |
| [`disable-interpolate-service-bindings.yml`](disable-interpolate-service-bindings.yml) | Disables the interpolation of CredHub service credentials by Cloud Controller. |
| [`disable-consul.yml`](disable-consul.yml) | **DEPRECATED: Consul has been removed from cf-deployment** Removes `consul` instance group and `consul_agent` jobs and prevents the `auctioneer`, `ssh_proxy`, `file_server`, `rep`, `locket`, and `bbs` jobs from registering as a service with Consul | |
| [`disable-consul-bosh-lite.yml`](disable-consul-bosh-lite.yml) | **DEPRECATED: Consul has been removed from cf-deployment** Consul has been removed. Compatibility shim for disabling Consul on BOSH-Lite. | Apply `disable-consul.yml`, `bosh-lite.yml`, and then `disable-consul-bosh-lite.yml`, in that order. |
| [`disable-consul-windows.yml`](disable-consul-windows.yml) | **DEPRECATED: Consul has been removed from cf-deployment** Removes `consul` job from `windows-cell` instance group and prevents the Windows cell rep from registering itself as a service with Consul | Requires `windows-cell.yml` |
| [`disable-consul-windows2016.yml`](disable-consul-windows2016.yml) | **DEPRECATED: Consul has been removed from cf-deployment** Consul has been removed. Removes `consul` job from `windows2016-cell` instance group and prevents the Windows 2016 cell rep from registering itself as a service with Consul | Requires `windows2016-cell.yml` |
| [`disable-consul-windows1803.yml`](disable-consul-windows1803.yml) | **DEPRECATED: Consul has been removed from cf-deployment** Consul has been removed. Removes `consul` job from `windows1803-cell` instance group and prevents the Windows 2016 cell rep from registering itself as a service with Consul | Requires `windows1803-cell.yml` |
| [`enable-bits-service-consul.yml`](enable-bits-service-consul.yml) | **DEPRECATED: Consul has been removed from cf-deployment** Consul has been removed. Registers the bits-service [bits-service](https://github.com/cloudfoundry-incubator/bits-service) job via consul | Requires `bits-service.yml` from the same directory. |
| [`enable-bpm-garden.yml`](enable-bpm-garden.yml) | Enables the [BOSH Process Manager](https://github.com/cloudfoundry-incubator/bpm-release) for Garden. This ops file cannot be deployed in conjunction with `use-garden-containerd.yml` | |
| [`use-create-swap-delete-vm-strategy.yml`](use-create-swap-delete-vm-strategy.yml) | Configures the default [`vm_strategy`](https://bosh.io/docs/changing-deployment-vm-strategy/) to be `create-swap-delete`. | Requires BOSH director `v267.7+` |
| [`enable-iptables-logger.yml`](enable-iptables-logger.yml) | Enables iptables logger. | |
| [`enable-mysql-tls.yml`](enable-mysql-tls.yml) | Enables TLS on the database job, and secures all client database connections. | |
| [`enable-nfs-volume-service-credhub.yml`](enable-nfs-volume-service-credhub.yml) | Enables credhub integration for NFS volume services | Requires `enable-nfs-volume-service.yml` |
| [`enable-oci-phase-1.yml`](enable-oci-phase-1.yml) | Configure Garden to create OCI compatible images. | |
| [`enable-routing-integrity.yml`](enable-routing-integrity.yml) | Enables container proxy on the Diego Cell `rep` and configures gorouter to opt into TLS-enabled connections to the backend. | |
| [`enable-smb-volume-service.yml`](enable-smb-volume-service.yml) | Enables volume support and deploys an SMB broker and volume driver | As of cf-deployment v2, you must use the `azurefilebrokerpush` errand to cf push the smb broker after `bosh deploy` completes. |
| [`enable-suspect-actual-lrp-generation.yml`](enable-suspect-actual-lrp-generation.yml) | Configures BBS to create ActualLRPs in a new "Suspect" state. You can find more in-depth information [here](https://docs.google.com/document/d/19880DjH4nJKzsDP8BT09m28jBlFfSiVx64skbvilbnA/view) | |
| [`enable-tls-cloud-controller-postgres.yml`](enable-tls-cloud-controller-postgres.yml) | Enables the usage of TLS to secure the connection between Cloud Controller and its Postgres database | Requires capi-release >= 1.41.0 and `use-postgres.yml` |
| [`enable-traffic-to-internal-networks.yml`](enable-traffic-to-internal-networks.yml) | Allows traffic from app containers to internal networks. Required to allow applications to communicate with the running CredHub in non-assisted mode. | |
| [`perm-service-with-tcp-routing.yml`](perm-service-with-tcp-routing.yml) | Adds a tcp route to perm in its own perm tcp router group. | Requires `perm-service.yml` |
| [`fast-deploy-with-downtime-and-danger.yml`](fast-deploy-with-downtime-and-danger.yml) | Risky, but fast. Disable canaries, increase the max number of vms bosh will update simultaneously, and remove `serial: true` from most instance groups to enable faster, but probably downtimeful, deploys. | |
| [`infrastructure-metrics.yml`](infrastructure-metrics.yml) | Add the Prometheus node exporter and Loggregator Prom Scraper to addons. This puts infrastructure metrics into Loggregator's metric stream. | |
| [`migrate-cf-mysql-to-pxc.yml`](migrate-cf-mysql-to-pxc.yml) | **DEPRECATED: use `../migrate-cf-mysql-to-pxc.yml`** | |
| [`migrate-nfsbroker-mysql-to-credhub.yml`](migrate-nfsbroker-mysql-to-credhub.yml) | Migrates existing NFS volume services state storage from MySQL to Credhub | Requires `enable-nfs-volume-service-credhub.yml` |
| [`perm-service.yml`](perm-service.yml) | Deploy CF with [Perm Service](https://github.com/cloudfoundry-incubator/perm) | Requires `enable-mysql-tls.yml`. See the [deployment section of perm-release's README file](https://github.com/cloudfoundry-incubator/perm-release/blob/master/README.md#deploying-perm-with-cf-deployment) for more information|
| [`perm-service-with-pxc-release.yml`](perm-service-with-pxc-release.yml) | Use [pxc-release](https://github.com/cloudfoundry-incubator/pxc-release) as data store for Perm Service. | Requires `perm-service.yml` and `use-pxc.yml`. |
| [`rootless-containers.yml`](rootless-containers.yml) | Enable rootless garden-runc containers. | Requires garden-runc 1.9.5 or later and grootfs 0.27.0 or later. This ops file cannot be deployed in conjunction with `use-garden-containerd.yml` |
| [`set-cpu-weight.yml`](set-cpu-weight.yml) | CPU shares for each garden container are proportional to its memory limits. | |
| [`use-compiled-releases-xenial-stemcell.yml`](use-compiled-releases-xenial-stemcell.yml) | **DEPRECATED: Xenial is now the default stemcell in cf-deployment**  Use releases compiled for Xenial stemcell, as opposed to Trusty | Requires `use-xenial-stemcell.yml` |
| [`use-compiled-releases-windows.yml`](use-compiled-releases-windows.yml) | Reverts to source version of releases required for Windows cells | Intended for use with `use-compiled-releases.yml` and any of `windows*-cell.yml` |
| [`use-garden-containerd.yml`](use-garden-containerd.yml) | Configure Garden to create containers via containerd. This ops file cannot be deployed in conjunction with either `rootless-containers.yml` or `enable-bpm-garden.yml`. | |
| [`use-latest-windows1803-stemcell.yml`](use-latest-windows1803-stemcell.yml) | Use the latest `windows1803` stemcell available on your BOSH director instead of the one in `windows1803-cell.yml` | Requires `windows1803-cell.yml` |
| [`use-logcache-for-cloud-controller-app-stats.yml`](use-logcache-for-cloud-controller-app-stats.yml) | Configure Cloud Controller to use Log Cache instead of Traffic Controller for app container metrics. | |
| [`use-pxc.yml`](use-pxc.yml) | **DEPRECATED: use `../use-pxc.yml`**| |
| [`use-pxc-for-smb-volume-service.yml`](use-pxc-for-smb-volume-service.yml) | Use [pxc-release](https://github.com/cloudfoundry-incubator/pxc-release) as data store for SMB volume services. | Requires `enable-smb-volume-service.yml` and `use-pxc.yml`. |
| [`use-xenial-stemcell.yml`](use-xenial-stemcell.yml) | **DEPRECATED: Xenial is now the default stemcell in cf-deployment** Use Ubuntu Xenial as the default stemcell. | |
| [`windows1803-cell.yml`](windows1803-cell.yml) | Deploys a windows1803 cell. | Requires that a windows1803 stemcell and fs release are uploaded to the Bosh director. **CAUTION:** Incompatible with `windows2016-cell.yml`. |
| [`windows-component-syslog-ca.yml`](windows-component-syslog-ca.yml) | Forces windows component syslog to respect only the provided CA for cert validation. | Requires `windows-enable-component-syslog.yml`. Can also be applied to runtime config, in the manner of the `component-syslog-custom-ca.yml` addon. The operations in this file are intended to be merged into that one when they graduate from experimental status. This ops file gets all its variables from the same place as that one, though not all are used. |
| [`windows-enable-component-syslog.yml`](windows-enable-component-syslog.yml) | Collocates a job from windows-syslog-release on all windows-based instances to forward job logs in syslog format. | Compatible with both `windows2016` and `windows2012R2` instances, even at the same time. Can also be applied to runtime config, in the manner of the `enable-component-syslog.yml` addon. The operations in this file are intended to be merged into that one when they graduate from experimental status. This ops file gets all its variables from the same place as that one, though not all are used. |
