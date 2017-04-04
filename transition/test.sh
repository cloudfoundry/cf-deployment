#!/bin/bash

pushd $(dirname $0) > /dev/null
diff fixture/expected-vars-store.yml <(spiff merge vars-store-template.yml vars-pre-processing-template.yml fixture/source-cf-manifest.yml)

status=$?
if [ "$status" == "0" ]; then
  echo PASS
else
  echo FAIL
fi

popd > /dev/null

exit $status
