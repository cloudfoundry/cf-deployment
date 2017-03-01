# On Bosh Job Specs
We expect some things about the job specs 
in the bosh releases `cf-deployment` specifies.
Our expectations are not always met.
When this happens,
after the grief,
and whatever work it causes,
we often realize the release authors
had no way of knowing what we expected.

We would like to change that.

The Cloud Foundry project's method
for achieving alignment around standards
is rooted in a blend of opinionated tools
shared ideals and heuristics,
and explicit coordinative communication.
It is not terribly surprising
that as our tools and their opinions change
alignment destabilizes.
Neither is it a surprise
that the implications of shared ideals and heuristics
tend to differ along with the tools and priorities
shaping the worldview of their executors.

This, then, is an effort to express
our heuristics and our tools influences on them,
not just our resulting expectations.

The way job specs have been handled
up until now
is the way it is
because it got that way
There's a long and reasonable history
rooted in a single team
managing a single repo
with jobs that often drew
from a single set of global properties,
and lived alongside manifest generation code
setting those properties.

This is a legacy of `cf-release`
and its manifest generation process.
Some of the expectations coming from the
experiences from this work
have been previously explicitly communicated,
like **Defaults Should Live in the Spec**.
We still hold this to be true,
but it is differently true
for jobs that see themselves as
inherently part of Cloud Foundry
than for those that see themselves
as able to exist apart
from an integrated deployment.
As teams have undergone
the glorious mitosis inherent in
an organization that takes both
Conway's Law
and a services architecture
seriously,
more components have come to see themselves
as able to exist apart.

This is an example of the changing norms
behind some of our expectations.
We now expect release authors in CF
to specify defaults in the spec for the
_generic_
operation of their jobs.
Settings that would be sensible defaults
for Cloud Foundry
are not always the right choice for a job spec.

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

