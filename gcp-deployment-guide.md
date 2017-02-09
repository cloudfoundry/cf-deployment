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

##### On certificates
Before you can create your load balancers,
you'll need to be able to provide an SSL certificate
for the domain that your load balancers will use.
You might already have one,
especially if you've already used this domain for a previous environment.

If you're deploying a fresh environment with a new domain,
you can generate a self-signed cert.
**Don't forget that the common name should match your system domain**:
```
openssl req -x509 -newkey rsa:2048 -keyout key.pem -out cert.pem -nodes
```

Alternatively, if you want to get a certificate from a trusted Certificate Authority,
you can skip this cert generation step
and provide that certificate directly to the `bbl` command below.

##### Create load balancers
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

##### Update your DNS records to point to your GCP load balancer
The `create-lbs` command will create an NS record in Google's CloudDNS
(in your Google Cloud console, look in `Networking/CloudDNS`).
The data associated with the record will have the following format:
```
ns-cloud-e1.googledomains.com.
ns-cloud-e2.googledomains.com.
...
```
 However you manage your DNS records
(most of the Cloud Foundry dev teams use Route53),
you'll need to update your NS records
(and SOA records, if you have them)
so that they include all of the data from your Google CloudDNS NS record.

For example, in the Route53 case,
simply copy the NS record data from Google CloudDNS described above,
and paste it into the `value` section of the Route53 NS record for your domain.

After a few minutes,
the your system domain should resolve to your GCP load balancer.

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

### Do it all with Concourse
We've also shipped a number of Concourse tasks
to help you with this lifecycle.
The best place to look to understand
how these tasks working
is the `task.yml` for each task,
and
[nats.yml](https://github.com/cloudfoundry/runtime-ci/blob/master/pipelines/nats.yml)
to understand how they fit together.

#### `bbl-up`
Despite its name,
[`bbl-up`](https://github.com/cloudfoundry/cf-deployment-concourse-tasks/tree/master/bbl-up)
actually runs both `bbl up` and `bbl create-lbs`.
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

**For an example for how to configure this in your pipeline,
see the nats pipeline
[here](https://github.com/cloudfoundry/runtime-ci/blob/97dc43bf0839b736d771b3a09a23bc28f1c03530/pipelines/nats.yml#L112-L130).**

#### `bosh-deploy`
As we did with `bbl-up`,
we've shipped a [Concourse task](https://github.com/cloudfoundry/cf-deployment-concourse-tasks/tree/master/bosh-deploy)
for deploying cf-deployment.
The task uses `bbl-state.json` as an input
in order to target and login to the correct director.


#### `bosh-deploy-with-created-release`
The more interesting Concourse task is
[bosh-deploy-with-created-release](https://github.com/cloudfoundry/cf-deployment-concourse-tasks/tree/master/bosh-deploy-with-created-release).
This task takes an additional release repository as an input,
builds a dev release from that repo,
and
uploads it to the bosh director.
It also applies an ops file
that ensures that the director uses the dev release
instead of `latest`.

**For an example for how to configure this in your pipeline,
see that nats pipeline
[here](https://github.com/cloudfoundry/runtime-ci/blob/97dc43bf0839b736d771b3a09a23bc28f1c03530/pipelines/nats.yml#L241-L254).**
