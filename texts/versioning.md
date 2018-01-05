# Versioning cf-deployment

One of the goals for cf-deployment
is to provide a meaningful versioning scheme
for Cloud Foundry operators.

In the past,
[cf-release](https://github.com/cloudfoundry/cf-release)
was versioned with a single number
that didn't provide the operator with any meaningful information.
For example,
the cf-release versions did not indicate
the size or nature of the delta between cf-release versions,
that an upgrade could be done without concerns about backwards compatibility,
or whether a deployer could automatically update to the new version.

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
> MAJOR version when you when you make incompatible API changes.

For cf-deployment,
the "API" we consider
is the ability of the operator to deploy.
If updates to cf-deployment require manual steps
from the operator
-- for example, to use a different deploy command
or to perform out-of-band setup --
then we will bump the major version.

As noted earlier,
the Cloud Foundry team values the ability
to deploy continuously.
As a result,
we intend not to make backwards-incompatible changes
without plenty of consideration
or without good reason.
Still,
we don't want to treat major version bumps
as something precious,
and we'll allow them when they're necessary.
We'll strive to make sure
that we provide detailed documentation with major version bumps.

### Minor versions
> MINOR version when you add functionality in a backwards-compatible manner,

This will be the most common change to cf-deployment.
Minor bumps will include new or updated functionality
that does not affect the operator's ability to deploy continuously.
Changes of this sort would include:
- Release or stemcell updates
- Manifest configuration that enables new features
- New or updated ops-files

These updates can be deployed automatically,
without manual intervention of any kind,
including updates to the operators deploy command.

### Patch versions
> PATCH version when you make backwards-compatible bug fixes.

Based on the way our testing pipeline works,
it's typically likely that bug fixes will be wrapped up
with changes that add functionality.
As such, bug fixes will often be made in minor,
rather than patch,
bumps.
Still, we may use patch versions
to encode small fixes that don't include new functionality.
One possible use for patch version updates
might be backported security fixes for older versions of cf-deployment.


### Versioning and Ops-files
Maintaining a stable interface for user-defined ops-files will be very difficult.
Essentially, we have to ensure that _nothing_ changes with regards to
the visible manifest structure
or
even with the structure of properties as defined by releases.

We can start with the following guarantee:
moving jobs into new instance groups will prompt a major version bump.

## On the language of versioning
While cf-release is still king,
it's common to hear people refer to version of cf-release as the "Cloud Foundry version"
-- for example, someone might ask,
"What version of Cloud Foundry are you running?"
A well-understood response would be,
"I'm running v264."

It may seem odd to suddenly "downgrade" to version `v1.0.0`
when cf-deployment is promoted to the preferred manifest.
During the twilight where both cf-release and cf-deployment
are viable deployment mechanisms,
we'd simply suggest that people be specific:

> "I'm running cf-release v264."
>
> "Oh, I'm running cf-deployment v1.2.0"

Once cf-release is left on the ash heap of history,
it seems reasonable that people might refer to cf-deployment versions
as their "Cloud Foundry version."
(Of course, everyone should remember
  that we're likely to iterate.
  In some years' time,
  cf-deployment could be replaced as well.)
