# cf-deployment

### Table of Contents
* <a href='#purpose'>Purpose</a>
* <a href='#tls'>TLS validation</a>
* <a href='#deploying-cf'>Deploying CF</a>
* <a href='#versioning'>Release Versioning</a>
* <a href='#contributing'>Contributing</a>
* <a href='#setup'>Setup and Prerequisites</a>
* <a href='#ops-files'>Ops Files</a>
* <a href='#ci'>CI</a>
* <a href='#vars-store'>Migrating from Vars-Store to CredHub</a>
* <a href='#migrating'>Migrating from cf-release to cf-deployment</a>

## <a name='purpose'></a>Purpose
This repo contains a canonical [BOSH](http://bosh.io/docs) deployment manifest
for deploying the Cloud Foundry Application Runtime by relying individual component releases.
It uses several newer features
of the BOSH director and CLI.
Older directors may need to be upgraded
and have their configurations extended
in order to support `cf-deployment`.

`cf-deployment` embodies several opinions
about the CF Application Runtime.
It:
- prioritizes readability and meaning to a human operator.
  For instance, only necessary configuration is included.
- emphasizes security by default.
  - CredHub is used to generate strong passwords, certs, and keys.
  There are no default credentials, even in bosh-lite.
  - TLS/SSL features are enabled on every job which supports TLS.
- uses two AZs to provide redundancy for most instance groups.
- uses [Diego](http://docs.cloudfoundry.org/concepts/diego/diego-architecture.html) ([source code](https://github.com/cloudfoundry/diego-release)) by default.
- deploys jobs to handle platform data persistence
using singleton versions of the `PXC` release for databases
and the CAPI release's singleton WebDAV job for blob storage.
See the  [database](texts/deployment-guide.md#databases) and [blobstore](texts/deployment-guide.md#blobstore) sections
of the deployment guide
for more information.
- assumes load-balancing will be handled by the IaaS
or an external deployment.

## <a name='tls'></a> TLS validation

Many test, development, and "getting started" environments
do not have valid `TLS` certificates
installed in their load balancers. For ease of use in such environments,
`cf-deployment` skips `TLS` validation
on some components
that access each other via the "front door"
of the Cloud Foundry load balancer.

Deployers who have valid
or otherwise trusted
load balancer certificates should use the
[stop-skipping-tls-validation.yml](operations/stop-skipping-tls-validation.yml) opsfile
to force the validation of `TLS` certificates
for all components.

## <a name='deploying-cf'></a>Deploying CF
Deployment instructions are verbose so we've moved them into a [dedicated deployment guide here](texts/deployment-guide.md).

## <a name='versioning'></a>Release Versioning
The Semantic Versioning scheme has been adopted by cf-deployment.
A detailed description of how [Semantic Versioning is applied to CF-Deployment can be found here](texts/versioning.md).

## <a name='contributing'></a>Contributing to CF-Deployment
Although the default branch for the repository is [`main`](https://github.com/cloudfoundry/cf-deployment/tree/main),
we ask that all pull requests be made against
the [`develop`](https://github.com/cloudfoundry/cf-deployment/tree/develop) branch. 
- **Please fill out the [PR Template](https://github.com/cloudfoundry/cf-deployment/blob/main/PULL_REQUEST_TEMPLATE.md)** when submitting pull requests. The information requested in the PR form provides important context for the team responsible for evaluating your submission.
- Please also take a look at the ["style guide"](texts/style-guide.md),
which lays out some guidelines for adding properties or jobs
to the deployment manifest.

**Before submitting a pull request
or pushing to the develop branch of cf-deployment, please:**
1. run `./units/test`
   which interpolates all of our ops files
   with the `bosh` cli.
    - By default, the test suite omits `semantic` tests,
which require both [jq](https://stedolan.github.io/jq/)
and [yq](https://github.com/mikefarah/yq) installed.
    - If you wish to run them,
please install these requirements and
set `RUN_SEMANTIC=true` in your environment.
    - **Note:** it is necessary to run the tests
from the root of the repo.
1. confirm your changes can be successfully deployed with 
   the [latest release of cf-deployment](https://github.com/cloudfoundry/cf-deployment/releases) 
   and tested with the latest version of [CAT's](https://github.com/cloudfoundry/cf-acceptance-tests/releases).
1. If modifying backup and restore, run `./scripts/test`
   which runs a legacy bash suite for backup and restore ops.
**If you're adding an Ops-file, you will need to:** 
1. document it in its corresponding README.
1. add it to the ops file tests in `units/test`.

**If you're promoting or deprecating Ops-file, please follow [Ops-file workflows](https://github.com/cloudfoundry/cf-deployment/blob/main/ops-file-promotion-workflow.md)** 


## <a name='setup'></a>Setup and Prerequisites
`cf-deployment` requires a bosh director with a valid cloud-config that has been configured with a certificate authority.
It also requires the `bosh` CLI,
which it relies on to generate and fill-in needed variables.

### BOSH director and stemcells
`cf-deployment` requires both [BOSH](https://github.com/cloudfoundry/bosh/releases) and [Linux stemcells](https://bosh.io/stemcells/).

### BOSH CLI
`cf-deployment` requires the [BOSH CLI](https://github.com/cloudfoundry/bosh-cli).

### BOSH `cloud-config`
`cf-deployment` assumes that
you've uploaded a compatible [cloud-config](http://bosh.io/docs/cloud-config.html) to the BOSH director prior to deploying your foundation.

The cloud-config produced by `bbl` covers GCP, AWS, and Azure, and is compatible by default.

The [`iaas-support`](https://github.com/cloudfoundry/cf-deployment/tree/main/iaas-support) directory includes tools and templates for building cloud-configs for other IaaSes,
including bosh-lite, vSphere, Openstack, and Alibaba Cloud.

For other IaaSes,
you may need to do some engineering work to figure out the right cloud config (and possibly ops files)
to get it working for `cf-deployment`.

### BOSH `runtime-config`
`cf-deployment` requires that you have uploaded
a [runtime-config](https://bosh.io/docs/runtime-config/) for [BOSH DNS](https://bosh.io/docs/dns/) prior to deploying your foundation.
We recommended that you use the one provided by the
[bosh-deployment](https://github.com/cloudfoundry/bosh-deployment/blob/master/runtime-configs/dns.yml) repo:

```
bosh update-runtime-config bosh-deployment/runtime-configs/dns.yml --name dns
```

**Note:** [BBL v6.10.0](https://github.com/cloudfoundry/bosh-bootloader/releases/tag/v6.10.0) or later will set a runtime config including BOSH DNS when you `bbl up`.

### Deployment variables and CredHub
`cf-deployment.yml` requires additional information
to provide environment-specific or sensitive configuration
such as the system domain and various credentials.

To do this in the default configuration,
we use [CredHub](https://github.com/pivotal-cf/credhub-release),
which is deployed on your BOSH director by default if you are using `bbl`.

Where necessary credential values are not present,
CredHub will generate new values
based on the type information stored in `cf-deployment.yml`.

**Note:** Since [`cf-deployment` v3.0](https://github.com/cloudfoundry/cf-deployment/releases/tag/v3.0.0), CredHub has replaced the now deprecated BOSH `vars-store` as the default way to store
and generate credentials.

Necessary variables that BOSH can't ask CredHub to generate
need to be supplied as well.

If the deployment includes only the base manifest (cf-deployment.yml), this is just the system domain.
However, some ops files introduce additional variables.
See the README summary for the particular ops files you're using
for any additional necessary variables.

There are three ways to supply
such additional variables:

1. They can be provided by passing individual `-v` arguments.
   The syntax for `-v` arguments is
   `-v <variable-name>=<variable-value>`.
   This is the recommended method for supplying
   the system domain.
2. They can be provided in a yaml file
   accessed from the command line with the
   `-l` or `--vars-file` flag.
   This is the recommended method for configuring
   external persistence services.
3. They can be stored in CredHub directly
   with the [CredHub CLI](https://docs.cloudfoundry.org/api/credhub/).
   If you do this, then you need follow variable namespacing
   rules respected by BOSH described [here](https://github.com/cloudfoundry-incubator/credhub/blob/master/docs/operator-quick-start.md#variable-namespacing).

## <a name='ops-files'></a>Ops Files
The configuration of CF represented by `cf-deployment.yml` is a workable, secure, fully-featured default.
When the need arises to make different configuration choices for your foundation,
you can accomplish this with the `-o`/`--ops-file` flags.
These flags read a single `.yml` file that details operations to be performed on the manifest
before variables are generated and filled.
We've supplied some common manifest modifications in the `operations` directory.
More details can be found in the [Ops-file README](operations/README.md).

### The `operations` subdirectories

#### [Addons](operations/addons)
These ops-files make changes to
most or all instance groups.
They can be applied to the BOSH Director's
runtime config,
or directly to an individual deployment manifest.

The ops-file to configure platform component logging
with rsyslog is such an add-on.
Please see the [Addon Ops-file README](operations/addons/README.md)
for details.

#### [Community](operations/community)
"Community" ops-files are contributed by the Cloud Foundry community. They are not maintained or supported by the Release Integration team. For details, see the [Community Ops-file README](operations/community/README.md)

#### [Experimental](operations/experimental)
"Experimental" ops-files represent configurations
that are in the process of being developed and/or validated.
Once the configurations have been sufficiently validated,
they will become part of cf-deployment.yml
and the ops-files will be removed.
For details, see the [Experimental Ops-file README](operations/experimental/README.md).

#### [Test](operations/test)
"Test" ops-files are configurations
that we run in our testing pipeline
to enable certain features.
We include them in the public repository
(rather than in our private CI repositories)
for a few reasons,
depending on the particular ops-file.

Some files are included
because we suspect that the configurations will be commonly needed
but not easily generalized.
For example,
`add-persistent-isolation-segment.yml` shows how a deployer can add an isolated Diego cell,
but the ops-file is hard to apply repeatably.
In this case, the ops-file is an example.

#### [Backup and Restore](operations/backup-and-restore)
Contains all the ops files utilized to enable and configure [BOSH Backup and Restore](https://github.com/cloudfoundry-incubator/bosh-backup-and-restore) (BBR).
BBR is a CLI utility for orchestrating the backup and restore of [BOSH](https://bosh.io/) deployments and BOSH directors. It orchestrates triggering the backup or restore process on the deployment or director, and transfers the backup artifact to and from the deployment or director.

## <a name='ci'></a>CI
The [ci](https://concourse.wg-ard.ci.cloudfoundry.org) for `cf-deployment`
automatically bumps to the latest versions of its component releases on the `develop` branch.
These bumps, along with any other changes made to `develop`, are deployed to a single long-running environment
and tested with CATs before being merged to main if CATs goes green.

Each version of cf-deployment is given a corresponding branch in the CATs repo,
so that users can discover which version of CATs to run against their deployments.
For example, if you've deployed cf-deployment v6.10.0,
check out the `cf6.10` branch in cf-acceptance-tests to run CATs.

The configuration for our pipeline can be found [here](https://github.com/cloudfoundry/cf-deployment/blob/develop/ci/pipelines/cf-deployment.yml).

[cf-deployment-concourse-url]: https://concourse.wg-ard.ci.cloudfoundry.org

## <a name='vars-store'></a>Migrating from Vars Store to CredHub
CredHub is default as of cf-deployment release v
If you've got a long running foundation running a release of cf-deployment that relies on `vars-store` and want to upgrade to a version that's backed by CredHub, you will need to migrate your credentials from `vars-store` to CredHub.
We have a [utility](https://github.com/ishustava/migrator) to help you migrate.

## <a name='migrating'></a>Can I Transition from `cf-release`?
CF-Deployment replaces the [manifest generation scripts in cf-release][cf-release-url] which have been deprecated and are no longer supported by the Release Integration team.
Although the team is no longer working on or supporting migrations from `cf-release` to `cf-deployment`, you can still find the tooling and documentation in the [cf-deployment-transition repo](https://github.com/cloudfoundry/cf-deployment-transition).

