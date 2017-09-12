# Discussion for issues and new features for cf-deployment and BOSH

## Purpose
As people are starting to use cf-deployment,
we're beginning to get feedback from operators regarding their use of the manifest.
Often, the issues boil down to feature requests and/or feedback for BOSH.
We want to use this doc as a place to track those issues and discuss solutions that work for both teams.

## Open discussion

### Link standardization

**BOSH story**: https://www.pivotaltracker.com/story/show/150867154

One of the most common issues we're finding is
that we can't use links as effectively as we'd like to.
The big obstacle is that releases provides links in different formats.
For example, postgres-release and cf-mysql-release both provide a link of type `database`,
but they represent their properties differently:
cf-mysql-release has `cf_mysql.mysql.port`
and postgres-release has `databases.port`,
so we can't consume the port via link.
The same applied for other configuration, including credentials.

We can we build a standard for a `database` link?
Only by convention?
Or can BOSH enforce certain properties in a link,
like a Golang interface?
It would probably help if BOSH could provide a way to rename properties for the purpose of link.
For example:
```
- name: mysql-database
  type: database
  properties:
  - name: port
    source: cf_mysql.mysql.port
```

Also, how do links account for external connections?
For example, database links allow connections to databases that are also bosh-deployed,
but how can use links to configure components to connect to an RDS instance?

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
As a data point, when people apply multiple ops-files, it's not always easy to figure out after the fact which ops-files were applied:
> Another thing that came up was that it'd be awesome if there was a tool that could tell me what ops files I used to deploy and what order they were in.

Another example of this complication is the network name.
After working on an ops-file to variable-ize the network name so that operators could override it,
we realized that many other ops-files assume the use of a particular network name (specifically, `default`).
Do we need to create a different version of all those ops-files that variable-izes the network name?
It also seems like this could be solved with a variable that has a default value (as described above),
or maybe simply allowing aliases for network names.

From CAPI:
> We've had some issues with ops files where we have an ops file out of order, and it has taken a long time to trace through all of the ops files in order to see what was overriding what.
> It'd be great if order could somehow not matter and/or there was a way for us to see which ops files overwrite which attributes.

#### Wildcard paths in operations
[This Github issue](https://github.com/cloudfoundry/cf-deployment/issues/190#issuecomment-320203780)
captures the idea pretty well.

#### Injecting into an array
If someone wants to write an ops-file that adds a new instance group,
their only option is to append to the list of instance groups.
Because BOSH deploys instance groups in order,
we need a way to inject a new instance group at a certain index in the array.
- https://github.com/cloudfoundry/cf-deployment/issues/223
**Update**: This issue is on the BOSH team's radar: https://github.com/cppforlife/go-patch/issues/11

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
**Update**: We think the best way forward for this is to
have a job like CC provide all of its configuration via a link,
and have the worker and clock consume that link to avoid duplication.

Also, some configuration there is user-provided
(specifically `app_domains`).
Should that be shared via link?
**Update**: See above.

What about configuration such as the metron agent,
which doesn't have an obvious candidate for an "owner" of the configuration?
How can tighten that configuration?
Does a runtime-config make the most sense?
A notion of a global link?
**Update**: We could use a deployment-level link: https://www.pivotaltracker.com/epic/show/3733664

### Seed values for BOSH jobs that allow that as configuration

**BOSH epic**: https://www.pivotaltracker.com/epic/show/3733649

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

### BOSH Director and CLI comaptibility
It would be great if we didn't have to maintain a compatibility matrix for director and CLI versions.
Could we encode this in the manifest somehow?
When we update the manifest with changes that depend on new versions of the CLI,
users get unintelligible errors and we have to broadcast communication to the entire community.
