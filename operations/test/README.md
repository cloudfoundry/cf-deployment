# cf-deployment Test Ops-files

This is the README for Test Ops-files. To learn more about `cf-deployment`, go to the main [README](../../README.md).

The opsfile in this directory are meant for testing and are **not meant for production environments**.

They may change without notice.

- For General Ops-files, check out the [Ops-file README](../README.md).
- For Addons Ops-files that can be applied to manifests or runtime configs, check out the [Addons Ops-file README](../addons/README.md).
- For Backup and Restore Ops-files (for configuring your deployment for use with [BBR](https://github.com/cloudfoundry/bosh-backup-and-restore)), checkout the [Backup and Restore Ops-files README](../backup-and-restore/README.md).
- For Community Ops-files, check out the [Community Ops-file README](../community/README.md).
- For Experimental Ops-files, check out the [Experimental Ops-file README](../experimental/README.md).

| Name | Purpose | Notes |
|:---  |:---     |:---   |
| [`add-datadog-firehose-nozzle.yml`](add-datadog-firehose-nozzle.yml) | Adds a Datadog firehose nozzle instance and UAA client for testing | |
| [`add-oidc-provider.yml`](add-oidc-provider.yml) | Allows testing of UAA with users authenticated via an OIDC provider | Creates a second UAA instance group that acts as the OIDC provider |
| [`alter-ssh-proxy-redirect-uri.yml`](alter-ssh-proxy-redirect-uri.yml) | Sets the SSH proxy UAA client redirect URI to `http://localhost/` | |
| [`scale-to-one-az-addon-parallel-cats.yml`](scale-to-one-az-addon-parallel-cats.yml) | Scales diego-cell and api instance groups up for running CATs quickly | Use after `scale-to-one-az.yml` |
| [`use-cflinuxfs4-compat-isolation-segment-diego-cell.yml`](use-cflinuxfs4-compat-isolation-segment-diego-cell.yml) | Adds cflinuxfs4-compat rootfs setup to the isolated Diego cell | |
| [`enable-nfs-test-server.yml`](enable-nfs-test-server.yml) | adds an NFS server to the deployment | nfstestserver can be reached at nfstestserver.service.cf.internal for acceptance testing purposes |
| [`enable-nfs-test-ldapserver.yml`](enable-nfs-test-ldapserver.yml) | Adds an LDAP server to the deployment to allow testing of NFS volume services configured with LDAP authentication | Requires enable-nfs-volume-service.yml and enable-nfs-test-server.yml. nfstestldapserver can be reached at nfstestldapserver.service.cf.internal |
| [`enable-smb-test-server.yml`](enable-smb-test-server.yml) | adds an SMB server to the deployment | smbtestserver can be reached at smbtestserver.service.cf.internal for acceptance testing purposes |
| [`fips-stemcell.yml`](fips-stemcell.yml) | Contains the validated version of the FIPS-compliant stemcell |
| [`speed-up-dynamic-asgs.yml`](speed-up-dynamic-asgs.yml) | decreases the polling time for policy-server-asg-syncer and vxlan-policy-agent to speed up cf-acceptance-tests | Not suitable for production envs |
| [`set-smoke-test-timeout-scale.yml`](set-smoke-test-timeout-scale.yml) | set the timeout scale to 5 | used when retrieving logs in the smoke tests timeout. usualy happens with gcp enviorments that do not have a ephemeral ips |