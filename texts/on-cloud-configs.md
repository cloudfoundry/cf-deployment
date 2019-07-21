# On Cloud Configs
`cf-deployment` is developed against `bbl`.
This allows us to delegate the particulars
of the director's [Cloud Config][bosh-docs-cloud-config].
However, `cf-deployment` does not _require_ `bbl`.

This document discusses what `cf-deployment` requires
of any Cloud Config intended to work with it.
The discussion here is not exhaustive,
and is not under test.
Nonetheless, we intend it to support
those wishing to use `cf-deployment` without `bbl`.

## General Resources
The [BOSH docs for Cloud Config][bosh-docs-cloud-config]
are a great starting-place.
You may find the CPI-specific `cloud_properties` references
linked throughout to be useful.

`bbl` has [fixtures][cloud-config-fixtures]
for each `bbl`-supported IaaS.
These can be useful examples.
Anything `cf-deployment` draws from the Cloud Config
will be present among these fixtures.

If you're having trouble with a specific question,
please feel free to join the Cloud Foundry Slack,
and ask us in the `#cf-deployment` channel.

We have some [example cloud configs](/iaas-support/README.md)
in this repository
that may be useful as a starting point.

## VM Types
`cf-deployment` uses three VM types.
Here are their names
and approximate resources:

- minimal: this is sufficient for most things.
  1 vCPU and ~4 GB RAM
- small: our API instances can benefit from some additional resources.
  2 vCPUs and ~8 GB RAM.
- small-highmem: diego cells need the memory to run apps.
  4 vCPUs and ~32 GB RAM.

It is important to note that all of these
have a 10 GB Ephemeral disk associated by default.
`cf-deployment` has encountered issues in the past
when attempting to use ephemeral disks
smaller than that.

## VM Extensions
We use VM Extensions to manage
non-default ephemeral disk sizes
and `cloud_properties` related to load balancing.

In particular, we generally require:
- `50GB_ephemeral_disk`
- `100GB_ephemeral_disk`
- `cf-router-network-properties`
- `cf-tcp-router-network-properties`
- `diego-ssh-proxy-network-properties`

While the disk extensions are straightforward,
load balancing is one of the details
that varies most between IaaSs,
so this may be one of the trickier parts
of writing your own Cloud Config.

On vSphere, which lacks load balancing,
you can include the LB vm extension names
without any cloud properties.
You'll still have to solve load balancing,
but this satisfies the manifest's need
for these VM extensions.

## Disk Types
`cf-deployment` requires the following disk types:

```
disk_types:
- disk_size: 5120
  name: 5GB
- disk_size: 10240
  name: 10GB
- disk_size: 100240
  name: 100GB
```

## Networks
The network name `default`
is used throughout `cf-deployment`.
VMs on this network should be able to reach one another.
If Cloud Foundry is expected to be able to reach the internet,
this network will need some kind of NAT solution.
For example:
- On GCP, we assign an ephemeral external IP
  to each instance.
- On AWS, we have a NAT box
  and a corresponding routing rule
  which sends internet-bound traffic to it.

[bosh-docs-cloud-config]: https://bosh.io/docs/cloud-config.html
[cloud-config-fixtures]: https://github.com/cloudfoundry/bosh-bootloader/tree/master/cloudconfig/fixtures
