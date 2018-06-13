#!/bin/bash

test_example_vars_files() {
  # Padded for pretty output
  suite_name="vars              "

  pushd ${home}/operations/example-vars-files > /dev/null
    example_vars_files="$(ls)"
    for example_vars_file in $example_vars_files; do
      ops_file="$(echo "${example_vars_file}" | cut -c 6-)"
      echo $ops_file
      bosh int "${home}/operations/${ops_file}" -l "${home}/operations/example-vars-files/${example_vars_file}" --var-errs --var-errs-unused > /dev/null
    done
  popd > /dev/null
  exit $exit_code
}
