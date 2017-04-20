#!/bin/bash -e

# Colors!
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

function help() {
  echo -e "${GREEN}usage${NC}: $0 [required arguments]"
  echo "  required arguments:"
  echo -e "   ${GREEN}-ca, --ca-keys${NC}         Path to your created CA Keys file"
  echo -e "   ${GREEN}-cf, --cf-manifest${NC}     Path to your existing Cloud Foundry Manifest"
  echo -e "   ${GREEN}-d,  --diego-manifest${NC}  Path to your existiong Diego Manifest"
  echo -e "   ${GREEN}-h,  --help${NC}            Print this here message"
}

function ca_key_stub_help() {
cat <<EOF
$(echo -e "${RED}You must create a Certificate Authority Key stub and provide it to $0.${NC}")
The file must be valid yaml with the following schema:
  ---
  from_user:
    diego_ca:
      private_key: |+
        multi
        line
        example
        key
    etcd_ca:
      private_key: |+
    etcd_peer_ca:
      private_key: |+
    consul_agent_ca:
      private_key: |+
    loggregator_ca:
      private_key: |+
    router_ca:
      private_key: |+
    uaa_ca:
      private_key: |+

$(echo -e "${GREEN}More details can be found in our README.md${NC}")
EOF
  echo
}

function check_params() {
  local ca_keys=false
  local cf_manifest=false
  local diego_manifest=false
  local error_message="${RED}Error: ${NC}"

  if [[ -f $CA_KEYS ]]; then
    ca_keys=true
  else
    echo $CA_KEYS
    error_message="$error_message CA keys stub required."
  fi

  if [[ -f $CF_MANIFEST ]]; then
    cf_manifest=true
  else
    error_message="$error_message CF manifest required."
  fi
  if [[ -f $DIEGO_MANIFEST ]]; then
    diego_manifest=true
  else
    error_message="$error_message Diego manifest required."
  fi

  if [[ $ca_keys == false || $cf_manifest == false || $diego_manifest == false ]]; then
    echo -e $error_message
    echo
    help
    echo
    if [[ $ca_keys == false ]]; then
      ca_key_stub_help
    fi
    exit 1
  fi
}

function parse_args() {
  while [[ $# -gt 0 ]]
  do
    key="$1"
    case $key in
      -ca|--ca-keys)
      CA_KEYS="$2"
      shift # past argument
      ;;
      -cf|--cf-manifest)
      CF_MANIFEST="$2"
      shift # past argument
      ;;
      -d|--diego-manifest)
      DIEGO_MANIFEST="$2"
      shift # past argument
      ;;
      -h|--help)
      help
      exit 0
      ;;
      *)
              # unknown option
      ;;
    esac
    shift # past argument or value
  done
}

function check_ca_private_keys() {
  spiff_temp_output=$(mktemp)
  echo $spiff_temp_output
cat > $spiff_temp_output <<EOF
$(spiff merge vars-ca-template.yml $CA_KEYS 2>&1 >/dev/null)
EOF
  local all_the_cas="diego_ca etcd_ca etcd_peer_ca uaa_ca router_ca consul_agent_ca loggregator_ca"
  for ca in $all_the_cas
  do
    check_ca_private_key $ca
  done
  rm $spiff_temp_output
}

function check_ca_private_key() {
  local ca_key_name=$1
  local ca_key_error=""

  ca_key_error=$(cat $spiff_temp_output | grep merge | grep $ca_key_name)
  if [[ $ca_key_error != "" ]]; then
    echo "CA Key [ $ca_key_name ] not found in [ $CA_KEYS ]!"
  fi
}

function main() {
  check_params
  check_ca_private_keys
}

parse_args "$@"
main
