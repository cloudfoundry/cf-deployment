# kind-neville

Validate cf-deployment on Kubernetes using [kind-deployment](https://github.com/cloudfoundry/kind-deployment).

## Goal

Validate that release versions on cf-deployment `develop` also work when
deployed on Kubernetes, in parallel with the existing BOSH-based validation.

cf-deployment **orchestrates** — it triggers kind-deployment's existing
GitHub Actions workflows and consumes the result. All Kubernetes logic
(Helm charts, image builds, `make up`, test suites) stays in kind-deployment.

---

## How it works

The implementation uses
[kind-deployment PR #424](https://github.com/cloudfoundry/kind-deployment/pull/424)
(already merged), which adds a `fresh-validation` boolean input to
`kind-smoke.yaml` and `kind-cats.yaml`. When `fresh-validation: true` is
passed via `workflow_dispatch`, the workflow runs
`sync-cf-deployment-versions.py --ref develop` inline before `make up`,
syncing Helm chart versions to cf-deployment's `develop` branch within
the workflow's ephemeral checkout.

```
develop (trigger)
         │
         ▼
  unit-test-ops-files
  lint-cf-deployment-manifest
  unit-test-golang-tests
  unit-test-update-releases-coverage
         │
         ├─── BOSH environments (fresh, upgrade, experimental, …) ────┐
         │                                                            │
         ├─── kind-smoke-tests ─► kind-smoke.yaml (fresh-validation) ─┤
         └─── kind-cats ────────► kind-cats.yaml  (fresh-validation) ─┤
                                                                      │
                                                           bless-manifest
                                               (waits for BOSH only)
```

Inside each kind workflow:

1. Checkout kind-deployment @ `main`
2. `sync-cf-deployment-versions.py --ref develop` (updates chart versions)
3. `make up` (deploy CF on kind)
4. Run smoke tests / CATS

Nothing is committed; synced versions are discarded when the run finishes.

---

## Pipeline details

### Group: `kind-neville`

```yaml
- name: kind-neville
  jobs:
  - kind-smoke-tests
  - kind-cats
```

### Jobs

| Job | Dispatches | Inputs |
|-----|-----------|--------|
| `kind-smoke-tests` | `kind-smoke.yaml` on `main` | `{"minimal": "true", "fresh-validation": "true"}` |
| `kind-cats` | `kind-cats.yaml` on `main` | `{"fresh-validation": "true"}` |

Both trigger after the same four unit/lint jobs that gate all BOSH
environments and share `serial_groups: [kind-workflows]`.

### Non-blocking

`bless-manifest` does **not** depend on kind jobs. Failures are
informational and do not gate releases.

---

## Reusable task: trigger-github-workflow

Lives in [runtime-ci](https://github.com/cloudfoundry/runtime-ci) at
`tasks/trigger-github-workflow/`. Uses `cloudfoundry/cf-deployment-concourse-tasks`
image (provides `gh` + `jq`).

The dispatch API returns no run ID, so the script locates the run by
matching: `id > BEFORE_ID`, `created_at >= DISPATCH_TS`, and
`actor.login == ACTOR_LOGIN`. The serial group ensures only one dispatch
is in flight at a time.

---

## Risks

### 1. Missing artifacts

When cf-deployment bumps a version on `develop`, the corresponding container
image or Helm chart may not yet exist. The artifact creation pipeline in
kind-deployment works as follows:

- A new GitHub release is created for a BOSH release repo (e.g. capi-release)
- Renovate bumps the version in `cf-k8s-releases` (runs once a day)
- The Renovate PR is verified and auto-merged
- On merge to `main`, Helm charts and Docker images are built and published

Two cases can cause a missing artifact:
- **cf-deployment is faster than Renovate** — Renovate runs daily, so there
  can be up to ~24h + verification time before the artifact exists.
- **Verification failed** — the artifact could not be built automatically.

**Mitigation:** Kind is non-blocking, so missing artifacts won't hold up
releases.

### 2. GitHub API availability

The task depends on the GitHub API for dispatch and polling.

**Mitigation:** Uses an authenticated token (rate-limit is not a concern).
Polling retries for up to 10 minutes.

### 3. Serial group throughput

Smoke and CATS run sequentially. If the pipeline triggers frequently, kind
validation may fall behind.

**Mitigation:** Can split into separate serial groups, or drop smoke tests
entirely (CATS is a superset — it cannot miss errors that smoke tests would
catch, though smoke tests provide a faster signal).

### 4. Develop ref drift

The workflow syncs from `develop` at execution time, which may have advanced
since the Concourse trigger.

**Mitigation:** Acceptable for an informational check. A future enhancement
could pass an exact commit SHA as a workflow input parameter.

---

## Credentials

The pipeline uses a dedicated token from the WG secret manager (stored as a
Concourse secret) with `actions: write` on `cloudfoundry/kind-deployment`.

---

## Related PRs

| Repository | PR |
|---|---|
| cf-deployment | [#1359](https://github.com/cloudfoundry/cf-deployment/pull/1359) — pipeline jobs |
| runtime-ci | [#687](https://github.com/cloudfoundry/runtime-ci/pull/687) — reusable trigger task |
| cf-deployment-concourse-tasks | [#249](https://github.com/cloudfoundry/cf-deployment-concourse-tasks/pull/249) — add `gh` CLI to image |
| kind-deployment | [#424](https://github.com/cloudfoundry/kind-deployment/pull/424) — `fresh-validation` input (merged) |
