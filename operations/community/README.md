# Community-supported ops-files

This is the README for Community Ops-files. To learn more about `cf-deployment`, go to the main [README](../README.md). 

- For general Ops-files, check out the [Ops-file README](../README.md).
- For experimental Ops-files, check out the [Experimental Ops-file README](../experimental/README.md).
- For Legacy Ops-files, checkout the [Legacy Ops-file README](../legacy/README.md).
- For Addons Ops-files that can be applied to manifests or runtime configs, check out the [Addons Ops-file README](addons/README.md).

Included in this directory is a collection of ops files submitted by the CF community.  They are **not** supported or tested in any way by the Release Integration team.  If you encounter an issue with any of these files, please contact the maintainer listed below.

## Ops-Files

| File | Maintainer | Purpose |
| --- | --- | --- |
| [`change-metron-agent-deployment.yml`](change-metron-agent-deployment.yml) | [SAP SE](https://www.sap.com/) - submitted by [jsievers](https://github.com/jsievers) | Adds an ops file for changing the metron agent deployment property in all jobs |
| [`use-haproxy.yml`](use-haproxy.yml) | [Stark & Wayne](https://www.starkandwayne.com/) - submitted by [rkoster](https://github.com/rkoster) | Adds https://github.com/cloudfoundry-incubator/haproxy-boshrelease as a load balancer for environments without IaaS provided load blancers. |
