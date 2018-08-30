# Ops-files

This is the README for Ops-files. To learn more about `cf-deployment`, go to the main [README](../README.md).

- For experimental Ops-files, check out the [Experimental Ops-file README](experimental/README.md).
- For Community Ops-files, checkout the [Community Ops-file README](community/README.md).
- For Legacy Ops-files, check out the [Legacy Ops-file README](legacy/README.md).
- For Addons Ops-files that can be applied to manifests or runtime configs, check out the [Addons Ops-file README](addons/README.md).
- For Backup and Restore Ops-files (for configuring your deployment for use with [BBR](https://github.com/cloudfoundry-incubator/bosh-backup-and-restore)), checkout the [Backup and Restore Ops-files README](backup-and-restore/README.md).

## IaaS-required Ops-files

| Name | Purpose | Notes |
|:---  |:---     |:---   |
| **Alibaba Cloud** | | |
| [`use-alicloud-oss-blobstore.yml`](use-alicloud-oss-blobstore.yml) | Configures external blobstore to use Alibaba Cloud OSS blobstore. | Requires `use-external-blobstore.yml`. Introduces [new variables](example-vars-files/vars-use-alicloud-oss-blobstore.yml) for oss credentials and bucket names. |
| **AWS** | | |
| [`aws.yml`](aws.yml) | Overrides the loggregator endpoint port to 4443. | It is required to have a separate port from the standard HTTPS port (443) for loggregator traffic in order to use "classic" AWS ELBs. Newer Application Load Balancers should not require this port override, so no need to use this ops-file if you're using the newer load balancer. |
| [`use-s3-blobstore.yml`](use-s3-blobstore.yml) | Configures external blobstore to use Amazon S3. | Requires `use-external-blobstore.yml`. Introduces [new variables](example-vars-files/vars-use-s3-blobstore.yml) for s3 credentials and bucket names. |
| **Azure** | | |
| [`azure.yml`](azure.yml) | Sets gorouter's `frontend_idle_timeout` to value appropriate for Azure load balancers. | Any value below 240 should work. |
| [`use-azure-storage-blobstore.yml`](use-azure-storage-blobstore.yml) | Configures external blobstore to use Azure Storage. | Requires `use-external-blobstore.yml`. Introduces [new variables](example-vars-files/vars-use-azure-storage-blobstore.yml) for Azure credentials and container names. |
| **GCP** | | |
| [`use-gcs-blobstore-service-account.yml`](use-gcs-blobstore-service-account.yml) | Enables service account credentials for Google blobstore. | Requires `use-external-blobstore.yml`. Introduces [new variables](example-vars-files/vars-use-gcs-blobstore-service-account.yml) for gcp service account email/json-key and bucket names. |
| [`use-gcs-blobstore-access-key.yml`](use-gcs-blobstore-access-key.yml) | Enables access key credentials for Google blobstore. | Requires `use-external-blobstore.yml`. Introduces [new variables](example-vars-files/vars-use-gcs-blobstore-access-key.yml) for access key/secret and bucket names. |
| **Openstack** | | |
| [`openstack.yml`](openstack.yml) | Used for deploying Cloud Foundry on OpenStack with BOSH | See [OpenStack](../iaas-support/openstack/README.md) documentation. |
| [`use-swift-blobstore.yml`](use-swift-blobstore.yml) | Replaces local WebDAV blobstore with OpenStack swift blobstore. Used for deploying Cloud Foundry on OpenStack with BOSH | Requires `use-external-blobstore.yml`. Introduces [new variables](example-vars-files/vars-use-swift-blobstore.yml) for OpenStack credentials and directory names. If you plan using the [Swift ops file](use-swift-blobstore.yml) to enable Swift as blobstore for the Cloud Controller, you should also run the [Swift extension](https://github.com/cloudfoundry-incubator/cf-openstack-validator/tree/master/extensions/object_storage). |


## Feature-based Ops-files

| Name | Purpose | Notes |
|:---  |:---     |:---   |
| [`bosh-lite.yml`](bosh-lite.yml) | Enables `cf-deployment` to be deployed on `bosh-lite`. | See [bosh-lite](../iaas-support/bosh-lite/README.md) documentation. |
| [`cf-syslog-skip-cert-verify.yml`](cf-syslog-skip-cert-verify.yml) | This disables TLS verification when connecting to a HTTPS syslog drain. | |
| [`configure-confab-timeout.yml`](configure-confab-timeout.yml) | Allows deployer to configure `consul_agent` Confab startup timeout on `consul` instances. | Adds new variable `confab_timeout` in seconds, must be at least 60. |
| [`configure-default-router-group.yml`](configure-default-router-group.yml) | Allows deployer to configure reservable ports for default tcp router group by passing variable `default_router_group_reservable_ports`. |  |
| [`disable-log-cache.yml`](disable-log-cache.yml) | Removes Log Cache and associated jobs from doppler VMs. |  |
| [`disable-router-tls-termination.yml`](disable-router-tls-termination.yml) | Eliminates keys related to performing TLS termination within the gorouter job. | Useful for deployments where TLS termination is performed prior to the gorouter - for instance, on AWS, such termination is commonly done at the ELB. This also eliminates the need to specify `((router_ssl.certificate))` and `((router_ssl.private_key))` in the var files. |
| [`enable-cc-rate-limiting.yml`](enable-cc-rate-limiting.yml) | Enable rate limiting for UAA-authenticated endpoints. | Introduces variables `cc_rate_limiter_general_limit` and `cc_rate_limiter_unauthenticated_limit` |
| [`enable-nfs-ldap.yml`](enable-nfs-ldap.yml) | Enables LDAP authentication for NFS volume services | Requires `enable-nfs-volume-service.yml`. Introduces [new variables](example-vars-files/vars-enable-nfs-ldap.yml) |
| [`enable-nfs-volume-service.yml`](enable-nfs-volume-service.yml) | Enables volume support and deploys an NFS broker and volume driver | As of cf-deployment v2, you must use the `nfsbrokerpush` errand to cf push the nfs broker after `bosh deploy` completes. |
| [`enable-privileged-container-support.yml`](enable-privileged-container-support.yml) | Enables Diego privileged container support. | |
| [`enable-service-discovery.yml`](enable-service-discovery.yml) | Enables application service discovery | |
| [`enable-uniq-consul-node-name.yml`](enable-uniq-consul-node-name.yml) | Configure Diego cell `consul_agent` jobs to have a unique id per instance. |  |
| [`override-app-domains.yml`](override-app-domains.yml) | Switches from using the system domain as a shared app domain; allows the configuration of one or more shared app domains instead. | Adds [new variables](example-vars-files/vars-override-app-domains.yml).<br/> **CAUTION:** Seeding domains with a router group name (including TCP domains) may cause problems deploying. Please use the `cf` CLI to add shared domains with router group names. |
| [`rename-network-and-deployment.yml`](rename-network-and-deployment.yml) | Allows a deployer to rename the network and deployment by passing a variables `network_name` and `deployment_name` | **CAUTION:** If you are using this ops file along  with another ops file that increases the number of instance groups (e.g. `windows-cell.yml` or `perm-services.yml`), this ops file will not rename the network for those instance groups. |
| [`scale-database-cluster.yml`](scale-database-cluster.yml) | Scales cf-deployment database to 3 nodes across 3 zones (z1, z2, z3). | Cannot be used with postgres as it will not scale. |
| [`scale-to-one-az.yml`](scale-to-one-az.yml) | Scales cf-deployment down to a single instance per instance group, placing them all into a single AZ. | Effectively halves the deployment's footprint. Should be applied before other ops files. |
| [`set-bbs-active-key.yml`](set-bbs-active-key.yml) | Allows a deployer to set the `bbs` active key label by passing a variable `diego_bbs_active_key_label` |  |
| [`set-router-static-ips.yml`](set-router-static-ips.yml) | Allows a deployer to set the static IPs for the `router` VMs by passing a variable `router_static_ips` | `router_static_ips` variable must be provided as a compacted YAML array, e.g. `-v router_static_ips=[10.0.16.4,10.0.47.5]` |
| [`stop-skipping-tls-validation.yml`](stop-skipping-tls-validation.yml) | Enforces `TLS` validation for all components which skip it in the base `cf-deployment.yml` manifest. | See the base [README](../README.md#tls) for details. |
| [`use-blobstore-cdn.yml`](use-blobstore-cdn.yml) | Adds support for accessing the `droplets` and `resource_pool` blobstore buckets via signed urls over a cdn. | This assumes that you are using the same keypair for both buckets. Introduces [new variables](example-vars-files/vars-use-blobstore-cdn.yml) |
| [`use-compiled-releases.yml`](use-compiled-releases.yml) | Instead of having your BOSH Director compile each release, use this ops-file to use pre-compiled releases for a deployment speed improvement. | These releases are compiled against a specific stemcell version that is listed in the opsfile.  Note that no Windows releases are currently compiled. |
| [`use-external-blobstore.yml`](use-external-blobstore.yml) | Removes the singleton-blobstore instance group, and adds `fog_connection` properties for components that use the blobstore. **Warning**: this does not migrate data, and will delete any existing singleton-blobstore groups. | This requires an external data store. Introduces [new variables](example-vars-files/vars-use-external-blobstore.yml) for blobstore connection details which will need to be provided at deploy time. |
| [`use-external-dbs.yml`](use-external-dbs.yml) | Removes the MySQL instance group, cf-mysql release, and all cf-mysql variables. **Warning**: this does not migrate data, and will delete existing database instance groups. | This requires an external data store.   Introduces [new variables](example-vars-files/vars-use-external-dbs.yml) for DB connection details which will need to be provided at deploy time. This must be applied _before_ any ops files that removes jobs that use a database, such as the ops file to remove the routing API. |
| [`use-haproxy.yml`](use-haproxy.yml) | Deploys a single haproxy instance to be used as a load balancer. | This opsfile doesn't depend on use of an IaaS VIP and doesn't use `keepalived` property of the [haproxy-boshrelease](https://github.com/cloudfoundry-incubator/haproxy-boshrelease). |
| [`use-haproxy-public-network.yml`](use-haproxy-public-network.yml) | Puts haproxy instance on a public network with a static IP assigned to it. | Requires `use-haproxy.yml`. This ops file also requires your BOSH cloud-config to have a `vm_extension` called `cf-haproxy-network-properties`, which configures firewall rules to allow public traffic on the necessary ports (You will need to allow at least the default HTTP and HTTPS ports (`80` and `443`), port `4443` for `doppler`, as well as the [port range configured for the TCP Routing](https://github.com/cloudfoundry/cf-deployment/blob/a6983a1b3345cd9f5af0f26d5c10265de0c7851f/cf-deployment.yml#L726)). |
| [`use-latest-stemcell.yml`](use-latest-stemcell.yml) | Use the latest stemcell available on your BOSH director instead of the one in `cf-deployment.yml`. **Caution**: This ops-file should not be used in conjunction with `use-compiled-releases.yml`, since the latter relies on a specific stemcell version being used. |  |
| [`use-latest-windows-stemcell.yml`](use-latest-windows-stemcell.yml) | Use the latest `windows2012R2` stemcell available on your BOSH director instead of the one in `windows-cell.yml` | Requires `windows-cell.yml` |
| [`use-postgres.yml`](use-postgres.yml) | Replaces the MySQL instance group with a postgres instance group. **Warning**: this will lead to total data loss if applied to an existing deployment with MySQL or removed from an existing deployment with postgres. |  |
| [`use-trusted-ca-cert-for-apps.yml`](use-trusted-ca-cert-for-apps.yml) | Injects the CA specified with `trusted_cert_for_apps` into the Diego trusted store | This store determines which CAs will be trusted in the app environment. |
| [`windows-cell.yml`](windows-cell.yml) | Deploys a Windows 2012R2 Diego cell and adds releases necessary for Windows. | **Known issue**: Windows cells deployed to AWS will likely have their disks fill up after ~9 days (depending on load). The bosh-windows team is actively working on a fix for this. Operators who want to deploy windows cells to AWS anyway may want to recreate those cells periodically.  |
| [`use-latest-windows2016-stemcell.yml`](use-latest-windows2016-stemcell.yml) | Use the latest `windows2016` stemcell available on your BOSH director instead of the one in `windows2016-cell.yml` | Requires `windows2016-cell.yml` |
| [`use-offline-windows2016fs.yml`](use-offline-windows2016fs.yml) | Use the offline version of [windows2016fs-release](https://github.com/cloudfoundry-incubator/windows2016fs-release) | Requires `windows2016-cell.yml`. Suitable for environments without internet access. Follow instructions [here](https://github.com/cloudfoundry-incubator/windows2016fs-release/blob/master/README.md) to upload the release prior to deploying. |
| [`windows2016-cell.yml`](windows2016-cell.yml) | Deploys a windows 2016 diego cell, adds releases necessary for windows. | Windows2016 stemcell is currently only supported on GCP and Azure. AWS support is currently under development. |
