# kind-neville

Validate cf-deployment on Cloud Foundry on Kubernetes (CF-on-kind) using the
[kind-deployment](https://github.com/cloudfoundry/kind-deployment) project.

## Goal

Validate that Cloud Foundry release versions promoted through cf-deployment's
BOSH-based pipeline also work when deployed on Kubernetes.

The design principle is that cf-deployment **orchestrates**, but does not
re-implement, the kind deployment logic. All Kubernetes-specific knowledge
(Helm charts, container image builds, `make up`, test suites) stays in the
kind-deployment repository. cf-deployment triggers workflows there and
consumes the result.

---

## Background

### How cf-deployment validates releases today (BOSH)

The `update-releases` pipeline watches for new BOSH release versions. When a
new version appears:

1. A lock is acquired from the pre-dev pool.
2. The release is updated in `cf-deployment.yml` (release-candidate branch).
3. A BOSH environment is stood up, CF is deployed, smoke tests run, compiled
   releases are exported.
4. On success, the version is pushed to the `develop` branch.
5. The main `cf-deployment` pipeline picks up the change on `develop` and runs
   full validation: fresh deploy, upgrade, CATS, smoke tests, BBR, Windows,
   lite, experimental, and FIPS environments.
6. `bless-manifest` promotes `develop` to `release-candidate` once all
   environments pass.

### How kind-deployment manages versions today

[kind-deployment](https://github.com/cloudfoundry/kind-deployment) deploys CF
on a local Kubernetes cluster (via [kind](https://kind.sigs.k8s.io/)) using
Helm charts. Key components:

- **`docker-bake.hcl`** – defines component version variables
  (`CAPI_RELEASE_VERSION`, `DIEGO_RELEASE_VERSION`, etc.). Each points to a
  GitHub release tag of the corresponding BOSH release. Container images are
  built from the Go source code in those release repos.
- **`helmfile.yaml.gotmpl`** + **`values.yaml.gotmpl`** – reference local
  Helm charts (under `releases/`) and external OCI charts. Image tags in
  `values.yaml` files within each chart carry `# sync: release=<name>`
  annotations.
- **`scripts/sync-cf-deployment-versions.py`** – a Python script that reads
  `cf-deployment.yml`, extracts release versions, and updates `Chart.yaml`
  (`appVersion`) and `values.yaml` (image tags) for each chart.
- **`.github/workflows/sync-cf-deployment-versions.yaml`** – runs the Python
  script on a daily cron (`0 6 * * *`) or manual dispatch. It always fetches
  the **latest tagged release** of cf-deployment, not `develop`.
- **Renovate** – independently watches upstream GitHub releases for each
  component and creates per-component PRs.

### The gap

The existing daily sync in kind-deployment is **batch and delayed**: it only
picks up versions after they appear in a cf-deployment *release* (tagged),
which can be days or weeks after they land on `develop`. There is no
automated path that validates whether the versions currently being tested in
BOSH environments also work on Kubernetes.

---

## Approach Considered and Rejected

### Local kind cluster in Concourse ("dobby")

The initial idea was to create a kind cluster directly inside a Concourse
worker, deploy CF with `make up`, and run tests — similar to how BOSH
environments work with dedicated pools and infrastructure.

This was rejected because:

- kind-deployment already has self-contained GitHub Actions workflows that
  handle the full lifecycle (cluster creation, deployment, testing, cleanup).
- Duplicating that logic in Concourse would create a second source of truth
  for the Kubernetes deployment process.
- Concourse workers are not well-suited for running Docker-in-Docker with
  kind clusters.
- Maintenance burden doubles: any change in kind-deployment's setup would
  need to be mirrored in cf-deployment's Concourse tasks.

---

## Approach Implemented

### Architecture

The implementation relies on
[kind-deployment PR #424](https://github.com/cloudfoundry/kind-deployment/pull/424),
which adds a `fresh-validation` boolean input to both the `kind-smoke.yaml`
and `kind-cats.yaml` workflows. When `fresh-validation: true`, the workflow
runs `sync-cf-deployment-versions.py --ref develop` **inline**, right before
`make up` — syncing the Helm chart versions to match cf-deployment's
`develop` branch inside the workflow's own ephemeral checkout.

This means cf-deployment does **not** need a separate sync job, a sync PR
branch, or any modification to the sync workflow. It simply dispatches the
two test workflows with `fresh-validation: true`.

Kind validation is triggered at the **same point** as every BOSH environment
— immediately after the four unit/lint jobs pass on `develop`. This makes
kind-neville a true parallel environment, running concurrently with fresh-luna,
upgrade, experimental, windows, lite, and FIPS.

```
develop (trigger)
         │
         ▼
  unit-test-ops-files
  lint-cf-deployment-manifest        (4 jobs, same gate as all BOSH environments)
  unit-test-golang-tests
  unit-test-update-releases-coverage
         │
         ├─── fresh-acquire-pool ──► fresh-deploy ──► fresh-smoke+cats ──┐
         ├─── upgrade-acquire-pool ► upgrade-deploy ► upgrade-smoke+cats ┤
         ├─── experimental ──────────────────────────────────────────────┤
         ├─── lite ──────────────────────────────────────────────────────┤
         ├─── windows ───────────────────────────────────────────────────┤
         ├─── fips ──────────────────────────────────────────────────────┤
         │                                                                │
         ├─── kind-smoke-tests ──► kind-smoke.yaml (fresh-validation) ───┤
         └─── kind-cats ─────────► kind-cats.yaml  (fresh-validation) ───┤
                                                                          │
                                                              bless-manifest
                                                       (waits for all above)
```

Inside each kind workflow, the sync happens as a self-contained step:

```
kind-smoke.yaml / kind-cats.yaml  (dispatched with fresh-validation=true)
  1. checkout kind-deployment @ main
  2. [fresh-validation] sync-cf-deployment-versions.py --ref develop
       → updates Helm chart versions from cf-deployment develop
  3. make up            (deploy CF on kind with the synced versions)
  4. run smoke / CATS
```

The sync + deploy + test all happen within one GitHub Actions run. Nothing
is committed; the synced versions live only in the workflow's checkout for
the duration of the run.

### Pipeline group: kind-neville

All kind jobs are grouped under `kind-neville` in the Concourse pipeline,
following the naming convention of other environments (luna, trelawney,
hermione, etc.):

```yaml
- name: kind-neville
  jobs:
  - kind-smoke-tests
  - kind-cats
```

### Job 1: kind-smoke-tests

**Trigger:** `cf-deployment-develop` with `passed: [unit-test-ops-files, lint-cf-deployment-manifest, unit-test-golang-tests, unit-test-update-releases-coverage]`

Same trigger gate as every BOSH environment. Dispatches `kind-smoke.yaml`
on `main` with `{"minimal": "true", "fresh-validation": "true"}`. The
`fresh-validation` flag makes the workflow sync chart versions from
cf-deployment `develop` before deploying and running smoke tests.

### Job 2: kind-cats

**Trigger:** same four unit/lint jobs as above.

Dispatches `kind-cats.yaml` on `main` with `{"fresh-validation": "true"}`.
Same self-syncing behavior, but runs the full Cloud Foundry Acceptance Tests.

### Serial group

Both jobs share `serial_groups: [kind-workflows]`. This serializes the
GitHub workflow dispatches so we don't run two heavy kind clusters at the
same time on shared GitHub runners.

### Non-blocking for releases

The `bless-manifest` job does **not** list any kind jobs in its `passed`
constraints. Kind validation is informational — a failure will not block
release promotion. This is intentional: the Kubernetes deployment path is
newer and less mature than the BOSH path, so it should not gate releases
until confidence is established.

---

## Reusable Concourse Task: trigger-github-workflow

All kind jobs use a single reusable task that lives in the
[runtime-ci](https://github.com/cloudfoundry/runtime-ci) repository at
`tasks/trigger-github-workflow/`:

- **`task.yml`** – Concourse task definition using the
  `cloudfoundry/cf-deployment-concourse-tasks` image (which provides `gh`
  and `jq`), with params for `GITHUB_TOKEN`, `GITHUB_REPO`, `WORKFLOW_FILE`,
  `WORKFLOW_REF`, and `WORKFLOW_INPUTS`.
- **`task`** – shell script that handles the full dispatch-and-watch
  lifecycle.

The pipeline references it via the `runtime-ci` resource
(`runtime-ci/tasks/trigger-github-workflow/task.yml`).

### Run identification mechanism

GitHub's workflow dispatch API returns `204 No Content` with no run ID.
The script must locate the run it just created. Before dispatching, it
snapshots the highest existing run ID (`BEFORE_ID`). It also records the
dispatch timestamp and authenticated user. After dispatching, it polls the
runs API (up to 60 × 10s = 10 minutes) looking for a run matching all three
signals:

- `id > BEFORE_ID` (new run, not pre-existing)
- `created_at >= DISPATCH_TS` (created after dispatch)
- `actor.login == ACTOR_LOGIN` (created by the expected service account)

A `TRIGGER_ID` is still generated from Concourse build metadata
(`BUILD_TEAM_NAME`, `BUILD_PIPELINE_NAME`, `BUILD_JOB_NAME`, `BUILD_NAME`)
and logged for debugging, but it is **not** injected into the workflow inputs
(the target workflows don't declare it, and GitHub rejects unknown inputs
with a 422). The three-signal match is sufficient because
`serial_groups: [kind-workflows]` ensures only one dispatch is in flight
at a time.

---

## Changes in kind-deployment (already merged)

The kind-deployment side is provided by
[PR #424](https://github.com/cloudfoundry/kind-deployment/pull/424)
(**already merged**), which adds a `fresh-validation` boolean input to both
test workflows.

### `.github/workflows/kind-smoke.yaml` and `kind-cats.yaml`

| Change | Purpose |
|--------|---------|
| Add `fresh-validation` boolean input (default `false`) | Opt in to validating cf-deployment's `develop` versions |
| Add step "Use develop versions of cf-deployment" | On `workflow_dispatch` with `fresh-validation == 'true'`, run `pip3 install -r scripts/requirements.txt` then `python3 scripts/sync-cf-deployment-versions.py --ref develop` before `make up` |

The step is gated so it only runs on manual dispatch with the flag set. The
scheduled cron runs are unaffected and keep their default behavior.

### `scripts/sync-cf-deployment-versions.py`

The script accepts a `--ref` argument (via argparse). When cf-deployment
dispatches with `fresh-validation: true`, the workflow calls it with
`--ref develop`, so the sync reads component versions from the tip of
`develop` instead of the latest tagged release.

Because the sync now runs **inside** the smoke/CATS workflows, there is no
separate `sync-cf-deployment-versions.yaml` dispatch, no `auto/…` PR branch,
and no branch-push coordination. Everything happens in the workflow's own
ephemeral checkout and is discarded when the run finishes.

---

## Risks and Potential Problems

### 1. Missing container images

When cf-deployment `develop` has a new release version, the corresponding
container image may not yet be built and pushed to `ghcr.io`. The sync
script checks for image availability and exits with an error if images are
missing. This would cause the `fresh-validation` step to fail, failing the
smoke/CATS workflow (and therefore the Concourse job).

**Mitigation:** The sync script reports which images are missing. Container
images are typically built by kind-deployment's Renovate-triggered image
build when version bumps are detected. There may be a gap where cf-deployment
bumps a version before kind-deployment's image build runs. This is the most
likely source of transient failures. Because kind is non-blocking for
`bless-manifest`, such a failure will not hold up releases.

### 2. Concourse-to-GitHub API reliability

The trigger-github-workflow task depends on the GitHub API being available
for dispatching workflows and polling for run status. GitHub API outages or
rate limiting could cause false failures.

**Mitigation:** The script uses the `gh` CLI which handles authentication
and retries. The polling loop has 60 attempts with 10-second intervals
(~10 minutes total) before giving up. Rate limiting can be mitigated with a
GitHub App token instead of a PAT.

### 3. Serial group throughput

Both kind jobs are in the same serial group, so smoke and CATS run
sequentially rather than concurrently. A full cycle is roughly the sum of
both durations. If the pipeline triggers frequently, kind validation may
fall behind BOSH.

**Mitigation:** Because smoke and CATS create independent kind clusters,
they can be split into separate serial groups if throughput becomes a
problem. The serial group is a conservative default to avoid running two
heavy clusters on shared GitHub runners at once.

### 4. Develop ref may advance between dispatch and sync

`fresh-validation` syncs from `develop` at the moment the workflow runs.
Additional commits may land on `develop` between the Concourse trigger and
the in-workflow sync, so the test could validate a slightly newer or older
set of versions than the exact commit that triggered the job.

**Mitigation:** Acceptable — the kind check is informational and
non-blocking. A few commits of drift do not meaningfully change what is
being validated.

### 5. Input name coupling

cf-deployment must pass exactly the input name kind-deployment defines
(`fresh-validation`). If kind-deployment renames the input, the Concourse
dispatch must be updated to match, otherwise the flag is silently ignored
and kind runs against `main` versions instead of `develop`.

**Mitigation:** The name is fixed by the merged PR #424. Any future rename
in kind-deployment should be coordinated with a matching change here.

---

## Credentials

The pipeline requires a Concourse secret `kind_deployment_github_token` with
`actions: write` scope on `cloudfoundry/kind-deployment`.

---

## Files Changed

### cf-deployment repository

| File | Change |
|------|--------|
| `ci/pipelines/cf-deployment.yml` | Added `kind-smoke-tests` and `kind-cats` jobs triggered on `develop` after the four unit/lint jobs (same gate as BOSH environments), dispatching `kind-smoke.yaml`/`kind-cats.yaml` on `main` with `fresh-validation: true`. Added `kind-neville` group. `bless-manifest` does not depend on either job (non-blocking). The jobs reference the reusable task from the `runtime-ci` resource. |

### runtime-ci repository (PR #687)

| File | Change |
|------|--------|
| `tasks/trigger-github-workflow/task.yml` | Reusable Concourse task to dispatch and watch a GitHub workflow |
| `tasks/trigger-github-workflow/task` | Dispatch-and-watch script with run identification via id/timestamp/actor matching |

### kind-deployment repository (already merged — PR #424)

| File | Change |
|------|--------|
| `.github/workflows/kind-smoke.yaml` | Added `fresh-validation` input + inline sync step (`sync-cf-deployment-versions.py --ref develop`) before `make up` |
| `.github/workflows/kind-cats.yaml` | Same `fresh-validation` input + inline sync step |

---

## Operational Shape

The intended flow on every `develop` commit that passes unit/lint:

1. `kind-smoke-tests` dispatches `kind-smoke.yaml` with `fresh-validation: true`.
2. `kind-cats` dispatches `kind-cats.yaml` with `fresh-validation: true`.
3. Inside each workflow, versions are synced from `develop`, CF is deployed on kind, and tests run.
4. Both kind jobs report pass/fail independently in Concourse.
5. `bless-manifest` proceeds based on BOSH-based validations only; kind results are informational.

---

## Pipeline Management

The kind-neville jobs live inside `ci/pipelines/cf-deployment.yml` under the
`kind-neville` group. To update the pipeline, run `ci/configure cf-deployment`.
