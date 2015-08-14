# cf-deployment
---

##About

cf-deployment is a collection of scripts for deploying Cloud Foundry elastic runtime.

##Scripts

###`scripts/create_releases`
*Usage:* `create_releases PATH_TO_CF_RELEASE PATH_TO_ETCD_RELEASE`

*Arguments:*

* `PATH_TO_CF_RELEASE`: Path to the cf-release folder.
* `PATH_TO_ETCD_RELEASE`: Path to the etcd-release folder, or the etcd release tarball.

*Description:* Creates cf-release and places the release tarball in the `outputs/releases` folder.
  The same will be done for etcd-release unless a tarball is given, then it is simply copied.


###`scripts/generate_deployment_manifest`
*Usage:* `generate_deployment_manifest <aws|openstack|warden|vsphere> PATH_TO_CF_RELEASE [stubs...]`

*Arguments:*

* `INFRASTRUCTURE`: Must be aws, openstack, warden, or vsphere.
* `PATH_TO_CF_RELEASE`: Path to the cf-release folder.
* `STUBS`: Paths for stubs to be merged into the manifest.

*Description:* Generates a deployment manifest for the given infrastructure and outputs it to standard out. 


###`scripts/prepare_deployment`
*Usage:* `prepare_deployment <aws|openstack|warden|vsphere> PATH_TO_CF_RELEASE PATH_TO_ETCD_RELEASE [stubs...]`

*Arguments:*

* `INFRASTRUCTURE`: Must be aws, openstack, warden, or vsphere.
* `PATH_TO_CF_RELEASE`: Path to the cf-release folder.
* `PATH_TO_ETCD_RELEASE`: Path to the etcd-release folder, or the etcd release tarball.
* `STUBS`: Paths for stubs to be merged into the manifest.

*Description:* Calls the `create_releases` script followed by the `generate_deployment_manifest` script 


###`scripts/deploy`
*Usage:* `deploy <aws|openstack|warden|vsphere> PATH_TO_CF_RELEASE PATH_TO_ETCD_RELEASE [stubs...]`

*Arguments:*

* `INFRASTRUCTURE`: Must be aws, openstack, warden, or vsphere.
* `PATH_TO_CF_RELEASE`: Path to the cf-release folder.
* `PATH_TO_ETCD_RELEASE`: Path to the etcd-release folder, or the etcd release tarball.
* `STUBS`: Paths for stubs to be merged into the manifest.

*Description:* Calls the `prepare_deployment` script and saves the manifest as `outputs/manifests/cf.yml`.
  Uploads the releases in the `outputs/releases` folder to the currently targeted BOSH director. Deploys
  the generated manifest to the currently targeted BOSH director.
