#!/bin/bash

# NB: our test does not assert that the value that we're looking for is not already present
# in cf-deployment.yml prior to having ops applied.  We believe this is unimportant to us.
pushd $(dirname $0) > /dev/null
status=0
ops_path=transition-ops.yml
blobstore_user=$(bosh interpolate ../cf-deployment.yml -o $ops_path --path=/instance_groups/name=blobstore/jobs/name=blobstore/properties/blobstore/admin_users/0/username)
ccdb_user=$(bosh interpolate ../cf-deployment.yml -o $ops_path --path=/instance_groups/name=api/jobs/name=cloud_controller_ng/properties/ccdb/roles/0/name)
uaa_jwt_policy=$(bosh interpolate ../cf-deployment.yml -o $ops_path --path=/instance_groups/name=uaa/jobs/name=uaa/properties/uaa/jwt)

if [ "${blobstore_user}" == "(( blobstore_admin_users_username ))" ];then
  echo PASS - blobstore_user
else
  echo FAIL - blobstore_user $blobstore_user "!=" "(( blobstore_admin_users_username ))"
  status=1
fi

if [ "${ccdb_user}" == "(( cc_database_username ))" ];then
  echo PASS - ccdb_user
else
  echo FAIL - ccdb_user $ccdb_user "!=" "(( cc_database_username ))"
  status=1
fi

if [ "${uaa_jwt_policy}" == "(( uaa_jwt_policy ))" ];then
  echo PASS - uaa_jwt_policy
else
  echo FAIL - uaa_jwt_policy $uaa_jwt_policy "!=" "(( uaa_jwt_policy ))"
  status=1
fi

popd > /dev/null

exit $status
