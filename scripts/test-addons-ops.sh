#!/bin/bash

test_addons_ops() {
  # Padded for pretty output
  suite_name="ADDONS      "

  pushd ${home} > /dev/null
    pushd operations/addons > /dev/null
      check_interpolation "enable-component-syslog.yml" "-v syslog_address=papertrail-address.com" "-v syslog_port=5473" "-v syslog_transport=tcp" "-v syslog_fallback_servers=[]" "-v syslog_custom_rule=\"\""
    popd > /dev/null # operations/addons
  popd > /dev/null
  exit $exit_code
}
