#!/bin/bash

test_backup_and_restore_ops() {
  # Padded for pretty output
  suite_name="BACKUP AND RESTORE"

  pushd ${home} > /dev/null
    pushd operations/backup-and-restore > /dev/null

      # internal
      check_interpolation "name: enable-backup-restore.yml" "enable-backup-restore.yml"

      # internal skip-droplets & skip-droplets-and-packages
      check_interpolation "name: skip-backup-restore-droplets.yml" "enable-backup-restore.yml" "-o skip-backup-restore-droplets.yml"
      check_interpolation "name: skip-backup-restore-droplets-and-packages.yml" "enable-backup-restore.yml" "-o skip-backup-restore-droplets-and-packages.yml"

      check_internal_blobstore_properties "$(echo -e '- buildpacks\n- packages\n- droplets')" ""
      check_internal_blobstore_properties "$(echo -e '- buildpacks\n- packages')" "-o skip-backup-restore-droplets.yml"
      check_internal_blobstore_properties "$(echo -e '- buildpacks')" "-o skip-backup-restore-droplets-and-packages.yml"

      ensure_singleton_blobstore_not_templated "skip-backup-restore-droplets.yml"
      ensure_singleton_blobstore_not_templated "skip-backup-restore-droplets-and-packages.yml"

      # s3 versioned & unversioned
      check_interpolation "name: enable-backup-restore-s3-versioned.yml"   "enable-backup-restore.yml" "-o ${home}/operations/use-external-blobstore.yml" "-o ${home}/operations/use-s3-blobstore.yml" "-o enable-backup-restore-s3-versioned.yml"   "-l ${home}/operations/example-vars-files/vars-use-s3-blobstore.yml"
      check_interpolation "name: enable-backup-restore-s3-unversioned.yml" "enable-backup-restore.yml" "-o ${home}/operations/use-external-blobstore.yml" "-o ${home}/operations/use-s3-blobstore.yml" "-o enable-backup-restore-s3-unversioned.yml" "-l ${home}/operations/example-vars-files/vars-use-s3-blobstore.yml" "-l example-vars-files/vars-enable-backup-restore-s3-unversioned.yml"

      # s3 versioned & unversioned, skip-droplets & skip-droplets-and-packages
      check_interpolation "name: skip-backup-restore-droplets.yml (with s3 ver)"   "enable-backup-restore.yml" "-o ${home}/operations/use-external-blobstore.yml" "-o ${home}/operations/use-s3-blobstore.yml" "-o enable-backup-restore-s3-versioned.yml" "-o skip-backup-restore-droplets.yml"  "-l ${home}/operations/example-vars-files/vars-use-s3-blobstore.yml"
      check_interpolation "name: skip-backup-restore-droplets-and-packages.yml (with s3 ver)"   "enable-backup-restore.yml" "-o ${home}/operations/use-external-blobstore.yml" "-o ${home}/operations/use-s3-blobstore.yml" "-o enable-backup-restore-s3-versioned.yml" "-o skip-backup-restore-droplets-and-packages.yml"  "-l ${home}/operations/example-vars-files/vars-use-s3-blobstore.yml"

      check_interpolation "name: skip-backup-restore-droplets.yml (with s3 unver)"   "enable-backup-restore.yml" "-o ${home}/operations/use-external-blobstore.yml" "-o ${home}/operations/use-s3-blobstore.yml" "-o enable-backup-restore-s3-unversioned.yml" "-o skip-backup-restore-droplets.yml"  "-l ${home}/operations/example-vars-files/vars-use-s3-blobstore.yml" "-l example-vars-files/vars-enable-backup-restore-s3-unversioned.yml"
      check_interpolation "name: skip-backup-restore-droplets-and-packages.yml (with s3 unver)"   "enable-backup-restore.yml" "-o ${home}/operations/use-external-blobstore.yml" "-o ${home}/operations/use-s3-blobstore.yml" "-o enable-backup-restore-s3-unversioned.yml" "-o skip-backup-restore-droplets-and-packages.yml"  "-l ${home}/operations/example-vars-files/vars-use-s3-blobstore.yml" "-l example-vars-files/vars-enable-backup-restore-s3-unversioned.yml"

      # azure
      check_interpolation "name: enable-backup-restore-azure.yml" "enable-backup-restore.yml" "-o ${home}/operations/use-external-blobstore.yml" "-o ${home}/operations/use-azure-storage-blobstore.yml" "-o enable-backup-restore-azure.yml" "-l ${home}/operations/example-vars-files/vars-use-azure-storage-blobstore.yml"
      check_interpolation "name: enable-restore-azure-clone.yml"  "enable-backup-restore.yml" "-o ${home}/operations/use-external-blobstore.yml" "-o ${home}/operations/use-azure-storage-blobstore.yml" "-o enable-restore-azure-clone.yml"  "-l ${home}/operations/example-vars-files/vars-use-azure-storage-blobstore.yml" "-l example-vars-files/vars-enable-restore-azure-clone.yml"

      # azure skip-droplets & skip-droplets-and-packages
      check_interpolation "name: skip-backup-restore-droplets.yml (with azure)" "enable-backup-restore.yml" "-o ${home}/operations/use-external-blobstore.yml" "-o ${home}/operations/use-azure-storage-blobstore.yml" "-o enable-backup-restore-azure.yml" "-o skip-backup-restore-droplets.yml" "-l ${home}/operations/example-vars-files/vars-use-azure-storage-blobstore.yml"
      check_interpolation "name: skip-backup-restore-droplets-and-packages.yml (with azure)" "enable-backup-restore.yml" "-o ${home}/operations/use-external-blobstore.yml" "-o ${home}/operations/use-azure-storage-blobstore.yml" "-o enable-backup-restore-azure.yml" "-o skip-backup-restore-droplets-and-packages.yml" "-l ${home}/operations/example-vars-files/vars-use-azure-storage-blobstore.yml"

      check_interpolation "name: skip-backup-restore-droplets.yml"  "enable-backup-restore.yml" "-o ${home}/operations/use-external-blobstore.yml" "-o ${home}/operations/use-azure-storage-blobstore.yml" "-o enable-restore-azure-clone.yml" "-o skip-backup-restore-droplets.yml" "-l ${home}/operations/example-vars-files/vars-use-azure-storage-blobstore.yml" "-l example-vars-files/vars-enable-restore-azure-clone.yml"
      check_interpolation "name: skip-backup-restore-droplets-and-packages.yml"  "enable-backup-restore.yml" "-o ${home}/operations/use-external-blobstore.yml" "-o ${home}/operations/use-azure-storage-blobstore.yml" "-o enable-restore-azure-clone.yml" "-o skip-backup-restore-droplets-and-packages.yml" "-l ${home}/operations/example-vars-files/vars-use-azure-storage-blobstore.yml" "-l example-vars-files/vars-enable-restore-azure-clone.yml"

      # gcs
      check_interpolation "name: enable-backup-restore-gcs.yml" "enable-backup-restore.yml" "-o ${home}/operations/use-external-blobstore.yml" "-o ${home}/operations/use-gcs-blobstore-service-account.yml" "-o enable-backup-restore-gcs.yml" "-l ${home}/operations/example-vars-files/vars-use-gcs-blobstore-service-account.yml" "-l ${home}/operations/backup-and-restore/example-vars-files/vars-enable-backup-restore-gcs.yml"

      # gcs skip-droplets & skip-droplets-and-packages
      check_interpolation "name: skip-backup-restore-droplets.yml (with gcs)" "enable-backup-restore.yml" "-o ${home}/operations/use-external-blobstore.yml" "-o ${home}/operations/use-gcs-blobstore-service-account.yml" "-o enable-backup-restore-gcs.yml" "-o skip-backup-restore-droplets.yml" "-l ${home}/operations/example-vars-files/vars-use-gcs-blobstore-service-account.yml" "-l ${home}/operations/backup-and-restore/example-vars-files/vars-enable-backup-restore-gcs.yml"
      check_interpolation "name: skip-backup-restore-droplets-and-packages.yml (with gcs)" "enable-backup-restore.yml" "-o ${home}/operations/use-external-blobstore.yml" "-o ${home}/operations/use-gcs-blobstore-service-account.yml" "-o enable-backup-restore-gcs.yml" "-o skip-backup-restore-droplets-and-packages.yml" "-l ${home}/operations/example-vars-files/vars-use-gcs-blobstore-service-account.yml" "-l ${home}/operations/backup-and-restore/example-vars-files/vars-enable-backup-restore-gcs.yml"

      # nfs
      check_interpolation "name: enable-backup-restore-nfs-broker.yml" "enable-backup-restore.yml" "-o enable-backup-restore-nfs-broker.yml" "-v nfs-broker-database-password=i_am_a_password"
      check_interpolation "name: enable-backup-restore-nfs-broker.yml" "enable-backup-restore.yml -o enable-backup-restore-nfs-broker.yml -v nfs-broker-database-password=i_am_a_password"
    popd > /dev/null
  popd > /dev/null
  exit $exit_code
}

ensure_properties_are_in_sync() {
  local component=$1
  local jobname=$2
  local manifest="$(mktemp)"
  local operations="${home}/operations"

  set +e
  interpolate "output: ${manifest}" "-o ${operations}/enable-${component}-volume-service.yml" "-o ${operations}/backup-and-restore/enable-backup-restore.yml" "-o ${home}/operations/backup-and-restore/enable-restore-${component}-broker.yml"

  diff <(bosh int $manifest --path /instance_groups/name=${component}-broker-push/jobs/name=${jobname}/properties) <(bosh int $manifest --path /instance_groups/name=backup-restore/jobs/name=${jobname}/properties)
  exit_code=$?
  set -e

  if [ "${exit_code}" == "0" ]; then
      pass "${jobname} properties in enable ops file and backup-restore ops file are in sync"
  else
      fail "${jobname} properties in enable ops file and backup-restore ops file have diverged"
  fi

  rm $manifest
  return $exit_code
}

check_internal_blobstore_properties() {
  local expected="$1"
  local selective_opsfile="$2"
  local output; output="$(mktemp)"

  interpolate "output: ${output}" "-o ${home}/operations/backup-and-restore/enable-backup-restore.yml" "${selective_opsfile}"

  set +e
  directories_to_backup="$(bosh int "$output" --path /instance_groups/name=singleton-blobstore/jobs/name=blobstore/properties/select_directories_to_backup)"
  exit_code=$?
  set -e

  local selective_opsfile="${2:-full blobstore}"
  if [ "${exit_code}" == "0" ] && [ "$directories_to_backup" == "$expected"  ]; then
      pass "${selective_opsfile#'-o '}"
  else
      fail "${selective_opsfile#'-o '}"
  fi
  rm "$output"
}

ensure_singleton_blobstore_not_templated() {
  local selective_opsfile="$1"
  local output; output=$(mktemp)
  local operations="${home}/operations"

  interpolate "output: ${output}" \
    "-o ${operations}/use-external-blobstore.yml" \
    "-o ${operations}/backup-and-restore/enable-backup-restore.yml" \
    "-o ${operations}/use-s3-blobstore.yml" \
    "-o ${operations}/backup-and-restore/enable-backup-restore-s3-versioned.yml" \
    "-l ${operations}/example-vars-files/vars-use-s3-blobstore.yml" \
    "-o ${operations}/backup-and-restore/${selective_opsfile}"

  set +e
  bosh int "$output" --path /instance_groups/name=singleton-blobstore &> /dev/null
  code=$?
  set -e

  if [ "${code}" != "0" ]; then
      exit_code=0
      pass "${selective_opsfile} does not render 'singleton-blobstore' instance_group"
  else
      fail "${selective_opsfile} does render 'singleton-blobstore' instance_group"
  fi
  rm "$output"
}
