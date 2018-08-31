# Deploying Cloud Foundry on HuaweiCloud with BOSH

## Prerequisites

You'll need to following to proceed:
 * An HuaweiCloud project
 * A user able to create/delete resource in this project

## Install BOSH

To install the BOSH director please follow the instructions on [huaweicloud cpi](https://github.com/zhongjun2/bosh-huaweicloud-cpi-release/).


## Cloud Config

After the BOSH director has been installed, you can prepare and upload a cloud config based on the [cloud-config.yml](cloud-config.yml) file.

Take the variables and outputs from the Terraform run of `cf-deployment-tf` to finalize the cloud config.

Use the following command to upload the cloud config.
```
bosh update-cloud-config \
     -v availability_zone1="<az-1>" \
     -v availability_zone2="<az-2>" \
     -v availability_zone3="<az-3>" \
     -v network_id1="<cf-network-id-1>" \
     -v network_id2="<cf-network-id-2>" \
     -v network_id3="<cf-network-id-3>" \
     cf-deployment/iaas-support/huaweicloud/cloud-config.yml
```

## Deploy Cloud Foundry

To deploy Cloud Foundry run the following command filling in the necessary variables. `system_domain` is the user facing domain name of your Cloud Foundry installation.

```
bosh -d cf deploy cf-deployment/cf-deployment.yml \
     -o cf-deployment/operations/use-compiled-releases.yml \
     --vars-store <vars-store> \
     -v system_domain="<system-domain>"
```
