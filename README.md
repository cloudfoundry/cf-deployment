# cf-deployment
---

##About

cf-deployment is a collection of tools for deploying Cloud Foundry.

##Tools

###`scripts/create_releases`
*Usage:* `create_releases PATH_TO_CF_RELEASE PATH_TO_ETCD_RELEASE`

*Arguments:*

* `PATH_TO_CF_RELEASE`: Path to the cf-release directory.
* `PATH_TO_ETCD_RELEASE`: Path to the etcd-release directory, or an etcd-release tarball.

*Description:* Creates cf-release and places the release tarball in the `outputs/releases` folder. The same will be done for etcd-release unless a tarball is given, then it is simply copied.


###`scripts/generate_deployment_manifest`
*Usage:* `generate_deployment_manifest <aws|openstack|warden|vsphere> PATH_TO_CF_RELEASE PATH_TO_STUB [PATHS_TO_ADDITIONAL_STUBS...]`

*Arguments:*

* `INFRASTRUCTURE`: Must be aws, openstack, warden, or vsphere.
* `PATH_TO_CF_RELEASE`: Path to the cf-release directory.
* `PATH_TO_STUB`, `PATHS_TO_ADDITIONAL_STUBS`: Paths for YAML stubs to be merged into the manifest. At minimum, you are required to provide a stub that has the `director_uuid` value for the BOSH director to which you will deploy.

*Description:* Generates a deployment manifest for the given infrastructure and writes it to standard output.


###`scripts/prepare_deployment`
*Usage:* `prepare_deployment <aws|openstack|warden|vsphere> PATH_TO_CF_RELEASE PATH_TO_ETCD_RELEASE PATH_TO_STUB [PATHS_TO_ADDITIONAL_STUBS...]`

*Arguments:*

* `INFRASTRUCTURE`: Must be aws, openstack, warden, or vsphere.
* `PATH_TO_CF_RELEASE`: Path to the cf-release directory.
* `PATH_TO_ETCD_RELEASE`: Path to the etcd-release directory, or an etcd-release tarball.
* `PATH_TO_STUB`, `PATHS_TO_ADDITIONAL_STUBS`: Paths for YAML stubs to be merged into the manifest. At minimum, you are required to provide a stub that has the `director_uuid` value for the BOSH director to which you will deploy.

*Description:* Calls the `create_releases` script followed by the `generate_deployment_manifest` script.


###`scripts/deploy`
*Usage:* `deploy <aws|openstack|warden|vsphere> PATH_TO_CF_RELEASE PATH_TO_ETCD_RELEASE PATH_TO_STUB [PATHS_TO_ADDITIONAL_STUBS...]`

*Arguments:*

* `INFRASTRUCTURE`: Must be aws, openstack, warden, or vsphere.
* `PATH_TO_CF_RELEASE`: Path to the cf-release directory.
* `PATH_TO_ETCD_RELEASE`: Path to the etcd-release directory, or an etcd-release tarball.
* `PATH_TO_STUB`, `PATHS_TO_ADDITIONAL_STUBS`: Paths for YAML stubs to be merged into the manifest. At minimum, you are required to provide a stub that has the `director_uuid` value for the BOSH director to which you will deploy.

*Description:* Calls the `prepare_deployment` script and saves the manifest as `outputs/manifests/cf.yml`. Uploads the releases in the `outputs/releases` folder to the currently targeted BOSH director. Deploys the generated manifest to the currently targeted BOSH director.

**NOTE:** You must already have uploaded a compatible stemcell to the director for the deploy to work.
