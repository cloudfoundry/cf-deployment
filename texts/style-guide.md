### Editorial Style Guide
Please observe the following conventions when contributing to `cf-deployment`.
We are likely to revert/reject commits and PRs which don't.
In general, every line of `cf-deployment.yml` should be clear,
necessary for a correctly functioning default deployment,
and explicable.
Maximizing the legibility and minimizing the size of `cf-deployment.yml` are high priorities.
Features under development and optional extensions should be added/enabled via ops files.

1. Don't use global properties.
  1. To maximize the readability of properties that must be set on many jobs,
  create a clearly named YAML anchor at the first occurrence of the duplicate properties,
  then reference that anchor as necessary.
  1. Duplication and the use of YAML anchors indicate properties which _should_ be provided/consumed by Releases using BOSH links, but aren't yet.
1. Don't include any property in `cf-deployment.yml`
which is not necessary for every user of the default configuration.
  1. Don't include any property in `cf-deployment.yml`
  for which a usable default exists in the spec of the job's release.
  1. Don't include properties in `cf-deployment.yml`
  as targets for ops files.
  Ops files can be used to add needed properties.
1. Any nominally variable property value
which can be safely hardcoded in `cf-deployment.yml` should be.
Usernames, for example.
1. Any property value
which isn't necessary for every user of the default configuration to specify
should be exposed via ops-files, not vars.
1. Properties which must be set to reflect IaaS-sensitive contextual conditions,
such as the relationship between networks and AZs,
should assume GCP and be set appropriately for other IaaSs in an ops file.
1. Ops files included in the `cf-deployment` repo should not overlap.
That is, they should be order-independent, and not address the same properties.
If this is not possible, their order must be documented.
1. All credentials should be bosh-generatable.
When adding new passwords, secrets, certs, CAs, and keys, add them to the `variables` section of the manifest.
Use the existing variables as a guide for the details necessary to allow bosh to perform credential generation.
When testing new credential properties, test with bosh-generated values.
