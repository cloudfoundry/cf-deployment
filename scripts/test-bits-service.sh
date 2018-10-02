#!/bin/bash

test_bits_service_ops() {
  # Padded for pretty output
  suite_name="BITS SERVICE      "

  pushd ${home} > /dev/null
    pushd operations/bits-service > /dev/null
      check_interpolation "use-bits-service.yml"
      check_interpolation "name: configure-bits-service-s3.yml" "${home}/operations/use-external-blobstore.yml" "-o ${home}/operations/use-s3-blobstore.yml" "-o use-bits-service.yml" "-o configure-bits-service-s3.yml" "-l ${home}/operations/example-vars-files/vars-use-s3-blobstore.yml"
      check_interpolation "name: configure-bits-service-alicloud-oss.yml" "${home}/operations/use-external-blobstore.yml" "-o ${home}/operations/use-alicloud-oss-blobstore.yml" "-o use-bits-service.yml" "-o configure-bits-service-alicloud-oss.yml" "-l ${home}/operations/example-vars-files/vars-use-alicloud-oss-blobstore.yml"
      check_interpolation "name: configure-bits-service-azure-storage.yml" "${home}/operations/use-external-blobstore.yml" "-o ${home}/operations/use-azure-storage-blobstore.yml" "-o use-bits-service.yml" "-o configure-bits-service-azure-storage.yml" "-l ${home}/operations/example-vars-files/vars-use-azure-storage-blobstore.yml"
      check_interpolation "name: configure-bits-service-gcs-service-account.yml" "${home}/operations/use-external-blobstore.yml" "-o ${home}/operations/use-gcs-blobstore-service-account.yml" "-o use-bits-service.yml" "-o configure-bits-service-gcs-service-account.yml" "-l ${home}/operations/example-vars-files/vars-use-gcs-blobstore-service-account.yml"
      check_interpolation "name: configure-bits-service-gcs-access-key.yml" "${home}/operations/use-external-blobstore.yml" "-o ${home}/operations/use-gcs-blobstore-access-key.yml" "-o use-bits-service.yml" "-o configure-bits-service-gcs-access-key.yml" "-l ${home}/operations/example-vars-files/vars-use-gcs-blobstore-access-key.yml"
      check_interpolation "name: configure-bits-service-swift.yml" "${home}/operations/use-external-blobstore.yml" "-o ${home}/operations/use-swift-blobstore.yml" "-o use-bits-service.yml" "-o configure-bits-service-swift.yml" "-l ${home}/operations/example-vars-files/vars-use-swift-blobstore.yml"
    popd > /dev/null
  popd > /dev/null
  exit $exit_code
}
