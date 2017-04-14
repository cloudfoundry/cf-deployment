# On Bosh Job Specs


The goal of this document is to articulate expectations
-- as well as the ideas and heuristics from which we derive them --
for job specifications
in the BOSH releases
included in cf-deployment.

Opinions about BOSH releases have been influenced by tools like BOSH and spiff,
as well as by our ideals about deployment and software development.
We often enforce these ideas by using opinionated tools,
but we also enforce these goals by explicitly coordinating between CF teams.
When new tooling -- with different opinions -- comes along,
and teams grow to the point where coordination becomes difficult,
teams lose alignment on what constitutes a best practice.
We hope that a document like this
will help to realign release authors.

A lot of our existing standards were derived in a time
when a single team maintained a single release
that also contained tools for manifest generation.
Now that we have many teams contributing to several BOSH releases,
and manifest generation has been separated into this repo,
it's time to update our standards,
keeping in mind updates to tooling like the new BOSH CLI.

- For example, the standard that **Defaults should live in the Spec** has existed for some time.
We continue to maintain this expectation, with a caveat:
releases that may be deployed independently of CF
should have defaults in their spec
that make sense for their standalone deployment.
In these cases, cf-deployment should override those defaults
in favor of CF-friendly values.

## Expectations
This is an initial list of headings,
intended to be filled in with examples
and explanations
as they occur to us
or become necessary.

### About Defaults
#### Specs Contain Appropriate Defaults for Standalone Operation
#### Specs Do Not Specify Defaults for Any Credentials
### About Descriptions
#### Spec Property Descriptions Include Constraints on the Value of the Property
### About Names and Paths
#### New Properties Are Not Namespaced To Their Job
#### New TLS Propeties Match The Credhub Data Structure For Certs
### About the Relationship of Specs to Other Things
#### Job Specs Constitute Some or All of the API of a BOSH Release for Versioning Purposes
