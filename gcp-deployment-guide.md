# Using `cf-deployment` With GCP
This document contains IaaS-specific notes and instructions for using `cf-deployment` with GCP. See the main [README](https://github.com/cloudfoundry/cf-deployment/blob/master/README.md) for more general information about `cf-deployment`.

## Get yourself a working director

In order to setup a bosh director on GCP, please refer to [the README](https://github.com/cloudfoundry-incubator/cf-gcp-infrastructure/blob/master/README.md) on the gcp-cf-infrastructure repository.

## Deploying CF
1. Upload the current stemcell for `cf` by running the command below with the appropriate version number. The version number is specified on the last line of `cf-deployment.yml`.
  ```
  bosh upload stemcell https://bosh.io/d/stemcells/bosh-google-kvm-ubuntu-trusty-go_agent?v=VERSION
  ```
1. Check that you can generate a final manifest without errors (from inside the cf-deployment directory)
  ```
  bosh -n interpolate --vars-store cf-deployment-vars.yml -o opsfiles/gcp.yml --var-errs cf-deployment.yml
  ```
1. Deploy!
  ```
  bosh \
    -n \
    -d cf \
    deploy \
    --vars-store=cf-deployment-vars.yml \
    -o opsfiles/gcp.yml \
    cf-deployment.yml
  ```
1. Save the `cf-deployment-vars.yml` file somewhere safe.  We use a private git repository for this purpose, but some choose instead to store it in a secure storage service such as LastPass.  You will need to reuse it if you want to update your cf deployment without rotating credentials.
