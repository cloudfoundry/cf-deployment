# Deploying Cloud Foundry against bosh-lite using bosh-bootloader (aka bbl)

## Prerequisites

- You are using `GCP` or `AWS` - `bbl` only supports these
- `bbl` is installed
- You have set the required environment variables for your IaaS environment as documented in `bbl up --help` and also the [README](https://github.com/cloudfoundry/bosh-bootloader/blob/master/README.md) of bosh-bootloader
- You have both `cf-deployment` and `bosh-deployment` repos handy

## 1. Obtain the plan patch and bbl up

`bbl` allows you to modify
the IaaS resources it creates
and the ops files it uses
by passing it a `plan-patch.`

To deploy BOSH lite to GCP
you will need the [`bosh-lite-gcp`](https://github.com/cloudfoundry/bosh-bootloader/tree/master/plan-patches/bosh-lite-gcp) plan patch.
More information about [plan-patches](https://github.com/cloudfoundry/bosh-bootloader/tree/master/plan-patches)
can be found in the [BOSH Bootloader](https://github.com/cloudfoundry/bosh-bootloader) repository.

You will need to run `bbl plan`
before you modify it with the plan patch.
`git clone` the bosh-bootloader repository 
to a local directory
and then run the following commands.

```
mkdir -p my-env/bbl-state && cd my-env/bbl-state
bbl plan --name my-env
cp -r /path/to/patch-dir/. .
bbl up
```

The path to the plan patch should be something like
`~/workspace/bosh-bootloader/plan-patches/bosh-lite-gcp/`

## 2. Targeting and Logging in

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


## 3. Upload a stemcell
```
bosh \
-e MY_ENV \
upload-stemcell \
https://bosh.io/d/stemcells/bosh-warden-boshlite-ubuntu-trusty-go_agent
```

## 4. Deploy CF

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
