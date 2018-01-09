# IaaS Support

The examples in this directory
are not under continuous test,
and may not be up to date.

They are intended to be a useful starting place.
For more information about
cf-deployment's use of cloud configs,
please see [On Cloud Configs](../texts/on-cloud-configs.md).

The examples are variablized.
You may be able to use them unmodified
(beyond filling in the appropriate vars)
with `bosh update-cloud-config <iaas>/cloud-config.yml -l <iaas>/cloud-config-vars.yml`.

## IaaS Details

See the READMEs for each IaaS:

- [bosh-lite](bosh-lite/README.md)
- [openstack](openstack/README.md)
- [vsphere](vsphere/README.md)