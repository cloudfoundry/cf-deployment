#!/bin/bash

test_example_vars_files() {
  set +e
  # Padded for pretty output
  suite_name="vars              "

  pushd ${home}/operations/example-vars-files > /dev/null
    example_vars_files="$(ls)"
    cf_d_variables="$(yq read ../../cf-deployment.yml -j | jq [.variables[].name])"
    export VARS=${cf_d_variables}

    for example_vars_file in $example_vars_files; do
      ops_file="$(echo "${example_vars_file}" | cut -c 6-)"
      echo $ops_file
      bosh int "${home}/operations/${ops_file}" -l "${home}/operations/example-vars-files/${example_vars_file}" --var-errs-unused &> /dev/null
      exit_code=$?

      if [ $exit_code == "0" ]; then
        bosh int "${home}/operations/${ops_file}" -l "${home}/operations/example-vars-files/${example_vars_file}" --var-errs > /dev/null 2> /tmp/errors.txt
        exit_code=$?

        if [ $exit_code != "0" ]; then
          cat /tmp/errors.txt |  grep ":" | wc -l | grep "1" > /dev/null
          code1=$?
          cat /tmp/errors.txt |  grep "Expected to find variables:" > /dev/null
          code2=$?

          if [ $code1 == "0" ] && [ $code2 == "0" ]; then
            tail -n +2 /tmp/errors.txt  | tail -r | tail -n +2 | cut -c 7- > /tmp/yaml-errors.txt
            missing_variables="$(yq read /tmp/yaml-errors.txt)"

            for variable in $missing_variables; do
              length="$(echo $cf_d_variables | jq --arg variable "$variable" 'map(select(. == $variable))' | jq length)"

              if [ $length != "1" ]; then
                fail "$ops_file"
              else
                pass "$ops_file"
              fi
            done
          else
            fail "$ops_file"
          fi
        else
          pass "$ops_file"
        fi
      else
        fail "$ops_file"
      fi
    done
  popd > /dev/null
  set -e
  exit $exit_code
}

#functionify above
#restructure pass/fail statements
#add custom error messages
#test most edge cases: (eg, no vars-... file exists etc)

