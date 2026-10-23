# resolute-stemcell

Test CF-Deployment on the Ubuntu Resolute stemcell.

## Triggers

This pipeline is automatically triggered when new Resolute stemcells are
published to https://bosh.io/stemcells/#ubuntu-resolute repository, or
when a commit is promoted to the `release-candidate` branch after passing
through the CF-Deployment CI.

## Cleanup

If the pipeline succeeds, then it will clean up the CF BOSH deployment after itself.

## Pipeline Management

This pipeline is managed directly by the `ci/pipelines/resolute-stemcell.yml` file and the `ci/configure` script. To update the pipeline, run `ci/configure resolute-stemcell`.
