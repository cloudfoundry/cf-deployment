# Discussion for issues and new features for cf-deployment and BOSH

## Purpose
As people are starting to use cf-deployment,
we're beginning to get feedback from operators regarding their use of the manifest.
Often, the issues boil down to feature requests and/or feedback for BOSH.
We want to use this doc as a place to track those issues and discuss solutions that work for both teams.

## Open discussion

### Values that could be configurable, but also have easy defaults
There are values in deployment manifests
that could have pretty standard defaults,
but that users may also want to override.
Feedback suggests that, in some cases, ops-files are a heavy handed solution to the problem.
One user asked to allow spiff-integration with cf-deployment to achieve this.

Examples for this include:
- Usernames
- Instance counts
- Widely-used values like deployment name or network name

This would especially helpful for deployers who are migrating to cf-deployment from cf-release.
These deployers have existing values that may be at odds with the defaults chosen by cf-deployment.

### Ops-files

#### Ops-files stepping on each other's toes
In [this issue](https://github.com/cloudfoundry/cf-deployment/issues/96),
we see that ops-files that mutate certain lower layers of the deployment
can cause problems with other ops-files
that want to update those values as well.
In this case,
one ops-file swapped MySQL with Postgres;
other ops-files that assume the use of MySQL will break,
so we've had to duplicate ops-files with a `-postgres` suffix.
There's another example [here](https://github.com/cloudfoundry/cf-deployment/issues/174).

Another factor is that we want to provide ops-files that "just work",
but we sometimes want to re-use logic from other ops-files to that.
For example, the [bosh-lite ops-file](https://github.com/cloudfoundry/cf-deployment/blob/master/operations/bosh-lite.yml)
tries to scale down the number of instances
as well as make the necessary changes to work with the Warden CPI.
It turns out that the scale-down logic is duplicated with
the [single-AZ ops-file](https://github.com/cloudfoundry/cf-deployment/blob/master/operations/scale-to-one-az.yml).

Could we "import" other ops-files?
Define a list of ops-files that are applied in-order?
Others have suggested [allowing the use of globs](https://cloudfoundry.slack.com/archives/C0FAEKGUQ/p1502153559284207).

Another example of this complication is the network name.
After working on an ops-file to variable-ize the network name so that operators could override it,
we realized that many other ops-files assume the use of a particular network name (specifically, `default`).
Do we need to create a different version of all those ops-files that variable-izes the network name?
It also seems like this could be solved with a variable that has a default value (as described above),
or maybe simply allowing aliases for network names.

#### Wildcard paths in operations
[This Github issue](https://github.com/cloudfoundry/cf-deployment/issues/190#issuecomment-320203780)
captures the idea pretty well.


### Updating job topology
[This issue](https://github.com/cloudfoundry/cf-deployment/issues/179)
gives a good example.

Without a `move` operation in ops-files,
it's difficult to change your colocation strategy.
It seems we either need `move`,
or some other way to more easily change the default topology defined in cf-deployment.

### Sharing configuration across jobs
Some jobs use duplicate configuration.
[This Github issue](https://github.com/cloudfoundry/cf-deployment/issues/190)
points out a few examples jobs that share configuration.

In some cases, the issue might be solved simply with links,
but there are also edge cases.
In the example above,
the amount of shared configuration is enormous.
Does it still make sense to share configuration via link?

Also, some configuration there is user-provided
(specifically `app_domains`).
Should that be shared via link?

What about configuration such as the metron agent,
which doesn't have an obvious candidate for an "owner" of the configuration?
How can tighten that configuration?
Does a runtime-config make the most sense?
A notion of a global link?

### Seed values for BOSH jobs that allow that as configuration
Some jobs allow operators to provide seed values in the manifest.
Different jobs have different behavior about how those seed value can change.
For example, the Cloud Controller job allows deployers to specify "app domains,"
which are really Shared Domains, with one of them (the first?) as a default Shared Domain.
If an operator removes a domain from the list, it doesn't get deleted from the database;
if an operator adds a domain to the list, it gets appended to the database table.

What makes these "seed values," and not merely configuration,
is the fact that these are resources that can be CRUD'ed via API.
As a result, the manifest may not be up-to-date,
and operators shouldn't use the manifest of the source of truth for those values.

The issue is that,
without specifying those seed values in the manifest,
a fresh deploy of cf-deployment will succeed,
but the Cloud Foundry will not operational (i.e. pass CATs)
until an admin creates those resources via the API.

One way to manage this is to create a `bootstrap.yml` ops-file,
that gets applied only on the initial deploy.
The ops-file would provide the seed values
so that cf-deployments "works out of the box,"
but that subsequent attempts to generate the manifest will not contain information
that might be stale.

How else can we solve this issue?

**Sources**:
https://github.com/cloudfoundry/cf-deployment/issues/58
