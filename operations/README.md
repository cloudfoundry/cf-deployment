# Ops-files

This is the README for Ops-files. To learn more about `cf-deployment`, go to the main [README](../README.md). 

- For experimental Ops-files, check out the [Experimental Ops-file README](experimental/README.md).
- For Community Ops-files, checkout the [Community Ops-file README](community/README.md).
- For Legacy Ops-files, check out the [Legacy Ops-file README](legacy/README.md).

## IaaS-required Ops-files

| Name | Purpose | Notes |
|:---  |:---     |:---   |
| **AWS** | | |
| [`use-s3-blobstore.yml`](use-s3-blobstore.yml) | Replaces local WebDAV blobstore with external s3 blobstore. | Introduces [new variables](example-vars-files/vars-use-s3-blobstore.yml) for s3 credentials and bucket names. |
| **Azure** | | |
| [`azure.yml`](azure.yml) | Sets gorouter's `frontend_idle_timeout` to value appropriate for Azure load balancers. | Any value below 240 should work. |
| [`use-azure-storage-blobstore.yml`](use-azure-storage-blobstore.yml) | Replaces local WebDAV blobstore with external Azure Storage blobstore. | Introduces [new variables](example-vars-files/vars-use-azure-storage-blobstore.yml) for Azure credentials and container names. |
| **Openstack** | | |
| [`openstack.yml`](openstack.yml) | Used for deploying Cloud Foundry on OpenStack with BOSH | |
| [`use-swift-blobstore.yml`](use-swift-blobstore.yml) | Used for deploying Cloud Foundry on OpenStack with BOSH | If you plan using the [Swift ops file](use-swift-blobstore.yml) to enable Swift as blobstore for the Cloud Controller, you should also run the [Swift extension](https://github.com/cloudfoundry-incubator/cf-openstack-validator/tree/master/extensions/object_storage). |


## Feature-based Ops-files

| Name | Purpose | Notes |
|:---  |:---     |:---   |
| [`bosh-lite.yml`](bosh-lite.yml) | Enables `cf-deployment` to be deployed on `bosh-lite`. | See [bosh-lite](../iaas-support/bosh-lite/README.md) documentation. |
| [`cf-syslog-skip-cert-verify.yml`](cf-syslog-skip-cert-verify.yml) | This disables TLS verification when connecting to a HTTPS syslog drain. | |
| [`configure-default-router-group.yml`](configure-default-router-group.yml) | Allows deployer to configure reservable ports for default tcp router group by passing variable `default_router_group_reservable_ports`. |  |
| [`disable-router-tls-termination.yml`](disable-router-tls-termination.yml) | Eliminates keys related to performing tls/ssl termination within the gorouter job. | Useful for deployments where tls termination is performed prior to the gorouter - for instance, on AWS, such termination is commonly done at the ELB. This also eliminates the need to specify `((router_ssl.certificate))` and `((router_ssl.private_key))` in the var files. |
| [`enable-cc-rate-limiting.yml`](enable-cc-rate-limiting.yml) | Enable rate limiting for UAA-authenticated endpoints. | Introduces variables `cc_rate_limiter_general_limit` and `cc_rate_limiter_unauthenticated_limit` |
| [`enable-privileged-container-support.yml`](enable-privileged-container-support.yml) | Enables diego privileged container support on cc-bridge. | This ops-file might not be compatible with Ops-files that inline bridge functionality to cloud-controller. |
| [`enable-uniq-consul-node-name.yml`](enable-uniq-consul-node-name.yml) | Configure Diego cell `consul_agent` jobs to have a unique id per instance. |  |
| [`rename-deployment.yml`](rename-deployment.yml) | Allows a deployer to rename the deployment by passing a variable `deployment_name` |  |
| [`rename-network.yml`](rename-network.yml) | Allows a deployer to rename the network by passing a variable `network_name` |  |
| [`scale-to-one-az.yml`](scale-to-one-az.yml) | Scales cf-deployment down to a single instance per instance group, placing them all into a single AZ. | Effectively halves the deployment's footprint. Should be applied before other ops files. |
| [`stop-skipping-tls-validation.yml`](stop-skipping-tls-validation.yml) | Enforces `TLS` validation for all components which skip it in the base `cf-deployment.yml` manifest. | See the base [README](../README.md#tls) for details. |
| [`use-blobstore-cdn.yml`](use-blobstore-cdn.yml) | Adds support for accessing the `droplets` and `resource_pool` blobstore resources via signed urls over a cdn. | This assumes that you are using the same keypair for both buckets. Introduces [new variables](example-vars-files/vars-use-blobstore-cdn.yml) |
| [`use-external-dbs.yml`](use-external-dbs.yml) | Removes the MySQL instance group, cf-mysql release, and all cf-mysql variables. **Warning**: this does not migrate data, and will delete existing database instance groups. | This requires an external data store.   Introduces [new variables](example-vars-files/vars-use-external-dbs.yml) for DB connection details which will need to be provided at deploy time. This must be applied _before_ any ops files that removes jobs that use a database, such as the ops file to remove the routing API. |
| [`use-postgres.yml`](use-postgres.yml) | Replaces the MySQL instance group with a postgres instance group. **Warning**: this will lead to total data loss if applied to an existing deployment with MySQL or removed from an existing deployment with postgres. |  |
| [`use-compiled-releases.yml`](use-compiled-releases.yml) | Instead of having your BOSH Director compile each release, use this ops-file to use pre-compiled releases for a deployment speed improvement. |  |
| [`use-latest-stemcell.yml`](use-latest-stemcell.yml) | Use the latest stemcell available on your BOSH director instead of the one in `cf-deployment.yml` |  |
| [`windows-cell.yml`](windows-cell.yml) | Deploys a windows 2012 diego cell, adds releases necessary for windows. |  |
