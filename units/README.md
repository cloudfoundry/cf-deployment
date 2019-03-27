# CF-Deployment Unit Tests

## Table of Contents
1. [Types of Tests](#types-of-tests)
1. [Running](#running)
1. [Contributing](#contributing)
    - [New Interpolate Tests](#new-interpolate-tests)

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
An `InterpolateTest` is composed of `helpers.OpsFileTestParams`.

The minimal test is:
```golang
"opsfile.yml": {}
```

In this case `opsfile.yml` is the name of the operations file being tested.

The optional `bosh interpolate` configurations are:
- `Ops` `[]string`: an ordered list of operations files to be added via the
  `-o` flag. These must be relative to the subdirectory being tested.
- `Vars` `[]string`: a list of `-vars` arguments to be added.
- `VarsFiles` `[]string`: a list of `-vars-file` arguments to be added.
