# jammy-stemcell

Test cf-d on the Ubuntu Jammy stemcell.

## Triggers

This pipeline is automatically triggered when new jammy stemcells are published, or when a cf-d commit passes through the cf-deployment CI to be promoted to the `release-candidate` branch.

## Cleanup

If the pipeline succeeds, then it will cleanup after itself.

If the pipeline fails then there will be an orphaned Toolsmiths environment. This is by design so that we can examine the pipeline to determine the causes of any failure. In this situation, an environment can be manually unclaimed with the `unclaim-env-manual` job.

## Pipeline Management

This pipeline is managed directly by the `ci/pipelines/jammy-stemcell.yml` file and the `ci/configure` script. To update the pipeline, run `ci/configure jammy-stemcell`.