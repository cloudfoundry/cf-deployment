# CF-Deployment Unit Tests

## Table of Contents
1. [Types of Tests](#types-of-tests)
1. [Running](#running)
1. [Contributing](#contributing)
    - [New Interpolate Tests](#new-interpolate-tests)
    - [Validating Ops-File Actions](#validating-ops-file-actions)

## Types of tests
Each unit test subdirectory suite has a set of basic tests it runs.

- `EnsureTestCoverage`: validates that every operations file in the subdirectory has
at least one `InterpolateTest` test.
- `ReadmeTest`: validates that every operations file in the subdirectory has a
README entry.
- `InterpolateTest`: runs a `bosh interpolate` against `cf-deployment.yml` as a
validation.

Of these three tests, `InterpolateTest` is the only one that is not
automatically determined based on the subdirectory configuration.

Additionally, the `semantic_test` suite runs several tests that are not
specific to any subdirectory and put an emphasis on possible semantic errors.

## Running
To run the base tests locally run `./test`.
To focus a specific suite use the `--run Test<SuiteName>/<TestName>`.
- `SuiteName` is the title cased version of the suite. (e.g. Standard or IAAS)
- `TestName` is usually the name of the opsfile in kebab-cased. (e.g.
  `bosh-lite.yml`)
**Note** for both sides of the `/`, go test uses a Regex substring match.

## Contributing
### New Interpolate Tests
An `InterpolateTest` is composed of `helpers.OpsFileTestParams` shapes in yaml.

The minimal test is specified by the yaml file:

```
---
opsfile.yml: {}
```

In this case `opsfile.yml` is the name of the operations file being tested.

The optional `bosh interpolate` configurations are:
- `ops` `[]string`: an ordered list of operations files to be added via the
  `-o` flag. These must be relative to the subdirectory being tested.
- `vars` `[]string`: a list of `-vars` arguments to be added.
- `varsfiles` `[]string`: a list of `-vars-file` arguments to be added.

For Example - A test that uses all 3 flags for Interpolation:
```
use-gcs-blobstore-access-key.yml:
  ops:
  - use-external-blobstore.yml
  - use-gcs-blobstore-access-key.yml
  vars:
  - blobstore_access_key_id=TEST_ACCESS_KEY
  - blobstore_secret_access_key=TEST_SECRET_ACCESS_KEY
  varsfiles:
  - example-vars-files/vars-use-gcs-blobstore-access-key.yml
```

### Validating Ops-File Actions
An `InterpolateTest` can optionally include a `PathValidator` configuration
that will interpolate the given path and compare the resulting output with
the given expected value.

For example, given the following manifest snippet:
```
stemcells:
- alias: default
  os: ubuntu-xenial
  version: "456.16"
```

and the following ops-file:
```
- path: /stemcells/alias=default/version
  type: replace
  value: latest
```

you could write your `InterpolateTest` to not only confirm that the ops-file
will apply cleanly, but also that it results in the desired change:
```
use-latest-stemcell.yml:
  pathvalidator:
    path: /stemcells/alias=default/version
    expectedvalue: latest
```

#### Current Limitations
- only one path can be validated per test
- the validation is performed using a string matcher, as opposed to a yaml
  matcher, which means that the output will be formatted exactly as `bosh
  interpolate --path` returns, including newlines and `-` markers for arrays.
