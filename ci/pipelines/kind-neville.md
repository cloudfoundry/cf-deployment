# kind-neville

Validate cf-deployment on Cloud Foundry on Kubernetes (CF-on-kind) using the
[kind-deployment](https://github.com/cloudfoundry/kind-deployment) project.

## Triggers

The `kind-smoke-tests` and `kind-cats` jobs trigger automatically when a
`develop` commit passes the four unit/lint jobs (`unit-test-ops-files`,
`lint-cf-deployment-manifest`, `unit-test-golang-tests`,
`unit-test-update-releases-coverage`) — the same gate used by all BOSH
environments. They run in parallel with fresh-luna, upgrade, experimental,
windows, lite, and FIPS.

## How it works

Each job dispatches a GitHub Actions workflow in `cloudfoundry/kind-deployment`
via `workflow_dispatch` with `fresh-validation: true`. That flag (added in
[kind-deployment#424](https://github.com/cloudfoundry/kind-deployment/pull/424))
causes the workflow to sync its Helm chart versions from cf-deployment's
`develop` branch before deploying, so the Kubernetes deployment is tested
against the same release versions being validated on BOSH.

The Concourse task that handles the dispatch lives at
`ci/tasks/trigger-github-workflow/`. It dispatches the workflow, locates the
resulting run (by run ID, timestamp, and actor), and watches it to completion
so pass/fail is reflected in Concourse.

## Credentials

The pipeline requires a Concourse secret `kind_deployment_github_token` with
`actions: write` scope on `cloudfoundry/kind-deployment`.

## Non-blocking

`bless-manifest` does not depend on the kind jobs. A kind failure does not
gate releases.

## Pipeline Management

The kind-neville jobs live inside `ci/pipelines/cf-deployment.yml` under the
`kind-neville` group. To update the pipeline, run `ci/configure cf-deployment`.
