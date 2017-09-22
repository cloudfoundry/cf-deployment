# cf-deployment experimental operations
"Experimental" ops-files represent configurations
that we expect to promote to blessed configuration eventually,
meaning that,
once the configurations have been sufficiently validated,
they will become part of cf-deployment.yml
and the ops-files will be removed.

| Name | Purpose | Notes |
|:---  |:---     |:---   |
| [bits-service.yml](bits-service.yml) | Adds the [bits-service](https://github.com/cloudfoundry-incubator/bits-service) job and enables it in the cloud-controller. | Also requires one of `bits-service-{local,webdav,s3}.yml` from the same directory. |
| [bits-service-local.yml](bits-service-local.yml) | Use local storage for the [bits-service](https://github.com/cloudfoundry-incubator/bits-service). | |
| [bits-service-s3.yml](bits-service-s3.yml) | Use s3 storage for the [bits-service](https://github.com/cloudfoundry-incubator/bits-service). | `use-s3-blobstore.yml` from the root `operations` directory is also required. |
| [bits-service-webdav.yml](bits-service-webdav.yml) | Use the `blobstore`'s webdav storage for the [bits-service](https://github.com/cloudfoundry-incubator/bits-service). | Requires the `blobstore` job. |
| [deploy-bosh-backup-restore.yml](deploy-bosh-backup-restore.yml) | Deploy BOSH backup and restore instance. | |
| [disable-consul-service-registrations-locket.yml](disable-consul-service-registrations-locket.yml) | Prevents the `locket` server from registering itself as a service with Consul | Requires `enable-locket.yml` |
| [disable-consul-service-registrations-windows.yml](disable-consul-service-registrations-windows.yml) | Prevents the Windows Cell `rep` from registering itself as a service with Consul | Requires `enable-locket.yml` and `windows-cell.yml` |
| [disable-consul-service-registrations.yml](disable-consul-service-registrations.yml) | Prevents the `auctioneer`, `ssh_proxy`, `file_server`, `rep`, and `bbs` jobs from registering as a service with Consul | Requires `enable-locket.yml` |
| [disable-etcd.yml](disable-etcd.yml) | Removes the `etcd` instance group and disables `loggregator` components from using it. | |
| [enable-container-proxy.yml](enable-container-proxy.yml) | Removes the `etcd` instance group and disables `loggregator` components from using it. | |
