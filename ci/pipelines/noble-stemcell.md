# noble-stemcell

Test cf-d on the Ubuntu Noble stemcell.

## Triggers

This pipeline is automatically triggered when new Noble stemcells are published to https://bosh.io/stemcells/#ubuntu-noble repository, or when a cf-d commit passes through the cf-deployment CI to be promoted to the `release-candidate` branch.

## Cleanup

If the pipeline succeeds, then it will clean up the CF BOSH deployment after itself.

## Pipeline Management

This pipeline is managed directly by the `ci/pipelines/noble-stemcell.yml` file and the `ci/configure` script. To update the pipeline, run `ci/configure noble-stemcell`.