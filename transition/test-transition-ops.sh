#!/bin/bash

# NB: our test does not assert that the value that we're looking for is not already present
# in cf-deployment.yml prior to having ops applied.  We believe this is unimportant to us.
status=0
ops_path=transition-ops.yml
blobstore_user=$(bosh interpolate ../cf-deployment.yml -o $ops_path --path=/instance_groups/name=blobstore/jobs/name=blobstore/properties/blobstore/admin_users/0/username)
if [ "${blobstore_user}" == "(( blobstore_admin_users_username ))" ];then
  echo PASS blobstore_user
else
  echo FAIL blobstore_user $blobstore_user "!=" "(( blobstore_admin_users_username ))"
  status=1
fi

exit $status
