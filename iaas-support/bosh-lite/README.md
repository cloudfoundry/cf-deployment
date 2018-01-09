# Deploying Cloud Foundry against bosh-lite using bosh-bootloader (aka bbl)

## Prerequisites

- You are using `GCP` or `AWS` - `bbl` only supports these
- `bbl` is installed
- You have set the required environment variables for your IaaS environment as documented in `bbl up --help` and also the [README](https://github.com/cloudfoundry/bosh-bootloader/blob/master/README.md) of bosh-bootloader
- You have both `cf-deployment` and `bosh-deployment` repos handy

## 1. Concatenate needed ops files

`bbl` only accepts a single ops file, so you need to concatenate all the necessary ops files into a single file, and then pass that to the `bbl up` command.  The ops files you will need reside in the [bosh-deployment](https://github.com/cloudfoundry/bosh-deployment) repository.

For `AWS`, you will need:
- bosh-lite.yml
- bosh-lite-runc.yml

For `GCP`, you will need:
- bosh-lite.yml
- bosh-lite-runc.yml
- gcp/bosh-lite-vm-type.yml

## 2. `bbl up` the environment

The command you'll need to run will look something like:

```
bbl \
up \
--name <ENV_NAME> \
--ops-file <CONCATENATED_OPS_FILE>

# ...
# IaaS-specific flags
# ...
```

## 3. Ensure required firewall ports open

Until `bbl` offers a `--lite` option, you'll also need to ensure the ports `80,443,2222` are opened on the firewall to the vm created by `bbl`.

## 4. Targeting and Logging in

There a several ways to target a bosh director.
This doc will use `alias-env` and `-e`,
but you can set environment variables if you prefer.

First, create an alias for your director:
```
bosh -e $(bbl director-address) --ca-cert <(bbl director-ca-cert) alias-env MY_ENV
```

Then, log in:
```
bosh -e MY_ENV login --client $(bbl director-username) --client-secret $(bbl director-password)
```

## 5. Upload the cloud config

```
bosh \
-e MY_ENV
update-cloud-config \
cf-deployment/iaas-support/bosh-lite/cloud-config.yml
```

## 6. Upload a stemcell
```
bosh \
-e MY_ENV \
upload-stemcell \
https://bosh.io/d/stemcells/bosh-warden-boshlite-ubuntu-trusty-go_agent
```

## 7. Deploy CF

```
bosh \
-e MY_ENV \
-d cf \
deploy \
cf-deployment/cf-deployment.yml \
-o cf-deployment/operations/bosh-lite.yml \
--vars-store deployment-vars.yml \
-v system_domain=<SYSTEM_DOMAIN>
```
