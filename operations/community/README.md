# Community-supported ops-files

This is the README for Community Ops-files. To learn more about `cf-deployment`, go to the main [README](../../README.md).

- For General Ops-files, check out the [Ops-file README](../README.md).
- For Addons Ops-files that can be applied to manifests or runtime configs, check out the [Addons Ops-file README](../addons/README.md).
- For Backup and Restore Ops-files (for configuring your deployment for use with [BBR](https://github.com/cloudfoundry-incubator/bosh-backup-and-restore)), checkout the [Backup and Restore Ops-files README](../backup-and-restore/README.md).
- For Experimental Ops-files, check out the [Experimental Ops-file README](../experimental/README.md).

Included in this directory is a collection of ops files submitted by the CF community.  They are **not** supported or tested in any way by the Release Integration team.  If you encounter an issue with any of these files, please contact the maintainer listed below.

## Ops-Files

| File | Maintainer | Purpose |
| --- | --- | --- |
| [`add-blobstore-internal-network-allow-rule.yml`](add-blobstore-internal-network-allow-rule.yml) | [A2Geek](https://github.com/a2geek) | Allows an additonal internal network to the blobstore allow rules. |
| [`change-metron-agent-deployment.yml`](change-metron-agent-deployment.yml) | [SAP SE](https://www.sap.com/) - submitted by [jsievers](https://github.com/jsievers) | Adds an ops file for changing the metron agent deployment property in all jobs |
| [`use-haproxy.yml`](use-haproxy.yml) | [Stark & Wayne](https://www.starkandwayne.com/) - submitted by [rkoster](https://github.com/rkoster) | Adds https://github.com/cloudfoundry-incubator/haproxy-boshrelease as a load balancer for environments without IaaS provided load blancers. |
