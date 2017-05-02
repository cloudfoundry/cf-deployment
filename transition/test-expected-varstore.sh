#!/bin/bash

pushd $(dirname $0) > /dev/null
root_dir=$PWD
  pushd $(mktemp -d) > /dev/null

    ${root_dir}/transition.sh \
      -cf ${root_dir}/fixture/source-cf-manifest.yml \
      -d ${root_dir}/fixture/source-diego-manifest.yml \
      -ca ${root_dir}/fixture/ca-private-keys.yml > /dev/null

    diff -wB -C5 ${root_dir}/fixture/expected-vars-store.yml deployment-vars.yml

    status=$?
    if [ "$status" == "0" ]; then
      echo PASS - expected-vars-store
    else
      echo FAIL - expected-vars-store
    fi

  popd > /dev/null
popd > /dev/null

exit $status
