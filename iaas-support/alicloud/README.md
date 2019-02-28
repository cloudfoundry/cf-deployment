# Deploying Cloud Foundry on Alibaba Cloud with BOSH
**Note about support:** The Release Integration team does not maintain nor validate Alibaba Cloud deployments and Alibaba Cloud deployers must rely on the general CF community for support.

In this directory, we provide an example `cloud-config.yml` for Alibaba Cloud.

## Install BOSH

To install the BOSH director please follow the instructions on [bosh.io](https://bosh.io/docs/init-alicloud.html).

Make sure the BOSH director is accessible through the BOSH cli, by following the instructions on [bosh.io](https://bosh.io/docs/cli-envs.html). Use this mechanism in all BOSH cli examples in
this documentation.

## Deploy Cloud Foundry

### Prepare Cloud Foundry Environment

- Select 3 availability zones
- Create vswitch in each zone get `vswitch_id`, `zone_id`, `internal_cidr`, `internal_gateway`
- Config VPC SNAT with each vswitch to enable vm internet access
- Create a Http SLB and get `http_slb_id`
- Create several security groups get their `security_group_id`
- Create a domain name wild bind to slb ip. Example: config *.hello-cf.cc to 47.47.47.47
    - You can use 47.47.47.47.xip.io instead custom DNS, but it's not very stable.
- create a Tcp slb get `tcp_slb_id` [optional]

## Cloud Config

After the BOSH director has been installed, you can prepare and upload a cloud config based on the [cloud-config.yml](cloud-config.yml) file.

Take the variables and outputs from your environment to finalize the cloud config.

Use the following command to upload the cloud config.
```
bosh update-cloud-config \
     cf-deployment/iaas-support/alicloud/cloud-config.yml \
     -v az1_zone="<az-1>" \
     -v az2_zone="<az-2>" \
     -v az3_zone="<az-2>" \
     -v az1_vswitch_id="<az1_vswitch_id>" \
     -v az2_vswitch_id="<az2_vswitch_id>" \
     -v az3_vswitch_id="<az3_vswitch_id>" \
     -v az1_vswitch_range="<az1_vswitch_range>" \
     -v az2_vswitch_range="<az2_vswitch_range>" \
     -v az3_vswitch_range="<az3_vswitch_range>" \
     -v az1_vswitch_gateway="<az1_vswitch_gateway>" \
     -v az2_vswitch_gateway="<az2_vswitch_gateway>" \
     -v az3_vswitch_gateway="<az3_vswitch_gateway>" \
     -v security_group_id_1="<security_group_id_1>" \
     -v security_group_id_2="<security_group_id_2>" \
     -v security_group_id_3="<security_group_id_3>" \
     -v tcp_slb_id_array=["<tcp_slb_id_array>"] \
     -v http_slb_id_array=["<http_slb_id_array>"]

```

## Deploy Cloud Foundry

To deploy Cloud Foundry run the following command filling in the necessary variables. `system_domain` is the user facing domain name of your Cloud Foundry installation.

Setup Domain, use your domain name

```
export CF_DOMAIN=...
```

```
bosh -d cf deploy cf-deployment/cf-deployment.yml \
     -o cf-deployment/iaas-support/alicloud/stemcells.yml \
     -v region="<region_id>" \
     -v system_domain=$CF_DOMAIN
```

### Deploy Cloud Foundry In China Region

For some network connection reasons, if you want to deploy Cloud Foundry in China region, like 'cn-beijing', 'cn-hangzhou' and so on, you may be failed using above method. In order to avoid it happened, you can use the following progress.

Using your local computer to download several releases that Cloud Foundry dependent. Running the following command in your local computer:

```
sh cf-deployment/iaas-support/alicloud/download-releases.sh cf-deployment/cf-deployment.yml "<store-releases-directory>"
```

If it succeed, there are several releases and a new cf-deployment-local.yml in the "<store-releases-directory>".

Uploading the downloaded releases to your development environment "cf-deployment/releases". After that, running the following command to upload releases:

```
cf-deployment/iaas-support/alicloud/upload-releases.sh cf-deployment/releases
```

Setup Domain, use your domain name

```
export CF_DOMAIN=...
```

```
bosh -d cf deploy cf-deployment/releases/cf-deployment-local.yml \
     -o cf-deployment/iaas-support/alicloud/stemcells.yml \
     -v region="<region_id>" \
     -v system_domain=$CF_DOMAIN
```
