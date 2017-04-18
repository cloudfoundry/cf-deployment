#!/bin/bash

pushd $(dirname $0) > /dev/null
diff -wB -C5 fixture/default-values-cf-manifest.yml <(spiff merge vars-store-template.yml vars-pre-processing-template.yml)

status=$?
if [ "$status" == "0" ]; then
  echo PASS
else
  echo FAIL
fi

popd > /dev/null

exit $status
