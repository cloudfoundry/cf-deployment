# cf-deployment
**This repo is still under initial development. This document describes the intended purpose and use of resources in this repo, but may not live up to those promises until we remove this warning. Having said that, we'd love for members of the CF community to try cf-deployment and give us feedback. Github issues welcome. Find us on the #cf-deployment channel in the cloudfoundry Slack.**

CI pipeline [here](https://runtime.ci.cf-app.com/teams/main/pipelines/cf-deployment).

Please make pull requests against the `develop` branch.

## Purpose
This repo contains a canonical manifest for deploying Cloud Foundry without the use of `cf-release`, relying instead on individual component releases. It will replace the [manifest generation scripts in cf-release](https://github.com/cloudfoundry/cf-release/tree/master/templates) when `cf-release` is deprecated. It uses several newer features of the BOSH director and CLI. Older directors may need to be upgraded and have their configurations extended in order to support `cf-deployment`.

`cf-deployment` embodies several opinions about Cloud Foundry deployment. It:

- prioritizes readability and meaning to a human operator.
  - All properties are set in the jobs which use them. Global properties are not used.
  - YAML Anchors with human-friendly names are used where the need for duplication has not yet been obviated by BOSH links.
  - Properties are ordered to maximize navigability and present the most useful and important information first.
  - Only necessary configuration is included. Any release default that can safely be used, is. Any properties which can be consumed via BOSH links, are.
- enables TLS/SSL features on every job which supports TLS.
- uses three AZs, of which two are used to provide redundancy for most instance groups. The third is used only for instance groups that should not have even instance counts, such as etcd and consul.
- uses Diego natively, does not support DEAs, and enables diego-specific features such as ssh access to apps by default.
- deploys jobs to handle platform data persistence, using the cf-mysql release for databases and the CAPI release's WebDAV job for blob storage.
- assumes load-balancing will be handled by the IaaS.
- assumes GCP as the default deployment environment. For use with other IaaSs, see the **Ops Files** section below.

# Usage
To deploy to a configured BOSH director using the new `bosh` CLI:

```
export SYSTEM_DOMAIN=some-domain.that.you.have
bosh -e my-env -d cf deploy cf-deployment/cf-deployment.yml [ -o opsfiles/CUSTOMIZATION1 ] [ -o opsfiles/CUSTOMIZATION2 (etc.) ] --vars-store env-repo/deployment-vars.yml -v system_domain=$SYSTEM_DOMAIN
```

See the rest of this document for more on the new CLI, deployment vars, and configuring your BOSH director.

# Setup and Prerequisites
`cf-deployment` relies on newer BOSH features, and requires a bosh director with a valid cloud-config that has been configured with a certificate authority. It also requires the new alpha `bosh` CLI, which it relies on to generate and fill-in needed variables.

- If you are deploying to GCP, please use `gcp-deployment-guide.md`, also located in this directory. (`bbl` support for GCP is coming soon.)
- If you are deploying to AWS, please use `bbl`, the bosh-bootloader, to prepare your environment.
- If you are deploying to bosh-lite, please see the example below under **Deploying to `bosh-lite`**.

## BOSH CLI
`cf-deployment` requires the new [BOSH CLI](https://github.com/cloudfoundry/bosh-cli). It's in alpha, but has features necessary to use `cf-deployment`.

## BOSH `cloud-config`
`cf-deployment` assumes that you've uploaded a compatible [cloud-config](http://bosh.io/docs/cloud-config.html) to the BOSH director. The cloud-config produced by `bbl` is compatible by default. For IaaSs not supported by `bbl`, please refer to our IaaS-specific advice in the **Setup and Prerequisites** section above. If your IaaS is not listed there, we have not yet tested cf-deployment with it, and you may need to do some engineering work to figure out the right cloud config (and possibly ops files) to get it working for `cf-deployment`.

## Deployment variables
`cf-deployment.yml` requires additional data to provide environment-specific or sensitive configuration such as the system domain and various credentials. To do this we use the `--vars-store` flag in the new BOSH CLI. This flag takes the name of a `yml` file that it will read and write to to generate or use certs, keys, and variables.  Where those values are not present, it will generate new values based on the type information stored in `cf-deployment.yml`.

## Ops Files
The configuration of CF represented by `cf-deployment.yml` is intended to be a workable, secure, fully-featured default. When the need arises to make different configuration choices, we accomplish this with the `-o`/`--ops-file` flags. These flags read a single `.yml` file that details operations to be performed on the manifest before variables are generated and filled. We've supplied some common manifest modifications in the `opsfiles` directory. Here's a brief summary:

- `opsfiles/disable-router-tls-termination.yml` - this file eliminates keys related to performing tls/ssl termination within the gorouter job. It's useful for deployments where tls termination is performed prior to the gorouter - for instance, on AWS, such termination is commonly done at the ELB. This also eliminates the need to specify `((router_ssl_cert))` and `((router_ssl_key))` in the var files.
- `opsfiles/change-logging-port-for-aws-elb.yml` - this file overrides the loggregator ports to 4443, since it is required under AWS to have a separate port from the standard HTTPS port (443) for loggregator traffic in order to use the AWS load balancer.
- `opsfiles/gcp.yml` - this file overrides the static IP addresses assigned to some instance groups, as GCP networking features allow them to all co-exist on the same subnet despite being spread across multiple AZs.

# Deploying to `bosh-lite`
To deploy to bosh-lite:

```
bosh -e lite update-cloud-config bosh-lite/cloud-config.yml
bosh -e lite -d cf deploy cf-deployment.yml -o opsfiles/bosh-lite.yml --vars-store deployment-vars.yml -v system_domain=bosh-lite.com
```

# Contributing
Changes to `cf-deployment` should be made on the `develop` branch. Pull requests should be based on `develop`, as well.

We ask that pull requests and other changes be successfully deployed, and tested with the latest sha of CATs.

## CI
The [ci](https://runtime.ci.cf-app.com/teams/main/pipelines/cf-deployment) for `cf-deployment` automatically bumps to the latest versions of its component releases on the `develop` branch. These bumps, along with any other changes made to `develop`, are deployed to a single long-running environment and tested with CATs before being merged to master if CATs goes green. There is not presently any versioning scheme, or way to correlate which version of CATs is associated with which sha of cf-deployment, other than the history in CI. As `cf-deployment` matures, we'll address versioning. The configuration for our pipeline can be found [here](https://github.com/cloudfoundry/runtime-ci/pipelines/cf-deployment.yml).

## Editorial Style Guide
Please observe the following conventions when contributing to `cf-deployment`. We are likely to revert/reject commits and PRs which don't. In general, every line of `cf-deployment.yml` should be clear, necessary for a correctly functioning default deployment, and explicable. Maximizing the legibility and minimizing the size of `cf-deployment.yml` are high priorities. Features under development and optional extensions should be added/enabled via ops files.

1. Global properties shouldn't be used.
  1. To maximize the readability of properties that must be set on many jobs, create a clearly named YAML anchor at the first occurrence of the duplicate properties, then reference that anchor as necessary.
  1. Duplication and the use of YAML anchors indicate properties which _should_ be provided/consumed by Releases using BOSH links, but aren't yet.
1. Don't include any property in `cf-deployment.yml` which is not necessary for every user of the default configuration.
  1. Don't include any property in `cf-deployment.yml` for which a usable default exists in the spec of the job's release.
  1. Don't include properties in `cf-deployment.yml` as targets for ops files. Ops files can be used to add needed properties.
1. Any nominally variable property value which can be safely hardcoded in `cf-deployment.yml` should be. Usernames, for example.
1. Any property value which isn't necessary for every user of the default configuration to specify should be exposed via ops-files, not vars.
1. Properties which must be set to reflect IaaS-sensitive contextual conditions, such as the relationship between networks and AZs, should assume GCP and be set appropriately for other IaaSs in an ops file.
1. Ops files included in the `cf-deployment` repo should not overlap. That is, they should be order-independent, and not address the same properties. If this is not possible, their order must be documented.

