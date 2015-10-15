# cf-deployment
---

##About

cf-deployment is a collection of tools for deploying Cloud Foundry.

##Tools

###`scripts/create_releases`
*Usage:* `create_releases PATH_TO_CF_RELEASE PATH_TO_ETCD_RELEASE PATH_TO_CONSUL_RELEASE`

*Arguments:*

* `PATH_TO_CF_RELEASE`: Path to the cf-release directory.
* `PATH_TO_ETCD_RELEASE`: Path to the etcd-release directory, or an etcd-release tarball.
* `PATH_TO_CONSUL_RELEASE`: Path to the consul-release directory, or a consul-release tarball.

*Description:* Creates cf-release and places the release tarball in the `outputs/releases` folder. The same will be done for etcd/consul-release unless a tarball is given, then it is simply copied.


###`scripts/generate_deployment_manifest`
*Usage:* `generate_deployment_manifest <aws|openstack|warden|vsphere> PATH_TO_CF_RELEASE PATH_TO_STUB [PATHS_TO_ADDITIONAL_STUBS...]`

*Arguments:*

* `INFRASTRUCTURE`: Must be aws, openstack, warden, or vsphere.
* `PATH_TO_CF_RELEASE`: Path to the cf-release directory.
* `PATH_TO_STUB`, `PATHS_TO_ADDITIONAL_STUBS`: Paths for YAML stubs to be merged into the manifest. At minimum, you are required to provide a stub that has the `director_uuid` value for the BOSH director to which you will deploy.

*Description:* Generates a deployment manifest for the given infrastructure and writes it to standard output.


###`scripts/prepare_deployment`
*Usage:* `prepare_deployment <aws|openstack|warden|vsphere> PATH_TO_CF_RELEASE PATH_TO_ETCD_RELEASE PATH_TO_CONSUL_RELEASE PATH_TO_STUB [PATHS_TO_ADDITIONAL_STUBS...]`

*Arguments:*

* `INFRASTRUCTURE`: Must be aws, openstack, warden, or vsphere.
* `PATH_TO_CF_RELEASE`: Path to the cf-release directory.
* `PATH_TO_ETCD_RELEASE`: Path to the etcd-release directory, or an etcd-release tarball.
* `PATH_TO_CONSUL_RELEASE`: Path to the consul-release directory, or a consul-release tarball.
* `PATH_TO_STUB`, `PATHS_TO_ADDITIONAL_STUBS`: Paths for YAML stubs to be merged into the manifest. At minimum, you are required to provide a stub that has the `director_uuid` value for the BOSH director to which you will deploy.

*Description:* Calls the `create_releases` script followed by the `generate_deployment_manifest` script.


###`scripts/deploy`
*Usage:* `deploy <aws|openstack|warden|vsphere> PATH_TO_CF_RELEASE PATH_TO_ETCD_RELEASE PATH_TO_CONSUL_RELEASE PATH_TO_STUB [PATHS_TO_ADDITIONAL_STUBS...]`

*Arguments:*

* `INFRASTRUCTURE`: Must be aws, openstack, warden, or vsphere.
* `PATH_TO_CF_RELEASE`: Path to the cf-release directory.
* `PATH_TO_ETCD_RELEASE`: Path to the etcd-release directory, or an etcd-release tarball.
* `PATH_TO_CONSUL_RELEASE`: Path to the consul-release directory, or a consul-release tarball.
* `PATH_TO_STUB`, `PATHS_TO_ADDITIONAL_STUBS`: Paths for YAML stubs to be merged into the manifest. At minimum, you are required to provide a stub that has the `director_uuid` value for the BOSH director to which you will deploy.

*Description:* Calls the `prepare_deployment` script and saves the manifest as `outputs/manifests/cf.yml`. Uploads the releases in the `outputs/releases` folder to the currently targeted BOSH director. Deploys the generated manifest to the currently targeted BOSH director.

**NOTE:** You must already have uploaded a compatible stemcell to the director for the deploy to work.

###`tools/prepare_deployments`
*Usage:* `prepare_deployments <aws> PATH_TO_CONFIG_FILE

*Arguments:*

* `PATH_TO_CONFIG_FILE`: Path to the config file.

*Description:* Generates a CF-Deployment manifest given a config file which contains the versions of each release to be used.

The config file you pass to `./tools/prepare_deployments` has the following form, for example:

```json
{
  "cf": "/Users/pivotal/workspace/cf-release",
  "etcd": "integration-latest",
  "stemcell": "/Users/pivotal/Downloads/light-bosh-stemcell-3058-aws-xen-hvm-ubuntu-trusty-go_agent.tgz",
  "stubs": ["/Users/pivotal/workspace/deployment1/properties-stub.yml", "/Users/pivotal/workspace/deployment1/instances-stub.yml"],
  "deployments-dir": "/Users/pivotal/workspace/deployment1/artifacts"
}
```

The config file provides the following values:

* `cf`: string, either a path to a directory of `cf-release`, or the string `"integration-latest"`
* `etcd`: string, either a path to a directory of `etcd-release`, a path to a release tarball, the string `"director-latest"`, or the string `"integration-latest"`
* `stemcell`: string, either a path to a stemcell tarball, the string `"director-latest"`, or the string `"integration-latest"`
* `stubs`: array, a list of paths to stub files (required)
* `deployments-dir`: string, a path to a directory where manifests will be written

#### Defaults

* `--cf`: defaults to `"integration-latest"`
* `--etcd`: defaults to `"integration-latest"`
* `--stemcell`: defaults to `"integration-latest"`
* `--stubs`: defaults to an empty list
* `--deployments-dir`: defaults to `./outputs/manifests`

Please note: default manifests for each IaaS have required properties that must be set in a stub provided by the user.
To see an example and instructions for how to create this stub visit our [documentation](http://docs.cloudfoundry.org/deploying/cf-stub-vsphere.html).

When the special version string `integration-latest` is specified the script will read `blessed_versions.json`
and fill in the proper values for each release. The exception to this is `cf` in which case it will clone
the `cf-release` repo into a temporary directory, check out the git commit sha specified for `cf-release`
in `blessed_versions.json`, and specify `create` as the version in the generated deployment manifest. Note that
the "create" version keyword is not currently supported in bosh, [see this branch of work](https://github.com/njbennett/bosh/tree/mega-remote-releases).

When the special version string `director-latest` is specified the script will set the version of the release
in the generated deployment manifest to `latest`. The exception to this is `cf` which does not support
`director-latest` as version or location parameter.