# bionic-stemcell

Test cf-d on the Ubuntu Bionic stemcell.

## Triggers

This pipeline is automatically triggered when new Bionic stemcells are published, or when a cf-d commit passes through the cf-deployment CI to be promoted to the `release-candidate` branch.

## Cleanup

If the pipeline succeeds, then it will clean up the CF BOSH deployment after itself. The bbl environment is "stable-bellatrix" and is managed by the "infrastructure" pipeline:
https://concourse.wg-ard.ci.cloudfoundry.org/teams/main/pipelines/infrastructure?group=stable-bellatrix

## Pipeline Management

This pipeline is managed directly by the `ci/pipelines/bionic-stemcell.yml` file and the `ci/configure` script. To update the pipeline, run `ci/configure bionic-stemcell`.
