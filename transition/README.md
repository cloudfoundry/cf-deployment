# Transition
The tools in this directory
have not been tested
in any actual transitions.

Do not use them
except if you wish to discover
the ways in which they may fail.

## Usage
```
usage: transition.sh [required arguments]
  required arguments:
    -ca, --ca-keys         Path to your created CA Keys file
    -cf, --cf-manifest     Path to your existing Cloud Foundry Manifest
    -d,  --diego-manifest  Path to your existiong Diego Manifest
```
This is intended to result
in a vars-store file you can use
with the `--vars-store` option
when deploying with `cf-deployment`
and the new `bosh` CLI.

When you deploy with this vars-store,
you will also need to use
the ops-file located in
`cf-deployment/operations/test/cfr-to-cfd-transition.yml`.

### Yes, Spiff
These tools use spiff templates
to extract values from a deployment manifest
based on `cf-release`,
and store them in a vars-store
for use with `cf-deployment`
and the new `bosh` cli.

To install `spiff`,
download the latest binary [here][spiff-releases],
extract it from its tarball,
and put it on your path.

### Why Create a CA Private Key Stubs File
While we can automatically obtain 
your CA certificates
from your existing CF manifest,
we're unable to do the same for 
their private keys.

`CF Release` relied on
the Bosh 1.x CLI,
which did not have a role
in managing your deployments' certificates.
The Bosh 2.x CLI 
that `CF Deployment` relies on now, does.

In order to transition your CF deployment 
to the new world,
we'll need your help.
Providing the CA keys to us now allows 
Bosh to use the correct CA cert and key to 
sign new certificates as they become necessary
in the future.

The CA private key stub file is required.

### Example CA Private Keys Stubs File
```
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
```

### Tests and Contributions
We're happy to accept feedback
in the form of issues and pull-requests.
If you make a change,
please run our tests
with `transition/test-suite.sh`,
and update the fixtures appropriately.

[spiff-releases]: https://github.com/cloudfoundry-incubator/spiff/releases

