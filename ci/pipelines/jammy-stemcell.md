# jammy-stemcell

Backward-compatibility pipeline ensuring `cflinuxfs4` keeps working on the
Ubuntu **Jammy** stemcell after the base `cf-deployment.yml` default stack
migrates to `cflinuxfs5`.

The default stack is explicitly pinned to `cflinuxfs4` via
[`set-cflinuxfs4-default-stack.yml`](../../operations/set-cflinuxfs4-default-stack.yml)
so the pipeline remains meaningful even after the fs5 flip.


## Triggers

This pipeline is automatically triggered when new Jammy stemcells are published to https://bosh.io/stemcells/#ubuntu-jammy repository, or when a cf-d commit passes through the cf-deployment CI to be promoted to the `release-candidate` branch.

## Cleanup

If the pipeline succeeds, then it will clean up the CF BOSH deployment after itself.

## Pipeline Management

This pipeline is managed directly by the `ci/pipelines/jammy-stemcell.yml` file and the `ci/configure` script. To update the pipeline, run `ci/configure jammy-stemcell`.