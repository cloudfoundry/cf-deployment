#!/bin/bash

test_legacy_ops() {
  # Padded for pretty output
  suite_name="LEGACY      "

  pushd ${home} > /dev/null
    pushd operations/legacy > /dev/null
      check_interpolation "old-droplet-mitigation.yml"
      check_interpolation "keep-original-blobstore-directory-keys.yml" "-l example-vars-files/vars-keep-original-blobstore-directory-keys.yml"
      check_interpolation "keep-original-internal-usernames.yml" "-l example-vars-files/vars-keep-original-internal-usernames.yml"
      check_interpolation "keep-static-ips.yml" "-l example-vars-files/vars-keep-static-ips.yml"
    popd > /dev/null # operations/legacy
  popd > /dev/null
  exit $exit_code
}
