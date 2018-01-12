# cf-deployment

### Table of Contents
* <a href='#purpose'>Purpose</a>
* <a href='#migrating'>Migrating from cf-release to cf-deployment</a>
* <a href='#tls'>TLS validation</a>
* <a href='#deploying-cf'>Deploying CF</a>
* <a href='#contributing'>Contributing</a>
* <a href='#setup'>Setup and Prerequisites</a>
* <a href='#ops-files'>Ops Files</a>
* <a href='#ci'>CI</a>

## <a name='purpose'></a>Purpose
This repo contains a canonical manifest
for deploying the CF Application Runtime without the use of `cf-release`,
relying instead on individual component releases.
It replaces the [manifest generation scripts in cf-release][cf-release-url]
which is in the process of being deprecated.
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
- emphasizes security and production-readiness by default.
  - bosh's `--vars-store` feature is used
  to generate strong passwords, certs, and keys.
  There are no default credentials, even in bosh-lite.
  - TLS/SSL features are enabled on every job which supports TLS.
- uses three AZs, of which two are used to provide redundancy for most instance groups.
The third is used only for instance groups
that should not have even instance counts,
such as consul.
- uses Diego natively,
does not support DEAs,
and enables diego-specific features
such as ssh access to apps by default.
- deploys jobs to handle platform data persistence
using singleton versions of the cf-mysql release for databases
and the CAPI release's singleton WebDAV job for blob storage.
See the  [database](deployment-guide.md#databases) and [blobstore](deployment-guide.md#blobstore) sections
of the deployment guide
for more resilient options.
- assumes load-balancing will be handled by the IaaS
or an external deployment.

## <a name='migrating'></a>Can I Transition from `cf-release`?
The Release Integration team
supports a transition path from `cf-release`.
You can find tooling and documentation for performing the migration
in our [cf-deployment-transition repo](https://github.com/cloudfoundry/cf-deployment-transition).

## <a name='tls'></a> TLS validation

Many test, development, and "getting started" environments
do not have valid `TLS` certificates
installed in their load balancers.
`cf-deployment` skips `TLS` validation
on some components
that access each other via the "front door"
of the Cloud Foundry load balancer
for ease of use
in such environments.
This is a temporary solution
that will be addressed soon
by the [BOSH Trusted Certificates](https://bosh.io/docs/trusted-certs.html) workflow.

Production deployers who have valid
or otherwise trusted
load balancer certificates should use the
[stop-skipping-tls-validation.yml](operations/stop-skipping-tls-validation.yml) opsfile
to force the validation of `TLS` certificates
for all components.

## <a name='deploying-cf'></a>Deploying CF
Deployment instructions have become verbose,
so we've moved them into a [dedicated deployment guide here](deployment-guide.md).

There's a small section in that doc
that tries to help operators reason about choices they can make in their deployments.
Take a look at [Notes for operators](deployment-guide.md#notes-for-operators).

See the rest of this document for more on the new CLI, deployment vars, and configuring your BOSH director.

## <a name='contributing'></a>Contributing
Although the default branch for the repository is `master`,
we ask that all pull requests be made against
the `develop` branch.
Please also take a look at the ["style guide"](texts/style-guide.md),
which lays out some guidelines for adding properties or jobs
to the deployment manifest.

Before submitting a pull request
or pushing to develop,
please run `./scripts/test`
which interpolates all of our ops files
with the `bosh` cli.

By default, the test suite omits `semantic` tests,
which require both [jq](https://stedolan.github.io/jq/)
and [yq](https://github.com/mikefarah/yq) installed.
If you wish to run them,
please install these requirements and
set `RUN_SEMANTIC=true` in your environment.

**Note:** it is necessary to run the tests
from the root of the repo.

If you add an Ops-file,
you will need to document it in its corresponding README
and add it to the ops file tests in `scripts/test`.

We ask that pull requests and other changes be successfully deployed,
and tested with the latest sha of CATs.

## <a name='setup'></a>Setup and Prerequisites
`cf-deployment` relies on newer BOSH features,
and requires a bosh director with a valid cloud-config that has been configured with a certificate authority.
It also requires the new `bosh` CLI,
which it relies on to generate and fill-in needed variables.

### BOSH director
`cf-deployment` requires BOSH [`v262`](https://github.com/cloudfoundry/bosh/releases/tag/v262).

### BOSH CLI
`cf-deployment` requires the new [BOSH CLI](https://github.com/cloudfoundry/bosh-cli).

### BOSH `cloud-config`
`cf-deployment` assumes that
you've uploaded a compatible [cloud-config](http://bosh.io/docs/cloud-config.html) to the BOSH director.
The cloud-config produced by `bbl` is compatible by default,
which covers GCP and AWS.
For bosh-lite, you can use the cloud-config in the `bosh-lite` directory of this repo.
We have not yet tested cf-deployment against other IaaSes,
so you may need to do some engineering work to figure out the right cloud config (and possibly ops files)
to get it working for `cf-deployment`.

### Deployment variables and the var-store
`cf-deployment.yml` requires additional information
to provide environment-specific or sensitive configuration
such as the system domain and various credentials.
To do this in the default configuration,
we use the `--vars-store` flag in the new BOSH CLI.
This flag takes the name of a `yml` file that it will read and write to.
Where necessary credential values are not present,
it will generate new values
based on the type information stored in `cf-deployment.yml`.

Necessary variables that BOSH can't generate
need to be supplied as well.
Though in the default case
this is just the system domain,
some ops files introduce additional variables.
See the summary for the particular ops files you're using
for any additional necessary variables.

There are three ways to supply
such additional variables.

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
3. They can be inserted directly in `--vars-store` file
   alongside BOSH-managed variables.
   This can confuse things,
   but you may find the simplicity worth it.

Variables passed with `-v` or `-l`
will override those already in the var store,
but will not be stored there.

## <a name='ops-files'></a>Ops Files
The configuration of CF represented by `cf-deployment.yml` is intended to be a workable, secure, fully-featured default.
When the need arises to make different configuration choices,
we accomplish this with the `-o`/`--ops-file` flags.
These flags read a single `.yml` file that details operations to be performed on the manifest
before variables are generated and filled.
We've supplied some common manifest modifications in the `operations` directory.
More details can be found in the [Ops-file README](operations/README.md).

### A note on `community`, `experimental`, and `test` ops-files
The `operations` directory includes subdirectories
for "community", "experimental", and "test" ops-files.

#### Addons
These ops-files make changes to
most or all instance groups.
They can be applied to the BOSH Director's
runtime config,
or directly to an individual deployment manifest.

The ops-file to configure platform component logging
with rsyslog is such an add-on.
Please see the [Addon Ops-file README](operations/addons/README.md)
for details.

#### Community
"Community" ops-files are contributed by the Cloud Foundry community. They are not maintained or supported by the Release Integration team. For details, see the [Community Ops-file README](operations/community/README.md)

#### Experimental
"Experimental" ops-files represent configurations
that we expect to promote to blessed configuration eventually,
meaning that,
once the configurations have been sufficiently validated,
they will become part of cf-deployment.yml
and the ops-files will be removed.
For details, see the [Experimental Ops-file README](operations/experimental/README.md).

#### Test
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

## <a name='ci'></a>CI
The [ci](https://release-integration.ci.cf-app.com/teams/main/pipelines/cf-deployment) for `cf-deployment`
automatically bumps to the latest versions of its component releases on the `develop` branch.
These bumps, along with any other changes made to `develop`, are deployed to a single long-running environment
and tested with CATs before being merged to master if CATs goes green.

Each version of cf-deployment is given a corresponding branch in the CATs repo,
so that users can discover which version of CATs to run against their deployments.
For example, if you've deployed cf-deployment v0.35.0,
check out the `cf0.35` branch in cf-acceptance-tests to run CATs.

The configuration for our pipeline can be found [here](https://github.com/cloudfoundry/runtime-ci/blob/master/pipelines/cf-deployment.yml).

[cf-deployment-concourse-url]: https://release-integration.ci.cf-app.com/teams/main/pipelines/cf-deployment
[cf-release-url]: https://github.com/cloudfoundry/cf-release/tree/master/templates
