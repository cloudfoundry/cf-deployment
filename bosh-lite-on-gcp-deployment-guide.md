# Setting up bosh-lite on GCP
The documnet contains IaaS-specific notes for
setting up bosh-lite on GCP
and deploying cf-deployment to it.

## Resources
- [Terraform template](https://github.com/cloudfoundry/runtime-ci/tasks/bosh-create-env/terraform/bosh-lite/terraform.tf)
- [bosh-deployment](https://github.com/cloudfoundry/bosh-deployment)
- [BOSH CLI](https://github.com/cloudfoundry/bosh-cli)

## Step-by-step guide

### 1. Pave a GCP project in advance of setting up your BOSH Director

Start with a directory that represents your environment workspace
-- such as an environment repo
or a directory whose contents you can upload to Lastpass.

Before you can pave your infrastructure,
you'll need to set up your terraform variables.
Create a file called `terraform.tfvars`,
and populate it so:
```
{
  "service_account_key": "{ \"type\": \"service_account\", ... }",
  "project": "YOUR_PROJECT_NAME",
  "projectid": "YOUR_PROJECT_NAME",
  "dns_suffix": "YOUR_SUBDOMAIN.cf-app.com",
  "env_name": "A_NAME_FOR_YOUR_ENVIRONMENT"
}
```

Once your terraform variables are set up, you can run
```
terraform apply ~/workspace/runtime-ci/tasks/bosh-create-env/terraform/bosh-lite/
```

### 2. Deploy a bosh director

To bootstrap our BOSH director,
we're going to use the new BOSH CLI and its `create-env` command.
For configuration, we'll use a vars-store and ops-files.
Like you did with `terraform.tfvars`,
you'll also need to save your vars-store in a secure, persistent location.
For the purpose of this example,
we'll reference an env-repo,
although you can just as easily use Lastpass instead.
Likewise, you'll need to save the BOSH state in the same location.

To bootstrap a director,
you'll need to provide a few variables:

| variable name | description |
| ------------- | ----------- |
| GCP_PROJECT_ID | Get this value from your GCP console |
| GCP_SERVICE_ACCOUNT_KEY | Your GCP credentials. |
| GCP_ZONE | Choose a value from [this list](https://cloud.google.com/compute/docs/regions-zones/regions-zones) |
| DIRECTOR_NAME | You can choose any string for this |
| EXTERNAL_IP | `jq .modules[0].outputs.external_ip.value  env-repo/terraform.tfstate` |
| NETWORK | `jq .modules[0].outputs.network_name.value env-repo/terraform.tfstate` |
| SUBNETWORK | `jq .modules[0].outputs.subnetwork_name.value env-repo/terraform.tfstate` |
| INTERNAL_CIDR | `jq .modules[0].outputs.internal_cidr.value env-repo/terraform.tfstate` |
| INTERNAL_GW | `jq .modules[0].outputs.internal_gw.value env-repo/terraform.tfstate` |
| INTERNAL_IP | `jq .modules[0].outputs.internal_ip.value env-repo/terraform.tfstate` |
| TAGS | `[]` |

You can provide vars to the `create-env` command in two ways:
as command line arguments,
or as data in your vars-store file.

With command line arguments, the `create-env` command will look like this:
```
bosh create-env \
  --vars-store /path/to/env-repo/bosh-vars.yml \
  --state /path/to/env-repo/bosh-state.yml \
  -o bosh-deployment/gcp/cpi.yml \
  -o bosh-deployment/bosh-lite.yml \
  -o bosh-deployment/external-ip-not-recommended.yml \
  -o bosh-deployment/gcp/bosh-lite-vm-type.yml \
  -o bosh-deployment/jumpbox-user.yml \
  -o bosh-deployment/bosh-lite-runc.yml \
  -v project_id=$GCP_PROJECT_ID \
  -v "gcp_credentials_json='$GCP_SERVICE_ACCOUNT_KEY'" \
  -v zone=$GCP_ZONE \
  -v director_name=$DIRECTOR_NAME \
  -v external_ip=$EXTERNAL_IP \
  -v network=$NETWORK \
  -v subnetwork=$SUBNETWORK \
  -v internal_cidr=$INTERNAL_CIDR \
  -v internal_gw=$INTERNAL_GW \
  -v internal_ip=$INTERNAL_IP \
  -v tags=$TAGS \
  bosh-deployment/bosh.yml
```

Alternatively, you can populate your vars-store with that data
before you run the `create-env` command:
```
echo "project_id: $GCP_PROJECT_ID" >> env-repo/bosh-vars.yml
echo "gcp_credentials_json: '$GCP_SERVICE_ACCOUNT_KEY'" >> env-repo/bosh-vars.yml
echo "gcp_zone: $GCP_ZONE" >> env-repo/bosh-vars.yml
echo "director_name: $DIRECTOR_NAME" >> env-repo/bosh-vars.yml
echo "external_ip: $EXTERNAL_IP" >> env-repo/bosh-vars.yml
echo "network: $NETWORK" >> env-repo/bosh-vars.yml
echo "subnetwork: $SUBNETWORK" >> env-repo/bosh-vars.yml
echo "internal_cidr: $INTERNAL_CIDR" >> env-repo/bosh-vars.yml
echo "internal_gw: $INTERNAL_GW" >> env-repo/bosh-vars.yml
echo "internal_ip: $INTERNAL_IP" >> env-repo/bosh-vars.yml
echo "tags: $TAGS" >> env-repo/bosh-vars.yml
```

With all of the variables stored in your vars-store,
you can run a simpler command to bootstrap a director:
```
bosh create-env \
  --vars-store /path/to/env-repo/bosh-vars.yml \
  --state /path/to/env-repo/bosh-state.json \
  -o bosh-deployment/gcp/cpi.yml \
  -o bosh-deployment/bosh-lite.yml \
  -o bosh-deployment/external-ip-not-recommended.yml \
  -o bosh-deployment/gcp/bosh-lite-vm-type.yml \
  -o bosh-deployment/jumpbox-user.yml \
  -o bosh-deployment/bosh-lite-runc.yml \
  bosh-deployment/bosh.yml
```

### 3. Upload the cloud config
```
bosh -e $EXTERNAL_IP update-cloud-config cf-deployment/bosh-lite/cloud-config.yml
```

### 4. Deploy CF
```
bosh -e $EXTERNAL_IP deploy cf-deployment/cf-deployment.yml -o cf-deployment/operations/bosh-lite.yml --vars-store env-repo/vars-store.yml -v system_domain=$SYSTEM_DOMAIN
```
