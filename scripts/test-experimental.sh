#!/bin/bash

test_experimental_ops() {
  # Padded for pretty output
  suite_name="EXPERIMENTAL      "

  pushd ${home} > /dev/null
    pushd operations/experimental > /dev/null
      check_interpolation "add-credhub-lb.yml"

      check_interpolation "add-deployment-updater.yml"
      check_interpolation "name: add-deployment-updater-postgres.yml" "add-deployment-updater.yml" "-o add-deployment-updater-postgres.yml"
      check_interpolation "name: add-deployment-updater-external-db.yml" "${home}/operations/use-external-dbs.yml" "-o add-deployment-updater.yml" "-o add-deployment-updater-external-db.yml" "-l ${home}/operations/example-vars-files/vars-use-external-dbs.yml"

      check_interpolation "disable-interpolate-service-bindings.yml"

      check_interpolation "enable-bpm-garden.yml"
      check_interpolation "enable-iptables-logger.yml"
      check_interpolation "enable-mysql-tls.yml"
      check_interpolation "enable-nfs-volume-service-credhub.yml"
      check_interpolation "enable-oci-phase-1.yml"
      check_interpolation "enable-smb-volume-service.yml"
      check_interpolation "enable-suspect-actual-lrp-generation.yml"
      check_interpolation "enable-traffic-to-internal-networks.yml"
      check_interpolation "name: enable-tls-cloud-controller-postgres.yml" "${home}/operations/use-postgres.yml" "-o enable-tls-cloud-controller-postgres.yml"

      check_interpolation "fast-deploy-with-downtime-and-danger.yml"

      check_interpolation "infrastructure-metrics.yml"

      check_interpolation "name: migrate-nfsbroker-mysql-to-credhub.yml" "${home}/operations/enable-nfs-volume-service.yml" "-o enable-nfs-volume-service-credhub.yml" "-o migrate-nfsbroker-mysql-to-credhub.yml" -l "${home}/operations/example-vars-files/vars-migrate-nfsbroker-mysql-to-credhub.yml"
      check_interpolation "name: migrate-nfsbroker-mysql-to-credhub.yml" "${home}/operations/enable-nfs-volume-service.yml" "-o migrate-nfsbroker-mysql-to-credhub.yml" -l "${home}/operations/example-vars-files/vars-migrate-nfsbroker-mysql-to-credhub.yml"

      check_interpolation "name: perm-service.yml" "enable-mysql-tls.yml" "-o perm-service.yml -v perm_uaa_clients_cc_perm_secret=perm_secret -v perm_uaa_clients_perm_monitor_secret=perm_monitor_secret"
      check_interpolation "name: perm-service-with-pxc-release.yml" "perm-service.yml" "-o ${home}/operations/use-pxc.yml" "-o perm-service-with-pxc-release.yml -v perm_uaa_clients_cc_perm_secret=perm_secret -v perm_uaa_clients_perm_monitor_secret=perm_monitor_secret"
      check_interpolation "name: perm-service-with-tcp-routing.yml" "perm-service.yml" "-o ${home}/operations/use-pxc.yml" "-o perm-service-with-pxc-release.yml -v perm_uaa_clients_cc_perm_secret=perm_secret -v perm_uaa_clients_perm_monitor_secret=perm_monitor_secret" "-o perm-service-with-tcp-routing.yml"

      check_interpolation "rootless-containers.yml"

      check_interpolation "set-cpu-weight.yml"

      check_interpolation "name: use-compiled-releases-windows.yml" "${home}/operations/use-compiled-releases.yml" "-o ${home}/operations/windows2012R2-cell.yml" "-o use-compiled-releases-windows.yml"
      check_interpolation "use-create-swap-delete-vm-strategy.yml"
      check_interpolation "use-native-garden-runc-runner.yml"
      check_interpolation "use-logcache-for-cloud-controller-app-stats.yml"

      check_interpolation "name: windows-component-syslog-ca.yml" "windows-enable-component-syslog.yml" "-o windows-component-syslog-ca.yml" "-l ${home}/operations/addons/example-vars-files/vars-enable-component-syslog.yml"
      check_interpolation "name: windows-enable-component-syslog.yml" "windows-enable-component-syslog.yml" "-l ${home}/operations/addons/example-vars-files/vars-enable-component-syslog.yml"
      check_interpolation "name: enable-routing-integrity-windows1803.yml" "../windows1803-cell.yml" "-o enable-routing-integrity-windows1803.yml"
      check_interpolation "name: enable-routing-integrity-windows2016.yml" "../windows2016-cell.yml" "-o enable-routing-integrity-windows2016.yml"

      check_interpolation "deploy-forwarder-agent.yml"
      check_interpolation "add-syslog-agent.yml"
      check_interpolation "name: add-syslog-agent-windows1803.yml" "../windows1803-cell.yml" "-o add-syslog-agent.yml" "-o add-syslog-agent-windows1803.yml"

      check_interpolation "add-system-metrics-agent.yml"
      check_interpolation "name: add-system-metrics-agent-windows1803.yml" "../windows1803-cell.yml" "-o add-system-metrics-agent.yml" "-o add-system-metrics-agent-windows1803.yml"

      check_interpolation "add-metric-store.yml"

    popd > /dev/null # operations/experimental
  popd > /dev/null
  exit $exit_code
}
