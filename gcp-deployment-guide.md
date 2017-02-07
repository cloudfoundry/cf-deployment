# Using `cf-deployment` With GCP
This document contains IaaS-specific notes and instructions for using `cf-deployment` with GCP. See the main [README](https://github.com/cloudfoundry/cf-deployment/blob/master/README.md) for more general information about `cf-deployment`.

## Resources
- [`bbl`](https://github.com/cloudfoundry/bosh-bootloader):
sets up IaaS and deploys a BOSH director
- [cf-deployment-concourse-tasks](https://github.com/cloudfoundry/cf-deployment-concourse-tasks):
contains concourse tasks
for
`bbl`ing up an environment
and
deploying cf-deployemnt.
**Make sure to lock your version
to `1.*`.
If we make any breaking changes,
we'll bump the major version.**
- Example pipeline: [nats.yml](https://github.com/cloudfoundry/runtime-ci/blob/master/pipelines/nats.yml).
This is a pipeline that we built
to test the nats-release.
You should be able to use it
for inspiration in constructing your own pipelines
that use your release and cf-deployment.

## Step-by-step guide for deploying by hand

### Get yourself a working director with `bbl`

To deploy a BOSH director on GCP with `bbl`,
you'll need to provide certain information,
either as an environment variable
or
as a flag argument to `bbl up`:
- `BBL_IAAS` or `--iaas=gcp`:
set this to `gcp`
- `BBL_GCP_PROJECT_ID` or `--gcp-project-id`:
The value should match the name of your GCP project.
- `BBL_GCP_SERVICE_ACCOUNT_KEY` or `--gcp-service-account-key`:
Path to the service account key file (something like `my-project.json`)
- `BBL_GCP_REGION` or `--gcp-region`:
GCP region. It should have at least 3 zones in it
(for example, `us-central1` or `us-east1`).
- `BBL_GCP_ZONE` or `--gcp-zone`:
Any of the zones in your specified region. This gets used to place the BOSH director.

So, your command may look like this:
```
bbl up \
  --iaas gcp \
  --gcp-project-id my-project \
  --gcp-service-account-key my-project.json \
  --gcp-region us-central1 \
  --gcp-zone us-central1-a
```

#### Load balancers
`bbl` will also set up your load balancers for you.
You can run `bbl create-lbs`,
which takes the following parameters,
but only as command line flags:
- `--type`:
Tells `bbl` which set of load balancers to create.
Possible values are `concourse` and `cf` (use `cf`).
- `--domain`:
The domain that will resolve to your load balancer. In CF parlance, it typically matches your `system_domain`.
- `--cert`:
A path to a file with a PEM-encoded SSL certificate.
Remember that the cert should be valid for whichever domain you specify in the `--domain` flag.
- `--key`:
A path to a file with a PEM-encoded SSL key that corresponds to the cert provided in `--cert`.

#### Do it with Concourse
We've shipped a [Concourse task](https://github.com/cloudfoundry/cf-deployment-concourse-tasks/tree/master/bbl-up)
for running `bbl up` and `bbl create-lbs`.
Because Concourse tasks use environment variables for parameters,
we transparently pass the appropriate parameters for `bbl up`.
For `bbl create-lbs`,
you can use the following environment variables,
which will get translated appropriately to flag arguments:
- `BBL_LB_CERT`:
The **contents** (not the path) of the PEM-encoded cert.
- `BBL_LB_KEY`:
The **contents** (not the path) of the PEM-encoded key.
- `LB_DOMAIN`

Here's an example:
```
- task: setup-infrastructure
  file: cf-deployment-concourse-tasks/bbl-up/task.yml
  params:
    BBL_IAAS: gcp
    BBL_GCP_SERVICE_ACCOUNT_KEY: google_account_creds.json
    BBL_GCP_PROJECT_ID: my-gcp-project
    BBL_GCP_REGION: us-central1
    BBL_GCP_ZONE: us-central1-a
    BBL_LB_CERT: |
      -----BEGIN CERTIFICATE-----
      ...
    BBL_LB_KEY: |
      -----BEGIN RSA PRIVATE KEY-----
      ...
    LB_DOMAIN: my-gcp-project.cf-app.com
```

#### Save `bbl-state.json`
However you run `bbl` (command line or with Concourse),
the side-effect of a successful bbl command is the creation/update of `bbl-state.json`.
As a deployer, **you must persist this file somehow.**

Currently, our Concourse tasks assume
that you want to check this file into a private git repo.
We'll likely prioritize work soon
to persist that file to a more secure location such as Lastpass.


### Deploying CF
1. Upload the current stemcell for `cf`
by running the command below with the appropriate version number.
The version number is specified on the last line of `cf-deployment.yml`.
  ```
  bosh upload stemcell https://bosh.io/d/stemcells/bosh-google-kvm-ubuntu-trusty-go_agent?v=VERSION
  ```
1. Check that you can generate a final manifest without errors (from inside the cf-deployment directory)
  ```
  bosh -n interpolate --vars-store cf-deployment-vars.yml -o operations/gcp.yml --var-errs cf-deployment.yml
  ```
1. Deploy!
   ```
   bosh \
     -e TARGET_DIRECTOR \
     -n \
     -d cf \
     deploy \
     --vars-store=cf-deployment-vars.yml \
     -v system_domain=YOUR_SYSTEM_DOMAIN \
     -o operations/gcp.yml \
     cf-deployment.yml
   ```

1. Save the `cf-deployment-vars.yml` file somewhere safe.  We use a private git repository for this purpose, but some choose instead to store it in a secure storage service such as LastPass.  You will need to reuse it if you want to update your cf deployment without rotating credentials.

#### Do it with Concourse
As we did with `bbl-up`,
we've shipped a [Concourse task](https://github.com/cloudfoundry/cf-deployment-concourse-tasks/tree/master/bosh-deploy)
for deploying cf-deployment.
The task uses `bbl-state.json` as an input
in order to target and login to the correct director.


#### Using your dev release with cf-deployment
The more interested Concourse task is
[bosh-deploy-with-created-release](https://github.com/cloudfoundry/cf-deployment-concourse-tasks/tree/master/bosh-deploy-with-created-release).
This task takes an additional release repository as an input,
builds a dev release from that repo,
and
uploads it to the bosh director.
It also applies an ops file
that ensures that the director uses the dev release
instead of `latest`.

Here's an example:
```
- task: deploy-cf-with-created-release
  file: cf-deployment-concourse-tasks/bosh-deploy-with-created-release/task.yml
  input_mapping:
    bbl-state: my-env-bbl-state
    release: my-release
    ops-files: cf-deployment
    vars-store: my-env-vars-store
  params:
    SYSTEM_DOMAIN: my-env.cf-app.com
  ensure:
    put: my-env-vars-store
    params:
      repository: updated-vars-store
      rebase: true
```
