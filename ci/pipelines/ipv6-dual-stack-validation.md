# noble-stemcell

Test cf-d for IPV6 dual stack.

## Triggers

This pipeline is automatically triggered for a develop branch.

## Cleanup

If the pipeline succeeds, then it will clean up the CF BOSH deployment after itself.

## Pipeline Management

This pipeline is managed directly by the `ci/pipelines/ipv6-dual-stack-validation.yml` file and the `ci/configure` script. To update the pipeline, run `ci/configure ipv6-dual-stack-validation`.