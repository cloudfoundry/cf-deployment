#!/bin/bash

fail_required_keys=0
fail_filling_in=0
pushd $(dirname $0) > /dev/null
  spiff merge vars-ca-template.yml 2&> /dev/null
  if [ "$?" == "1" ]; then
    echo PASS - the ca template requires filling in keys
  else
    fail_required_keys=1
    echo FAIL - the ca template requires filling in keys
  fi

  spiff merge vars-ca-template.yml fixture/ca-private-keys.yml > /dev/null
  if [ "$?" == "0" ]; then
    echo PASS - the ca template can be filled completely with keys
  else
    fail_filling_in=1
    echo FAIL - the ca template can be filled completely with keys
  fi
popd > /dev/null

if [[ "$fail_required_keys" == "1" || "$fail_filling_in" == "1" ]]; then
  exit 1
else
  exit 0
fi

