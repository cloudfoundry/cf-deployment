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

Technically speaking, `cf-deployment.yml` is a manifest template that requires one additional step of environment-specific configuration, mostly for credentials and system domain. To do this we use the `-l`/`--var-files` flags in the new BOSH CLI. These flags read in a `.yml` file and use configuration present there to fill out the template provided by `cf-deployment`.

The easiest way to get a file for deployment variables is to generate them with [cf-filler](https://github.com/rosenhouse/cf-filler). It's a go binary that generates a yaml file with all of the necessary variables to populate the template in cf-deployment.

## Dependencies and assumptions

### BOSH CLI

`cf-deployment` requires that a deployer use the new [BOSH CLI](https://github.com/cloudfoundry/bosh-cli). The tool is still technically in alpha, but it has the features necessary to consume `cf-deployment`.

### BOSH `cloud-config`

`cf-deployment` also assumes that a deployer has already uploaded a [cloud-config](http://bosh.io/docs/cloud-config.html) to the BOSH director.
