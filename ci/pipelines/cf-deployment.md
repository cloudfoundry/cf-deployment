# cf-deployment

## Purpose

This pipeline validates changes to cf-deployment and automates the creation of artifacts used in the release process.

## Groups

* `cf-deployment`: test commits to the `develop` branch of cf-deployment and promotes them to the `release-candidate` branch where they are subsequently used in the manual release process.
* `bbr`: tests BBR (bosh backup and restore) using DRATs (disaster recover acceptance tests)
* `fresh-luna`: tests a fresh install with mostly default configuration
* `upgrade-trelawney`: tests an upgrade from the latest release with an external db
* `experimental-hermione`: tests experimental ops files and upgrades from the latest release
* `lite-snitch`: tests a fresh installation on a dynamically provisioned bosh-lite director
* `windows`: tests windows functionality on a fresh install with windows diego cells using the windows suites from cf-acceptance-tests
* `ship-it`: jobs for use in the manual release process of cf-deployment

## Validation Strategy

### Unit Testing

We block acceptance testing on unit testing and static code analysis of the `cf-deployment.yml` bosh manifest, surrounding bosh ops-files, and related documentation in the `operations/README.md` file. These test suites validate the bosh manifest configuration interface and the presence of documentation for ops-files.

### Acceptance Testing Fan-out

Once unit testing is complete, we deploy cf-deployment and use smoke-tests and cf-acceptance-tests to validate a matrix of configuration scenarios including the following dimensions:

* Fresh installation, upgrade from latest release
* Pre-compiled releases, and source releases compiled on director
* Persistent data stores (database, blobstore): internally deployed, external service
  * Note that our external database infrastructure is managed by a Terraform template in the `trelawney` group of the `infrastructure` pipeline
* Isolation segments
* Windows cells
* Infrastructure provider: GCP, AWS
* Experimental ops-files

Separately, we include specific testing for BBR as noted in the group descriptions.

In general, the acceptance testing flow involves deploying the `develop` branch commit as a fresh installation to a pre-provisioned bosh director (usually managed by the `infrastructure` pipeline) with pre-compiled releases to reduce the deployment time.

In the case of upgrade, we first deploy the latest release of `cf-deployment` and ensure stability with `smoke-tests` before upgrading to the latest commit from `develop`. We use [uptimer](https://github.com/cloudfoundry/uptimer) to measure platform and app availability during the upgrade process.

### Integration of Validated Commits

After unit testing and the acceptance testing fan-out succeed, we promote the commit to the `release-candidate` branch of cf-deployment and mark any related [Pivotal Tracker](https://www.pivotaltracker.com) story using the [concourse tracker resource](https://github.com/concourse/tracker-resource). From there, the manual release jobs are responsible for further promotion of the `release-candidate` branch to the `main` branch of cf-deployment for use in a new release.

## Release Management

Release management is a manual process and consists of the following steps:

1. Open the latest build of the `release-notes-template` job and view the output of the `generate-cf-deployment-release-notes-template` task to get a table of upstream component release information.
1. Review the release notes template and the commits in the diff between the `release-candidate` and `main` branch to capture any changes to the bosh manifest and ops-files configuration interface.
1. Based on the previous steps determine whether the release is a major, minor, or patch.
1. Based on the type of release run the `ship-it-*` job to promote the changes to the `main` branch with a new version tag.
1. Manually associate the new tag with a release populated with information from the previous steps.

See the `CF-Deployment-Release` page on the team wiki for further release process details.

## Pipeline Management

This pipeline is managed directly by the `ci/pipelines/cf-deployment.yml` file and the `ci/configure` script. To update the pipeline, run `ci/configure cf-deployment`.

## Notes

* `validate-certs`: warns of upcoming expiration of the certs of the bosh directors we use for acceptance testing
* `branch-freshness`: warns of branches of cf-d that go stale
* `*-release-pool-manual`: jobs that will release the lock on the environment in question.  Only visible via group. Used to reset the pipeline when an environment remains claimed after a build failure.
