# cf-deployment Experimental Ops-files

This is the README for Experimental Ops-files. To learn more about `cf-deployment`, go to the main [README](../../README.md).

- For General Ops-files, check out the [Ops-file README](../README.md).
- For Addons Ops-files that can be applied to manifests or runtime configs, check out the [Addons Ops-file README](../addons/README.md).
- For Backup and Restore Ops-files (for configuring your deployment for use with [BBR](https://github.com/cloudfoundry-incubator/bosh-backup-and-restore)), checkout the [Backup and Restore Ops-files README](../backup-and-restore/README.md).
- For Bits Service Ops-files (for configuring your deployment for use with [Bits Service](https://github.com/cloudfoundry-incubator/bits-service)), checkout the [Bits Service Ops-files README](../bits-service/README.md).
- For Community Ops-files, check out the [Community Ops-file README](../community/README.md).

"Experimental" Ops-file represent configurations that we expect to promote to blessed configuration eventually, meaning that, once the configurations have been sufficiently validated, they will either become default (inlined into the base manifest), or GA'd as an optional feature (promoted from experimental to operations directory). Please follow the [ops file workflows](https://github.com/cloudfoundry/cf-deployment/blob/master/ops-file-promotion-workflow.md)

# Experimental ops files

| Name | Purpose | Notes | Currently validated in Release Integration CI pipelines? |
|:---  |:---     |:---   |:---   |
| [`add-credhub-lb.yml`](add-credhub-lb.yml) |  **[DEPRECATED]** Use load balancer to expose external address for CredHub. | | **NO** |
| [`add-metric-store.yml`](add-metric-store.yml) |  **Add Metric Store node for persistence of metrics from Loggregator** | | **NO** |
| [`add-metrics-discovery.yml`](add-metrics-discovery.yml) |  **Add Metrics Discovery Registrar and Metrics Agent to enable egress of metrics using Open Metrics standard** | | **NO** |
| [`add-metrics-discovery-windows.yml`](add-metrics-discovery-windows.yml) |  **Add Metrics Discovery Registrar and Metrics Agent to Windows VMs to enable egress of metrics using Open Metrics standard** | | **NO** |
| [`add-syslog-agent.yml`](add-syslog-agent.yml) |  Add agent to all vms for the purpose of egressing application logs to syslog and disable cf-syslog-drain release | | **YES** |
| [`add-syslog-agent-windows1803.yml`](add-syslog-agent-windows1803.yml) |  Add agent to windows1803 Diego cells for the purpose of egressing application logs to syslog | Requires `../windows1803-cell.yml` and `add-syslog-agent.yml` | **NO** |
| [`add-syslog-agent-windows2019.yml`](add-syslog-agent-windows2019.yml) |  Add agent to windows2019 Diego cells for the purpose of egressing application logs to syslog | Requires `../windows2019-cell.yml` and `add-syslog-agent.yml` | **NO** |
| [`add-system-metrics-agent.yml`](add-system-metrics-agent.yml) | Add agent to all vms with the purpose of egressing system metrics | | **NO** |
| [`add-system-metrics-agent-windows1803.yml`](add-system-metrics-agent-windows1803.yml) | Add agent to windows1803 Diego cells for the purpose of egressing system metrics | | **NO** |
| [`add-system-metrics-agent-windows2019.yml`](add-system-metrics-agent-windows2019.yml) | Add agent to windows2019 Diego cells for the purpose of egressing system metrics | | **NO** |
| [`disable-interpolate-service-bindings.yml`](disable-interpolate-service-bindings.yml) | Disables the interpolation of CredHub service credentials by Cloud Controller. | | **NO** |
| [`disable-uaa-client-redirect-uri-legacy-matching-mode.yml`](disable-uaa-client-redirect-uri-legacy-matching-mode.yml) | Disables legacy (non-exact) matching of redirect URIs in the UAA. | | **NO** |
| [`enable-bpm-garden.yml`](enable-bpm-garden.yml) | Enables the [BOSH Process Manager](https://github.com/cloudfoundry-incubator/bpm-release) for Garden. | This ops file **cannot** be deployed in conjunction with `enable-oci-phase-1.yml`. | **NO** |
| [`enable-containerd-for-processes.yml`](enable-containerd-for-processes.yml) | Configure Garden to run processes via containerd. | This ops file **cannot** be deployed in conjunction with `rootless-containers.yml`. | **NO** |
| [`enable-iptables-logger.yml`](enable-iptables-logger.yml) | Enables iptables logger. | | **YES** |
| [`enable-nginx-routing-integrity-windows2019.yml`](enable-nginx-routing-integrity-windows2019.yml) | Enables container proxy on the Windows 2019 Diego Cell `rep` and configures gorouter to opt into TLS-enabled connections to the backend. | **Warning: this is very experimental** Requires `../windows1803-cell.yml` | **NO** |
| [`enable-oci-phase-1.yml`](enable-oci-phase-1.yml) | Configure CC, Diego, and Garden to create app and task containers more efficiently via OCI image specs. | This ops file **cannot** be deployed in conjunction with `rootless-containers.yml`. | **NO** |
| [`enable-routing-integrity-windows1803.yml`](enable-routing-integrity-windows1803.yml) | Enables container proxy on the Windows 1803 Diego Cell `rep` and configures gorouter to opt into TLS-enabled connections to the backend. | **Warning: this is very experimental** Requires `../windows1803-cell.yml` | **NO** |
| [`enable-smb-volume-service.yml`](enable-smb-volume-service.yml) | **DEPRECATED: use `../enable-smb-volume-service.yml`** | | **NO** |
| [`enable-suspect-actual-lrp-generation.yml`](enable-suspect-actual-lrp-generation.yml) | **"DEPRECATED because it is the default in diego-release"** | Configures BBS to create ActualLRPs in a new "Suspect" state. You can find more in-depth information [here](https://docs.google.com/document/d/19880DjH4nJKzsDP8BT09m28jBlFfSiVx64skbvilbnA/view) | | **NO** |
| [`enable-tls-cloud-controller-postgres.yml`](enable-tls-cloud-controller-postgres.yml) | Enables the usage of TLS to secure the connection between Cloud Controller and its Postgres database | Requires capi-release >= 1.41.0 and `use-postgres.yml` | **NO** |
| [`enable-traffic-to-internal-networks.yml`](enable-traffic-to-internal-networks.yml) | Allows traffic from app containers to internal networks. Required to allow applications to communicate with the running CredHub in non-assisted mode. | | **NO** |
| [`fast-deploy-with-downtime-and-danger.yml`](fast-deploy-with-downtime-and-danger.yml) | Risky, but fast. Disable canaries, increase the max number of vms bosh will update simultaneously, and remove `serial: true` from most instance groups to enable faster, but probably downtimeful, deploys. | | **YES** |
| [`infrastructure-metrics.yml`](infrastructure-metrics.yml) | Add the Prometheus node exporter and Loggregator Prom Scraper to addons. This puts infrastructure metrics into Loggregator's metric stream. | | **NO** |
| [`rootless-containers.yml`](rootless-containers.yml) | Enable rootless garden-runc containers. | Requires garden-runc 1.9.5 or later and grootfs 0.27.0 or later. This ops file **cannot** be deployed in conjunction with `enable-oci-phase-1.yml`. | **NO** |
| [`set-cpu-weight.yml`](set-cpu-weight.yml) | CPU shares for each garden container are proportional to its memory limits. | | **YES** |
| [`set-cpu-weight-windows1803.yml`](set-cpu-weight-windows1803.yml) | CPU shares for each garden container are proportional to its memory limits. | Requires `../windows1803-cell.yml` | **NO** |
| [`set-cpu-weight-windows2019.yml`](set-cpu-weight-windows2019.yml) | CPU shares for each garden container are proportional to its memory limits. | Requires `../windows2019-cell.yml` and `../use-online-windows2019fs.yml` | **NO** |
| [`use-compiled-releases-windows.yml`](use-compiled-releases-windows.yml) | Reverts to source version of releases required for Windows cells | Intended for use with `use-compiled-releases.yml` and any of `windows*-cell.yml` | **YES** |
| [`use-create-swap-delete-vm-strategy.yml`](use-create-swap-delete-vm-strategy.yml) | Configures the default [`vm_strategy`](https://bosh.io/docs/changing-deployment-vm-strategy/) to be `create-swap-delete`. | Requires BOSH director `v267.7+` | **NO** |
| [`use-logcache-for-cloud-controller-app-stats.yml`](use-logcache-for-cloud-controller-app-stats.yml) | **DEPRECATED because the Cloud Controller now uses logcache for app stats by default** Configure Cloud Controller to use Log Cache instead of Traffic Controller for app container metrics. | | **YES** |
| [`use-logcache-syslog-ingress.yml`](use-logcache-syslog-ingress.yml) | Uses syslog ingress for Log Cache in place of Loggregator | Requires `add-syslog-agent.yml` if using Windows cells | **NO** |
| [`use-logcache-syslog-ingress-windows1803.yml`](use-logcache-syslog-ingress-windows1803.yml) | Uses syslog ingress for Log Cache in place of Loggregator for Windows cells | Requires `use-logcache-syslog-ingress.yml` and `add-syslog-agent-windows1803.yml` | **NO** |
| [`use-logcache-syslog-ingress-windows2019.yml`](use-logcache-syslog-ingress-windows2019.yml) | Uses syslog ingress for Log Cache in place of Loggregator for Windows cells | Requires `use-logcache-syslog-ingress.yml` and `add-syslog-agent-windows2019.yml` | **NO** |
| [`use-native-garden-runc-runner.yml`](use-native-garden-runc-runner.yml) | Configure Garden to **not** create containers via containerd, using the native runner instead. | | **NO** |
| [`windows-component-syslog-ca.yml`](windows-component-syslog-ca.yml) | Forces windows component syslog to respect only the provided CA for cert validation. | Requires `windows-enable-component-syslog.yml`. Can also be applied to runtime config, in the manner of the `component-syslog-custom-ca.yml` addon. The operations in this file are intended to be merged into that one when they graduate from experimental status. This ops file gets all its variables from the same place as that one, though not all are used. | **NO** |
| [`windows-enable-component-syslog.yml`](windows-enable-component-syslog.yml) | Collocates a job from windows-syslog-release on all windows-based instances to forward job logs in syslog format. | Compatible with both `windows2016` and `windows2012R2` instances, even at the same time. Can also be applied to runtime config, in the manner of the `enable-component-syslog.yml` addon. The operations in this file are intended to be merged into that one when they graduate from experimental status. This ops file gets all its variables from the same place as that one, though not all are used. | **NO** |
