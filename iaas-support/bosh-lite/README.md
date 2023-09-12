# Deploying Cloud Foundry against bosh-lite using bosh-bootloader (aka bbl)

## Prerequisites

- You are using `GCP` or `AWS` - `bbl` only supports these
- `bbl` is installed
- You have set the required environment variables for your IaaS environment as documented in `bbl up --help` and also the [README](https://github.com/cloudfoundry/bosh-bootloader/blob/main/README.md) of bosh-bootloader
- You have both `cf-deployment` and `bosh-deployment` repos handy

## 1. Obtain the plan patch and bbl up

`bbl` allows you to modify
the IaaS resources it creates
and the ops files it uses
by passing it a `plan-patch.`

To deploy BOSH lite to GCP
you will need the [`bosh-lite-gcp`](https://github.com/cloudfoundry/bosh-bootloader/tree/main/plan-patches/bosh-lite-gcp) plan patch.
More information about [plan-patches](https://github.com/cloudfoundry/bosh-bootloader/tree/main/plan-patches)
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

## 2. Set up DNS
To make sure your system and app domains resolve, you will need to set up DNS to
point at your BOSH Director. For this, you will need to
1. Find the value of `director__external_ip` by running `bbl outputs`
1. Create a wildcard `A` record `*.<SYSTEM_DOMAIN>` and point it
   at the external IP of the BOSH director from step 1

## 3. Targeting

There a several ways to target a bosh director.
This doc will use environment variables.

```
eval "$(bbl print-env)"
```

## 4. Upload a `runtime-config`

`cf-deployment` requires that you have uploaded a [runtime-config](https://bosh.io/docs/runtime-config/) for [BOSH DNS](https://bosh.io/docs/dns/).

We recommended that you use the one provided by the [bosh-deployment](https://github.com/cloudfoundry/bosh-deployment/blob/master/runtime-configs/dns.yml) repo:

```
bosh update-runtime-config bosh-deployment/runtime-configs/dns.yml --name dns
```

## 5. Upload a stemcell

With your bosh director targeted:
```
STEMCELL_VERSION=$(bosh interpolate cf-deployment/cf-deployment.yml --path /stemcells/alias=default/version)

bosh \
  upload-stemcell \
  https://bosh.io/d/stemcells/bosh-warden-boshlite-ubuntu-jammy-go_agent?v=${STEMCELL_VERSION}
```


## 6. Deploy CF

With your bosh director targeted:
```
bosh \
  -d cf \
  deploy \
  cf-deployment/cf-deployment.yml \
  -o cf-deployment/operations/bosh-lite.yml \
  -v system_domain=<SYSTEM_DOMAIN>
```
