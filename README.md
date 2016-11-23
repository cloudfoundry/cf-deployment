# cf-deployment

#### This repo is still under incubation. This document describes the intended purpose and use of resources in this repo, but may not live up to those promises until we remove this warning. Having said that, we'd love for members of the CF community to try cf-deployment and give us feedback.

## Purpose
This repo contains a canonical manifest for deploying Cloud Foundry. It will replace the [manifest generation scripts in cf-release](https://github.com/cloudfoundry/cf-release/tree/master/templates). It will also contain scripts and other tools for aiding in deployment.

## Usage
To deploy:
```
bosh -e my-env -d cf deploy cf-deployemnt/cf-deployment.yml -l env-repo/deployment-vars.yml
```

## Deployment variables

`cf-deployment.yml` requires additional data to provide environment-specific or sensitive configuration such as credentials and system domain. To do this we use the `-l`/`--var-files` flags in the new BOSH CLI. These flags read in a list of `.yml` files and use values present there to fill out the template represented by `cf-deployment`.

The easiest way to get a file for deployment variables is to generate them with [cf-filler](https://github.com/rosenhouse/cf-filler). It's a go binary that generates a yaml file with all of the necessary variables to hydrate cf-deployment. While the `cf-filler` repo has a recipe for use with `cf-deployment`, this repo also has such a recipe, in the `cf-filler` directory. This recipe is more up-to-date. Upcoming BOSH functionality should obviate the need for this file soon.

## Ops Files
The configuration of CF represented by `cf-deployment.yml` is intended to be a workable, secure, fully-featured default. However, the need occasionally arises to make different configuration choices. We accomplish this with the `-o`/`--ops-file` flags. These flags read a single `.yml` file that details operations to be performed on the manifest before variables are filled. We've packaged some common manifest modifications in the `opsfiles` directory. Here's a brief summary:

- `opsfiles/disable-router-tls-termination.yml` - this file eliminates keys related to performing tls/ssl termination within the gorouter job. It's useful for deployments where tls termination is performed prior to the gorouter - for instance, on AWS, such termination is commonly done at the ELB. This also eliminates the need to specify `((router_ssl_cert))` and `((router_ssl_key))` in the var files.
- `opsfiles/change-logging-port-for-aws-elb.yml` - this file overrides the loggregator ports to 4443, since it is required under AWS to have a separate port from the standard HTTPS port (443) for loggregator traffic in order to use the AWS load balancer.

## Dependencies and assumptions

### BOSH CLI

`cf-deployment` requires that a deployer use the new [BOSH CLI](https://github.com/cloudfoundry/bosh-cli). The tool is still technically in alpha, but it has the features necessary to consume `cf-deployment`.

### BOSH `cloud-config`

`cf-deployment` also assumes that a deployer has already uploaded a [cloud-config](http://bosh.io/docs/cloud-config.html) to the BOSH director.
