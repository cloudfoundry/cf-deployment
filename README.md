# cf-deployment


### About

cf-deployment is a collection of tools to facilitate deploying Cloud Foundry with BOSH.

### Tools

#### Prepare Deployments
*Usage:*  
`./tools/prepare_deployments <aws> PATH_TO_CONFIG_FILE`

*Arguments:*
* `aws`: The infrastructure for which to generate the manifests. Currently only `aws` is supported.
* `PATH_TO_CONFIG_FILE`: Path to the config file.

*Description:*  
Generates a Cloud Foundry deployment manifest called `cf.yml` placed in either a specified or default directory (see references to `deployments-dir` below). The config file you pass to `./tools/prepare_deployments` must be a JSON file specifying some or all of the following properties:

* `cf`: (string, optional) either a path to a directory of `cf-release`, or the string `"integration-latest"`
* `etcd`: (string, optional) either a path to a directory of `etcd-release`, a path to a release tarball, the string `"director-latest"`, or the string `"integration-latest"`
* `stemcell`: (string, optional) either a path to a stemcell tarball, the string `"director-latest"`, or the string `"integration-latest"`
* `stubs`: (array of strings, required): a non-empty list of paths to stub files
* `deployments-dir`: (string, optional) a path to a directory where manifests will be written

For example:

```json
{
  "cf": "/Users/pivotal/workspace/cf-release",
  "etcd": "integration-latest",
  "stemcell": "/Users/pivotal/Downloads/light-bosh-stemcell-3058-aws-xen-hvm-ubuntu-trusty-go_agent.tgz",
  "stubs": ["/Users/pivotal/workspace/deployment1/properties-stub.yml", "/Users/pivotal/workspace/deployment1/instances-stub.yml"],
  "deployments-dir": "/Users/pivotal/workspace/deployment1/artifacts"
}
```

NOTE: The manifest templates each IaaS require certain properties to be set in a stub provided by the user.
To see instructions for the current recommendations on how to create this stub for the various IaaSes, check out the following links:

* [AWS](https://docs.cloudfoundry.org/deploying/ec2/cf-stub-aws.html)
* [vSphere](https://docs.cloudfoundry.org/deploying/vsphere/cf-stub-vsphere.html) (not currently supported by this tool)
* [vCloud](https://docs.cloudfoundry.org/deploying/vcloud/cf-stub-vcloud.html) (not currently supported by this tool)
* [OpenStack](https://docs.cloudfoundry.org/deploying/openstack/cf-stub-openstack.html) (not currently supported by this tool)
* [BOSH-Lite](https://docs.cloudfoundry.org/deploying/boshlite/#create-stub) (not currently supported by this tool)

*Defaults:*  
For each property (other than `stubs`) that is not specified in the config file, the following default values exist:

* `cf`: defaults to `"integration-latest"`
* `etcd`: defaults to `"integration-latest"`
* `stemcell`: defaults to `"integration-latest"`
* `deployments-dir`: defaults to `./outputs/manifests`

##### Explanation of `director-latest` and `integration-latest`

When the special version string `integration-latest` is specified for a release or stemcell, this tool will read `blessed_versions.json`
and fill in the proper values in the deployment manifest for that release or stemcell. The exception to this is `cf` in which case it will clone the `cf-release` repo into a temporary directory, check out the git commit SHA specified for `cf-release`
in `blessed_versions.json`, and specify `create` as the version in the generated deployment manifest. Note that
the `create` version keyword is a work-in-progress feature, expected to be officially supported in BOSH by early November 2015. [See this branch of work](https://github.com/njbennett/bosh/tree/mega-remote-releases).

When the special version string `director-latest` is specified the script will set the version of the release or stemcell
in the generated deployment manifest to `latest`. The exception to this is `cf` which does not support
`director-latest`.

----

### Scripts (to be replaced by above Tools)
#### Create Releases
*Usage:*  
`./scripts/create_releases PATH_TO_CF_RELEASE PATH_TO_ETCD_RELEASE PATH_TO_CONSUL_RELEASE`

*Arguments:*  
* `PATH_TO_CF_RELEASE`: Path to the cf-release directory.
* `PATH_TO_ETCD_RELEASE`: Path to the etcd-release directory, or an etcd-release tarball.
* `PATH_TO_CONSUL_RELEASE`: Path to the consul-release directory, or a consul-release tarball.

**Description:**  
Creates cf-release and places the release tarball in the `outputs/releases` folder. The same will be done for etcd/consul-release unless a tarball is given, then it is simply copied.

#### Generate Deployment Manifest
*Usage:*  
`./scripts/generate_deployment_manifest <aws|openstack|warden|vsphere> PATH_TO_CF_RELEASE PATH_TO_STUB [PATHS_TO_ADDITIONAL_STUBS...]`

*Arguments:*  
* `INFRASTRUCTURE`: Must be aws, openstack, warden, or vsphere.
* `PATH_TO_CF_RELEASE`: Path to the cf-release directory.
* `PATH_TO_STUB`, `PATHS_TO_ADDITIONAL_STUBS`: Paths for YAML stubs to be merged into the manifest. At minimum, you are required to provide a stub that has the `director_uuid` value for the BOSH director to which you will deploy.

*Description:*  
Generates a deployment manifest for the given infrastructure and writes it to standard output.

#### Prepare Deployment
*Usage:*  
`./scripts/prepare_deployment <aws|openstack|warden|vsphere> PATH_TO_CF_RELEASE PATH_TO_ETCD_RELEASE PATH_TO_CONSUL_RELEASE PATH_TO_STUB [PATHS_TO_ADDITIONAL_STUBS...]`

*Arguments:*  
* `INFRASTRUCTURE`: Must be aws, openstack, warden, or vsphere.
* `PATH_TO_CF_RELEASE`: Path to the cf-release directory.
* `PATH_TO_ETCD_RELEASE`: Path to the etcd-release directory, or an etcd-release tarball.
* `PATH_TO_CONSUL_RELEASE`: Path to the consul-release directory, or a consul-release tarball.
* `PATH_TO_STUB`, `PATHS_TO_ADDITIONAL_STUBS`: Paths for YAML stubs to be merged into the manifest. At minimum, you are required to provide a stub that has the `director_uuid` value for the BOSH director to which you will deploy.

*Description:*  
Calls the `create_releases` script followed by the `generate_deployment_manifest` script.

#### Deploy  
*Usage:*  
`./scripts/deploy <aws|openstack|warden|vsphere> PATH_TO_CF_RELEASE PATH_TO_ETCD_RELEASE PATH_TO_CONSUL_RELEASE PATH_TO_STUB [PATHS_TO_ADDITIONAL_STUBS...]`

*Arguments:*  
* `INFRASTRUCTURE`: Must be aws, openstack, warden, or vsphere.
* `PATH_TO_CF_RELEASE`: Path to the cf-release directory.
* `PATH_TO_ETCD_RELEASE`: Path to the etcd-release directory, or an etcd-release tarball.
* `PATH_TO_CONSUL_RELEASE`: Path to the consul-release directory, or a consul-release tarball.
* `PATH_TO_STUB`, `PATHS_TO_ADDITIONAL_STUBS`: Paths for YAML stubs to be merged into the manifest. At minimum, you are required to provide a stub that has the `director_uuid` value for the BOSH director to which you will deploy.

*Description:*  
Calls the `prepare_deployment` script and saves the manifest as `outputs/manifests/cf.yml`. Uploads the releases in the `outputs/releases` folder to the currently targeted BOSH director. Deploys the generated manifest to the currently targeted BOSH director.

NOTE: You must already have uploaded a compatible stemcell to the director for the deploy to work.
