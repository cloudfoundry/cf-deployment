#!/bin/bash

test_test_ops() {
  # Padded for pretty output
  suite_name="TEST              "

  pushd ${home} > /dev/null
    pushd operations/test > /dev/null
      check_interpolation "add-datadog-firehose-nozzle.yml" "-v datadog_api_key=XYZ" "-v datadog_metric_prefix=foo.bar" "-v traffic_controller_external_port=8443"
      check_interpolation "add-persistent-isolation-segment-diego-cell.yml"
      check_interpolation "name: add-persistent-isolation-segment-diego-cell-bosh-lite.yml" "add-persistent-isolation-segment-diego-cell.yml" "-o add-persistent-isolation-segment-diego-cell-bosh-lite.yml"
      check_interpolation "add-persistent-isolation-segment-router.yml"
      check_interpolation "alter-ssh-proxy-redirect-uri.yml"
      check_interpolation "name: disable_windows_consul_agent_nameserver_overwriting.yml" "${home}/operations/windows2012R2-cell.yml" "-o disable_windows_consul_agent_nameserver_overwriting.yml"
      check_interpolation "name: windows2016-debug.yml" "${home}/operations/windows2012R2-cell.yml"
      check_interpolation "name: windows1803-debug.yml" "${home}/operations/experimental/windows1803-cell.yml"
      check_interpolation "add-oidc-provider.yml"
    popd > /dev/null # operations/test
  popd > /dev/null
  exit $exit_code
}
