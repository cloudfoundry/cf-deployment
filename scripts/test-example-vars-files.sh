#!/bin/bash

test_example_vars_files() {
  set +e
  directories="$(find . -name example-vars-files)"
  for directory in $directories; do
    path="$(echo $directory | cut -c 3-)"
    echo -e "${GREEN} ~~~ Testing ${path} ~~~ ${NOCOLOR}"
    test_example_vars_files_in_directory $directory
  done
  set -e
  exit $exit_code
}

test_example_vars_files_in_directory() {
  # Padded for pretty output
  suite_name="VARS              "
  pushd $directory > /dev/null
    example_vars_files="$(ls)"
    cf_d_variables="$(yq read ${home}/cf-deployment.yml -j | jq [.variables[].name])"
    for example_vars_file in $example_vars_files; do
      ops_file="$(echo "${example_vars_file}" | cut -c 6-)"
      if [ ! -f ../${ops_file} ]; then
        fail "$ops_file does not exist OR ${example_vars_file} does not follow the vars-ops-file-name.yml format"
      else
        if [ "$(are_all_present_variables_used)" = "no" ]; then
          fail "$ops_file failed because it has example variables that are not used"
        else
          if [ "$(are_all_needed_variables_present)" = "yes" ]; then
            pass "$ops_file"
          else
            if [ "$(is_it_the_error_we_expect)" = "no" ]; then
              fail "$ops_file failed because of an unknown bosh error message"
            else
              if [ "$(are_missing_variables_in_cf_d)" = "no" ]; then
                fail "$ops_file failed because not all missing variables are in cf_d"
              else
                pass "$ops_file"
              fi
            fi
          fi
        fi
      fi
    done
  popd > /dev/null
}
are_missing_variables_in_cf_d() {
  tail -n +2 /tmp/errors.txt  | tail -r | tail -n +2 | cut -c 7- > /tmp/yaml-errors.txt
  missing_variables="$(yq read /tmp/yaml-errors.txt)"
  for variable in $missing_variables; do
    length="$(echo $cf_d_variables | jq --arg variable "$variable" 'map(select(. == $variable))' | jq length)"
    if [ $length != "1" ]; then
      echo "no"
    else
      echo "yes"
    fi
  done
}

is_it_the_error_we_expect() {
  cat /tmp/errors.txt |  grep ":" | wc -l | grep "       1" > /dev/null
  code1=$?
  cat /tmp/errors.txt |  grep "Expected to find variables:" > /dev/null
  code2=$?
  if [ $code1 = "0" ] && [ $code2 = "0" ]; then
    echo "yes"
  else
    echo "no"
  fi
}

are_all_needed_variables_present() {
  bosh int "../${ops_file}" -l "${example_vars_file}" --var-errs > /dev/null 2> /tmp/errors.txt
  exit_code=$?
  if [ $exit_code = "0" ]; then
    echo "yes"
  else
    echo "no"
  fi
}

are_all_present_variables_used() {
  bosh int "../${ops_file}" -l "${example_vars_file}" --var-errs-unused &> /dev/null
  exit_code=$?
  if [ $exit_code == "0" ]; then
    echo "yes"
  else
    echo "no"
  fi
}
