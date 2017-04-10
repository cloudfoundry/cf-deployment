# Transition
The tools in this directory
have not been tested
in any actual transitions.

Do not use them
except if you wish to discover
the ways in which they may fail.

## Usage
```
spiff merge \
vars-store-template.yml \
vars-pre-processing-template.ym \
<your-cf-manifest.yml> \
<your-diego-manifest.yml> | grep -v bosh-will-generate-me \
> deployment-vars.yml
```

This is intended to result
in a vars-store file you can use
with the `--vars-store` option
when deploying with `cf-deployment`
and the new `bosh` CLI.

When you deploy with this vars-store,
you will also need to use
the ops-file in this directory,
`transition-ops.yml`.

## Yes, Spiff
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

## Tests and Contributions
We're happy to accept feedback
in the form of issues and pull-requests.
If you make a change,
please run our tests
with `test-transition-ops.sh`,
and update the fixtures appropriately.

[spiff-releases]: https://github.com/cloudfoundry-incubator/spiff/releases

