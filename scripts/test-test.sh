#!/bin/bash

test_test_ops() {
  # Padded for pretty output
  suite_name="TEST              "

  pushd ${home} > /dev/null
    pushd operations/test > /dev/null
      check_interpolation "add-datadog-firehose-nozzle.yml" "-v datadog_api_key=XYZ" "-v datadog_metric_prefix=foo.bar" "-v traffic_controller_external_port=8443"
      check_interpolation "add-oidc-provider.yml"
      check_interpolation "add-persistent-isolation-segment-diego-cell.yml"
      check_interpolation "name: add-persistent-isolation-segment-diego-cell-bosh-lite.yml" "add-persistent-isolation-segment-diego-cell.yml" "-o add-persistent-isolation-segment-diego-cell-bosh-lite.yml"
      check_interpolation "add-persistent-isolation-segment-router.yml"
      check_interpolation "alter-ssh-proxy-redirect-uri.yml"
      check_interpolation "enable-nfs-test-server.yml"
      check_interpolation "name: enable-nfs-test-ldapserver.yml" "${home}/operations/enable-nfs-volume-service.yml" "-o enable-nfs-test-server.yml" "-o enable-nfs-test-ldapserver.yml"
      check_interpolation "enable-smb-test-server.yml" "-v smb-password=FOO.PASS" "-v smb-username=BAR.USER"
      check_interpolation "name: add-persistent-isolation-segment-logging-system.yml" "add-persistent-isolation-segment-diego-cell.yml" "-o add-persistent-isolation-segment-logging-system.yml"
      check_interpolation "name: add-persistent-isolation-segment-syslog-drain.yml" "add-persistent-isolation-segment-diego-cell.yml" "-o add-persistent-isolation-segment-logging-system.yml" "-o add-persistent-isolation-segment-syslog-drain.yml"
      check_interpolation "name: alter-router-for-log-agent.yml" "add-persistent-isolation-segment-router.yml" "-o add-persistent-isolation-segment-diego-cell.yml" "-o add-persistent-isolation-segment-logging-system.yml" "-o alter-router-for-log-agent.yml"
      check_interpolation "name: isolated-logging-system-with-windows-cells.yml" "add-persistent-isolation-segment-diego-cell.yml" "-o add-persistent-isolation-segment-logging-system.yml" "-o ${home}/operations/windows2012R2-cell.yml" "-o ${home}/operations/windows1803-cell.yml" "-o isolated-logging-system-with-windows-cells.yml"
      check_interpolation "name: add-persistent-isolation-segment-infrastructure-metrics.yml" "${home}/operations/experimental/infrastructure-metrics.yml" "-o add-persistent-isolation-segment-diego-cell.yml" "-o add-persistent-isolation-segment-logging-system.yml" "-o add-persistent-isolation-segment-infrastructure-metrics.yml"
    popd > /dev/null # operations/test
  popd > /dev/null
  exit $exit_code
}
