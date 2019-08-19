# Versioning cf-deployment

One of the goals for cf-deployment
is to provide a meaningful versioning scheme
for Cloud Foundry operators.

## Version Scheme
cf-deployment uses [semantic versioning](https://server.org),
insofar as that scheme makes sense for a deployment manifest.
In this doc, we'd like to lay out
how we intend to use semantic versioning for cf-deployment.

One of the goals of cf-deployment
is promote the idea of continuous deployment.
That is, operators should grow comfortable
with the idea that they can update their deployments
without much process or pomp.
Ideally
-- and we think this is possible most of the time --
operators could deploy most updates automatically,
without any human intervention whatsoever.
To that end,
semantic versioning plays a crucial role.

### Major versions
As the semantic versioning specific states, one should increment:
> MAJOR version when there are incompatible API changes

For cf-deployment,
the "API" we consider
is the ability of the operator to deploy.
If updates to cf-deployment require manual steps
from the operator. Following are examples of breaking changes. This is not a comprehensive list and will revised in the future.

> **Types of breaking changes:**
> - **causes app or operator downtime**
> - modifies, deletes or moves the name of a job or instance group in the main manifest
> - modifies the name or deletes a property of a job or instance group in the main manifest
> - changes the name of credentials in the main manifest
> - requires out-of-band manual intervention on the part of the operator 
> - modifies the ops-file path, changes the type, changes the values or removes ops-files from the followning folders
>    - `./operations/` or `./operations/experimental` 
>    - `./addons`
>    - `./backup-and-restore/`
>    - `./bits-service/`
>
> _If you're promoting an experimental Ops-file (or removing one), Please follow the [Ops-file workflows](https://github.com/cloudfoundry/cf-deployment/blob/master/ops-file-promotion-workflow.md)._

> Ops files changes in the following folders are considered as NON BREAKING CHANGES
> `./community`, `./example-vars-files`, `./test/`, `./workaround`


As noted earlier,
the Cloud Foundry team values the ability
to deploy continuously.
Still,
we don't treat major version bumps
as something precious and allow them as needed to support the continued development of the platform.

### Minor versions
> MINOR version when changes are made in a backwards-compatible manner

This will be the most common change to cf-deployment.
Minor bumps will include new or updated functionality
that does not affect the operator's ability to deploy continuously.
Changes of this sort would include:
- Release or stemcell updates
- Manifest configuration that enables new features
- New or updated ops-files

These updates can be deployed automatically,
without manual intervention.

### Patch versions
> PATCH version when there are backwards-compatible bug fixes

Because there are a large number of teams contributing to cf-deployment independently and asynchronously,
most bug fixes will likely be included with changes that add functionality.
As such, bug fixes will often be published in minor releases rather than patch releases.
Although we may use patch versions
to encode small fixes that don't include new functionality, so far our precedent is to include in minor version bumps.


### Versioning and Ops-files
Maintaining a stable interface for user-defined, custom, ops-files is not a realistic contract to uphold.
Essentially, we'd have to ensure that _nothing_ changes with regards to
the visible manifest structure
or
even with the structure of properties as defined by releases.

We do consider the movement of existing jobs into new instance groups, or the renaming existing jobs, worthy of a major version bump.
