#!/bin/bash -e

# Colors!
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

SCRIPT_DIR=$(dirname $0)

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
      private_key: |
        multi
        line
        example
        key
    etcd_ca:
      private_key: |
    etcd_peer_ca:
      private_key: |
    consul_agent_ca:
      private_key: |
    loggregator_ca:
      private_key: |
    uaa_ca:
      private_key: |

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

  # There is likely a more elegant way to do this.  Our first pass is to just
  # cat std_err from Spiff out to a temp file so we can grep over it.
cat > $spiff_temp_output <<EOF
$(spiff merge $SCRIPT_DIR/vars-ca-template.yml $CA_KEYS 2>&1 >/dev/null)
EOF

  # If there is no error output to look at, then Spiff is saying we're good to
  # go.  Return 0 and carry on.
  # For some reason, the above heredoc does not result in an empty file, so
  # testing with -s fails.  Instead, we'll just return on a file with single line.
  if [[ $(cat $spiff_temp_output | wc -l) -eq 1 ]]; then
    rm -f $spiff_temp_output
    return 0
  fi

  # There must be error output.  Use it to find which key(s) we're missing.
  local all_the_cas="diego_ca etcd_ca etcd_peer_ca uaa_ca consul_agent_ca loggregator_ca"
  for ca in $all_the_cas
  do
    check_ca_private_key $ca
  done
  rm $spiff_temp_output
}

function check_ca_private_key() {
  local ca_key_name=$1
  local ca_key_error=""

  ca_key_error=$(cat $spiff_temp_output | grep merge | grep $ca_key_name) || true
  if [[ $ca_key_error != "" ]]; then
    echo "CA Key [ $ca_key_name ] not found in [ $CA_KEYS ]!"
  fi
}

function extract_uaa_jwt_value() {
  local uaa_jwt_spiff_template
  uaa_jwt_spiff_template="${1}"

  uaa_jwt_active_key=$(bosh interpolate $CF_MANIFEST --path=/properties/uaa/jwt/policy/active_key_id)
  uaa_jwt_value=$(bosh interpolate $CF_MANIFEST --path=/properties/uaa/jwt/policy/keys/${uaa_jwt_active_key}/signingKey | sed -e 's/^/    /')

  cat > $uaa_jwt_spiff_template << EOF
uaa_jwt_signing_key:
  private_key: |+
${uaa_jwt_value}
EOF
}

function spiff_it() {
  uaa_jwt_spiff_template=$(mktemp)

  extract_uaa_jwt_value "${uaa_jwt_spiff_template}"

  spiff merge \
  $SCRIPT_DIR/vars-store-template.yml \
  $SCRIPT_DIR/vars-pre-processing-template.yml \
  $SCRIPT_DIR/vars-ca-template.yml \
  $CF_MANIFEST \
  $DIEGO_MANIFEST \
  $CA_KEYS \
  $uaa_jwt_spiff_template \
  > deployment-vars.yml
}

function main() {
  check_params
  check_ca_private_keys
  spiff_it
  echo -e "${GREEN}Merge successful!${NC}"
  echo "Please find your new vars store file in $PWD/deployment-vars.yml"
}

parse_args "$@"
main
