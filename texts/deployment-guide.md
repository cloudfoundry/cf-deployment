# Deploying CF

## Paving your IaaS and getting a BOSH Director

Before you can start deploying CF,
you'll need to make sure you've configured your infrastructure appropriately
and deployed a BOSH Director.
If you're using AWS, GCP, or Azure,
we'd suggest using [bbl](https://github.com/cloudfoundry/bosh-bootloader)
to set up your IaaS resources and bootstrap a BOSH director.
Otherwise, take a look at [the BOSH documentation](https://bosh.io/docs/init.html)
for information about prerequisites for a given IaaS
and installing a BOSH Director.

**Note about validation of foundation deployments by the Release Integration team:** 
- The team uses BBL exclusively for IaaS set-up.
- The team validates deployments only against GCP and AWS (not all IaaS are confirmed).
 
#### bosh-lite
If you're deploying bosh-lite to a VM on AWS, GCP, or Azure,
look at [this guide](iaas-support/bosh-lite/README.md).

If you're planning to deploy against a **local** bosh-lite,
follow [these instructions](https://bosh.io/docs/bosh-lite.html)
to setup a BOSH Lite director. Then follow [these instructions](#deploy-cf-to-local-bosh-lite)
to deploy CF.

#### IaaSes not supported by `bbl`
See [IaaS Support](iaas-support/README.md)

### Step 1: Get you some load balancers
The CF Routers need a way to receive traffic.
The most common way to accomplish this is to configure load balancers
to route traffic to them.
While we cannot offer help for all IaaSes specifically, 
you can use `bbl` to create load balancers on AWS, GCP, and Azure.
- Before you can create your load balancers using the command `bbl up`, you need to populate a state directory with the latest configs to be used by the command. 
This can be achieved by running `bbl plan...`
- `bbl plan...` requires you provide an SSL certificate for the domain your load balancers will use:
  - If you have certificate from a trusted Certificate Authority, or you already have a certificate because you've used your domain for a previous environment, you can skip the cert generation steps described below and go directly to executing the `bbl plan...` command.
  - If you're deploying a fresh environment with a new domain, you can generate a self-signed cert by executing the following command.
```openssl req -x509 -newkey rsa:2048 -keyout key.pem -out cert.pem -nodes -days 365```
    - You’ll be asked a series of simple questions, the answers to which will be used to generate your cert.
    - **The answer you provide for the "common name" _must_ match your intended system domain (and app domains, if it's different)**
    - Once complete, you'll find `key.pem` and `cert.pem` in the directory where you executed the `openssl...` command.

With SSL certificate "in-hand", you're ready proceed with executing `bbl plan...`:
```
bbl --state-dir <BBL-STATE-DIRECTORY> plan --lb-type cf --lb-domain <SYSTEM_DOMAIN> --lb-cert <LB_CERT> --lb-key <LB_KEY> 
```
- **IaaS Note**: the additional flags required by `bbl plan...` will vary based on which IaaS you’re working with. 

Now that your bbl-state is saved you're ready to `bbl up` your load balancers and bootstrap your bosh director:
```
bbl --state-dir <BBL-STATE-DIRECTORY> up
```

### Step 2: Update your DNS records to point to your load balancer
Once you have a load balancer set up,
you'll want to make sure that your system and app domains resolve to the appropriate load balancer.

You can set up DNS with your preferred provider,
but if you've used `bbl` to create your load balancers on GCP, AWS, or Azure,
`bbl` will create NS records for your system domain.
- From your bbl state directory, `grep name_servers vars/terraform.tfstate` to view those records

If you manage your DNS with some other provider
-- for example, with Route53 --
you can copy the NS record data that `bbl` created,
and paste it into the `value` section of the Route53 NS record for your domain.

After a few minutes, your system domain should resolve to your load balancer.

### Step 3: Save bbl state directory
However you run `bbl` (command line or with Concourse),
the side-effect of a successful bbl command is the creation/update of the directory
containing `bbl-state.json` and other files.
(This is either the directory that you ran `bbl` from, the directory provided as a
`--state-dir` argument to `bbl`, or the `$BBL_STATE_DIR` variable in your environment.)
As a deployer, **you must persist this directory somehow.**

Currently, our [CF-Deployment-Concourse-Tasks](https://github.com/cloudfoundry/cf-deployment-concourse-tasks) assume
that you want to check this directory into a private git repo.

### Step 4: Target your BOSH Director
There are several ways to target your new BOSH director.
One of the simplest ways is to create an environment alias:
```
bosh -e <DIRECTOR_IP> alias-env my-env --ca-cert DIRECTOR_CA_CERT_FILE

bosh -e my-env login
# Provide username and password for your BOSH Director
```

Alternatively, you can set environment variables:
```
export BOSH_ENVIRONMENT=<DIRECTOR_IP>
export BOSH_CLIENT=<DIRECTOR_USERNAME>
export BOSH_CLIENT_SECRET=<DIRECTOR_PASSWORD>
export BOSH_CA_CERT=<DIRECTOR_CA_CERT_TEXT>
```

If you've used `bbl` to set up your director,
you can fetch the director location and credentials with the following commands:

```
eval "$(bbl print-env)"
```
or
```
export BOSH_ENVIRONMENT=$(bbl director-address)
export BOSH_CLIENT=$(bbl director-username)
export BOSH_CLIENT_SECRET=$(bbl director-password)
export BOSH_CA_CERT="$(bbl director-ca-cert)"
```

### Step 5: Upload a `cloud-config`
cf-deployment depends on use of a [cloud-config](https://bosh.io/docs/cloud-config).
You can find details about the requirements for a cloud-config [here](texts/on-cloud-configs.md),
but if you used `bbl` to set up your BOSH director,
`bbl` already uploaded a valid cloud-config for you.

For bosh-lite,
```
bosh -e MY_ENV update-cloud-config iaas-support/bosh-lite/cloud-config.yml
```

### Step 6: Upload a `runtime-config`
`cf-deployment` requires that you have uploaded
a [runtime-config](https://bosh.io/docs/runtime-config/) for [BOSH DNS](https://bosh.io/docs/dns/).
We recommended that you use the one provided by the
[bosh-deployment](https://github.com/cloudfoundry/bosh-deployment/blob/master/runtime-configs/dns.yml) repo:

```
bosh update-runtime-config bosh-deployment/runtime-configs/dns.yml --name dns
```

### Step 7: Upload a stemcell
Before BOSH can deploy CF,
it needs a base VM image to start with.
In the BOSH ecosystem, these images are called [stemcells](http://bosh.io/docs/stemcell.html).

Stemcells are closely tied to the IaaS against which they're compatible,
but the BOSH team versions stemcells for different IaaSes consistently.
As such, we can encode the stemcell version in the cf-deployment manifest,
but we can't encode the IaaS.

As such, you'll need to [upload the stemcell](http://bosh.io/docs/uploading-stemcells.html) to the BOSH director yourself.
Take a look at the list of stemcells at http://bosh.io/stemcells
and find the stemcell for your IaaS.
Each stemcell will have an important descriptor in its url that describes the platform and virtualization technology.
For example, for GCP, the url contains `google-kvm`; for AWS, it's `aws-xen-hvm`.

Find that value and set it:
```
export IAAS_INFO=google-kvm
```
Now, you can pull the stemcell version required for the particular release of cf-deployment you're deployingby interpolating the base manifest (`cf-deployment.yml`):
```
export STEMCELL_VERSION=$(bosh interpolate cf-deployment.yml --path=/stemcells/alias=default/version)
```
Now you can upload the stemcell:
```
bosh upload-stemcell https://bosh.io/d/stemcells/bosh-${IAAS_INFO}-ubuntu-xenial-go_agent?v=${STEMCELL_VERSION}
```

### Step 8: Deploy CF
To deploy to a configured BOSH director using the `bosh` CLI:

```
export SYSTEM_DOMAIN=some-domain.that.you.have
bosh -e my-env -d cf deploy cf-deployment/cf-deployment.yml \
  -v system_domain=$SYSTEM_DOMAIN \
  [ -o operations/CUSTOMIZATION1 ] \
  [ -o operations/CUSTOMIZATION2 (etc.) ]
```

The length of time your deployment will take will vary based on many factors, but a fresh deployment typically takes between 45 and 90 minutes.

**Note:** You will be asked to confirm the deployment after bosh does some initial evaluation of your deploy instructions. If you prefer to execute the deploy and walk away without confirming the deployment, you can include `-n` in your `bosh deploy...` command.

**Login to CF Admin on your foundation**

Once the deployment is finished, the CF Admin credentials can be found in CredHub.

To retrieve CF Admin credentials,
1. Login to CredHub
    ```
    credhub login
    ```
2. Find the password for the CF Admin user. You will need to first find the credential to get the full path of the stored variable in your BOSH deployment namespace:
    ```
    credhub find -n cf_admin_password
    ```

    in the output of the above command, you'll find the full path through credhub to supply to the next and last command:

    ```
    credhub get -n <FULL_CREDENTIAL_NAME>
    ```
    
**OR** - you can combine the two steps above:

```
credhub get -n $(credhub find -n admin | grep cf_admin | cut -d: -f2) | grep value | cut -d: -f2
```

Now target your api:
```
cf api https://api.<SYSTEM-DOMAIN>.com --skip-ssl-validation
```
Then you can
```
cf login
```
with the username `admin` and the password from CredHub above.

**For operators trying out cf-deployment for the first time**

In the hope of saving you some time,
we'd advise that you add `operations/scale-to-one-az.yml`, `operations/use-compiled-releases.yml`, and `operations/experimental/fast-deploy-with-downtime-and-danger.yml` ops-files to your bosh deploy commmand:
```
bosh -e my-env -d cf deploy cf-deployment/cf-deployment.yml \
  -v system_domain=$SYSTEM_DOMAIN \
  -o operations/scale-to-one-az.yml \
  -o operations/use-compiled-releases.yml
  -o operations/experimental/fast-deploy-with-downtime-and-danger.yml
```



#### For Operators Deploying CF to local bosh-lite
If you're using a local bosh-lite,
remember to add the `operations/bosh-lite.yml` ops file
to your deploy command and use the IP address of the BOSH Director that's running inside your local VirtualBox.

First, setup your environment with BOSH and CredHub credentials, so that you can
retrieve CF Admin credentials later:

```
export BOSH_CLIENT=admin
export BOSH_CLIENT_SECRET="$(bosh int <PATH_TO_DIRECTOR_VARS_STORE>/creds.yml --path /admin_password)"
export BOSH_CA_CERT="$(bosh interpolate <PATH_TO_DIRECTOR_VARS_STORE>/creds.yml --path /director_ssl/ca)"

export CREDHUB_SERVER=https://192.168.50.6:8844
export CREDHUB_CLIENT=credhub-admin
export CREDHUB_SECRET=$(bosh interpolate <PATH_TO_DIRECTOR_VARS_STORE>/creds.yml --path=/credhub_admin_client_secret)
export CREDHUB_CA_CERT="$(bosh interpolate <PATH_TO_DIRECTOR_VARS_STORE>/creds.yml --path=/credhub_tls/ca )"$'\n'"$( bosh interpolate <PATH_TO_DIRECTOR_VARS_STORE>/creds.yml --path=/uaa_ssl/ca)"
```
The new line in the `CREDHUB_CA_CERT` env var is critical, as the PEM format requires a new line between the two CA certs CredHub requires.
Concatenating them together in the env var without the new line in-between will result in difficult-to-troubleshoot generic errors.

Then, deploy CF:
```
bosh -e 192.168.50.6 -d cf deploy \
  cf-deployment.yml \
  -o operations/bosh-lite.yml \
  -v system_domain=bosh-lite.com
```

**Login to CF Admin on local bosh-lite**

To retrieve CF Admin credentials, follow the same steps described in the "Deploy CF" section above

Target your api:
```
cf api https://api.bosh-lite.com --skip-ssl-validation
```
then you can
```
cf login
```
with the username `admin` and the password from CredHub above.

## Notes for operators
`cf-deployment` includes tooling
(mostly in the form of ops-files)
that allow operators to make choices about their deployment configuration.
However, some decisions are necessarily left to the operator
because tooling can be hard to make generic.
In this section,
we want to outline some of the decisions operators
will need to make about their deployments without tooling from cf-deployment.

### Databases
By default,
`cf-deployment` includes
MySQL Galera databases
that are singletons. The MySQL databases can be scaled by applying `operations/scale-database-cluster.yml` during the bosh deployment.
Some may want to deploy IaaS-managed database systems
such as [Amazon RDS](https://aws.amazon.com/rds/) or [Google Cloud SQL](https://cloud.google.com/sql/).
External databases
will require the use of the [`use-external-dbs.yml`](operations/use-external-dbs.yml) opsfile.


### Blobstore
By default,
`cf-deployment` includes
a `webdav` blobstore
that is a singleton
and cannot be scaled out.
Deployers
may want to use
an external blobstore
such as [Amazon S3](https://aws.amazon.com/s3/),
[Google Cloud Storage](https://cloud.google.com/storage/),
[Azure Blob storage](https://azure.microsoft.com/en-us/services/storage/blobs/), or
[OpenStack Swift](https://docs.openstack.org/swift/latest/).
External blobstores
require the use of opsfiles listed in the operations [README](operations/README.md#iaas-required-ops-files)

### The `update` section of instance groups
The [`update` section of a deployment manifest](http://bosh.io/docs/manifest-v2.html#update)
controls the way BOSH rolls out updates to instance groups.
CF-Deployment assumes the default scale as defined in the base manifest
(typically two instances of each instance group).
Some deployers may need to reconfigure the `update` section to suit the unique needs of their foundation.

The most straightfoward way
to reconfigure those sections
would be with a custom ops-file, such as:
```yml
- type: replace
  path: /instance_groups/name=<JOB_NAME>/update?/canaries
  value: 2
- type: replace
  path: /instance_groups/name=<JOB_NAME>/update?/canary_watch_time
  value: 60000-150000
- type: replace
  path: /instance_groups/name=<JOB_NAME>/update?/max_in_flight
  value: 10
- type: replace
  path: /instance_groups/name=<JOB_NAME>/update?/serial
  value: true
- type: replace
  path: /instance_groups/name=<JOB_NAME>/update?/update_watch_time
  value: 60000-150000
```

### Scaling instance groups
`cf-deployment` deploys with
two instances, distributed across two AZs
(with the exception of some jobs that require more instances).
While it's easy for us to provide an ops-file
[to scale instance groups _down_](operations/scale-to-one-az.yml), operators will need to provide their own ops-file
to scale instances _up_ to suit the unique requirements of their foundations.
Here's an example:
```yml
- type: replace
  path: /instance_groups/name=<JOB_NAME>/instances
  value: 10
```
