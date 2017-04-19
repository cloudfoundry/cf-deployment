#!/bin/bash

pushd $(dirname $0) > /dev/null
diff -wB -C5 fixture/expected-vars-store.yml <(spiff merge \
  vars-store-template.yml \
  vars-pre-processing-template.yml \
  vars-ca-template.yml \
  fixture/source-cf-manifest.yml \
  fixture/source-diego-manifest.yml \
  fixture/ca-private-keys.yml )

status=$?
if [ "$status" == "0" ]; then
  echo PASS - expected-vars-store
else
  echo FAIL - expected-vars-store
fi

popd > /dev/null

exit $status
