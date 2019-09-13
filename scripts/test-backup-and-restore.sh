#!/bin/bash

test_backup_and_restore_ops() {
  # Padded for pretty output
  suite_name="BACKUP AND RESTORE"

  pushd ${home} > /dev/null
    pushd operations/backup-and-restore > /dev/null
      ensure_singleton_blobstore_not_templated "skip-backup-restore-droplets.yml"
      ensure_singleton_blobstore_not_templated "skip-backup-restore-droplets-and-packages.yml"
      ensure_properties_are_in_sync "nfs" "nfsbrokerpush"
      ensure_properties_are_in_sync "smb" "smbbrokerpush"
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
