# Using `cf-deployment` With Azure

This document contains IaaS-specific notes and instructions for using `cf-deployment` with Azure. See the main [README](https://github.com/cloudfoundry/cf-deployment/blob/master/README.md) for more general information about `cf-deployment`.

## Resources

- [`BOSH v2`](https://github.com/cloudfoundry/bosh-cli):
[`bbl`](https://github.com/cloudfoundry/bosh-bootloader) doesn't support Azure for now. You can use `BOSH v2` to set up IaaS and deploys a BOSH director.

## Step-by-step guide for deploying by hand

### 1. Get yourself a working director with `BOSH v2`

#### a. IaaS and Director setup

You can set up BOSH environment on Azure with the [steps](https://bosh.io/docs/init-azure.html).

#### b. Load balancers

You can run the [script](https://github.com/cloudfoundry-incubator/bosh-azure-cpi-release/blob/master/docs/advanced/deploy-multiple-haproxy/create-load-balancer.sh) to create a load balancer in the resource group.

#### c. Save `state.json`

However you run `bosh create-env`, the side-effect of a successful bosh command is the creation/update of `state.json`. As a deployer, **you must persist this file somehow.**

### 2. Deploying CF

1. Upload the current stemcell for `cf` by running the command below with the appropriate version number.
The version number is specified on the last line of `cf-deployment.yml`.

  ```
  bosh upload-stemcell https://bosh.io/d/stemcells/bosh-azure-hyperv-ubuntu-trusty-go_agent?v=VERSION
  ```

1. Update the cloud config.

    A sample `cloud-config.yml`:

    ```
    azs:
    - name: z1
    - name: z2
    - name: z3

    compilation:
      az: z1
      network: default
      reuse_compilation_vms: true
      vm_type: compilation
      vm_extensions:
      - 100GB_ephemeral_disk
      workers: 6

    disk_types:
    - name: default
      disk_size: 1024
    - name: 1GB
      disk_size: 1024
    - name: 5GB
      disk_size: 5120
    - name: 10GB
      disk_size: 10240
    - name: 50GB
      disk_size: 51200
    - name: 100GB
      disk_size: 102400
    - name: 500GB
      disk_size: 512000
    - name: 1TB
      disk_size: 1048576
    - name: 4TB
      disk_size: 4194304

    networks:
    - name: default
      type: manual
      subnets:
      - range: ((internal_cidr))
        gateway: ((internal_gw))
        azs: [z1, z2, z3]
        dns: [168.63.129.16]
        reserved: [((internal_gw))/30]
        cloud_properties:
          virtual_network_name: ((vnet_name))
          subnet_name: ((subnet_name))
          security_group: ((security_group))
    - name: vip
      type: vip

    vm_types:
    - name: small
      cloud_properties:
        instance_type: Standard_F1
    - name: medium
      cloud_properties:
        instance_type: Standard_F2
    - name: large
      cloud_properties:
        instance_type: Standard_D12_v2
    - name: compilation
      cloud_properties:
        instance_type: Standard_F4

    vm_extensions:
    - name: 1GB_ephemeral_disk
      cloud_properties:
        ephemeral_disk:
          size: 1024
    - name: 5GB_ephemeral_disk
      cloud_properties:
        ephemeral_disk:
          size: 5120
    - name: 10GB_ephemeral_disk
      cloud_properties:
        ephemeral_disk:
          size: 10240
    - name: 50GB_ephemeral_disk
      cloud_properties:
        ephemeral_disk:
          size: 51200
    - name: 100GB_ephemeral_disk
      cloud_properties:
        ephemeral_disk:
          size: 102400
    - name: 500GB_ephemeral_disk
      cloud_properties:
        ephemeral_disk:
          size: 512000
    - name: 1TB_ephemeral_disk
      cloud_properties:
        ephemeral_disk:
          size: 1048576
    - name: 4TB_ephemeral_disk
      cloud_properties:
        ephemeral_disk:
          size: 4194304
    - name: cf-router-network-properties
      cloud_properties:
        load_balancer: ((load_balancer_name))
    - name: diego-ssh-proxy-network-properties
    ```

    ```
    bosh update-cloud-config cloud-config.yml \
      -v internal_cidr=10.0.16.0/24 \
      -v internal_gw=10.0.16.1 \
      -v vnet_name=boshvnet-crp \
      -v subnet_name=CloudFoundry \
      -v security_group=nsg-cf
    ```

1. Deploy!

    ```
    bosh \
      -e TARGET_DIRECTOR \
      -n \
      -d cf \
      deploy \
      cf-deployment/cf-deployment.yml \
      --vars-store env-repo/deployment-vars.yml \
      -v system_domain=YOUR_SYSTEM_DOMAIN \
      -o cf-deployment/operations/azure.yml
    ```

1. Save the `deployment-vars.yml` file somewhere safe. You will need to reuse it if you want to update your cf deployment without rotating credentials.
