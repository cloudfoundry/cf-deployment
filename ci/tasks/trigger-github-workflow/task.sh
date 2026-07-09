#!/usr/bin/env sh
set -eu

##
# Triggers a GitHub Actions workflow via workflow_dispatch, locates the
# resulting run, and streams its output until completion.
#
# Requires these environment variables:
#   GITHUB_TOKEN      – PAT or GitHub App token with Actions scope
#   GITHUB_REPO       – owner/repo  (e.g. cloudfoundry/kind-deployment)
#   WORKFLOW_FILE     – workflow filename  (e.g. kind-smoke.yaml)
#   WORKFLOW_REF      – git ref to run against  (default: main)
#   WORKFLOW_INPUTS   – JSON object of workflow inputs  (default: {})
##

# ── install gh CLI and jq ───────────────────────────────────────────
apk add --no-cache --quiet \
  --repository=https://dl-cdn.alpinelinux.org/alpine/edge/community \
  github-cli jq

export GH_TOKEN="${GITHUB_TOKEN}"

TEAM_NAME="${BUILD_TEAM_NAME:-unknown-team}"
PIPELINE_NAME="${BUILD_PIPELINE_NAME:-unknown-pipeline}"
JOB_NAME="${BUILD_JOB_NAME:-unknown-job}"
BUILD_NAME="${BUILD_NAME:-unknown-build}"
TRIGGER_SOURCE="${TEAM_NAME}/${PIPELINE_NAME}/${JOB_NAME}/${BUILD_NAME}"
TRIGGER_ID=$(printf 'cfd-%s-%s-%s-%s-%s' \
  "${TEAM_NAME}" "${PIPELINE_NAME}" "${JOB_NAME}" "${BUILD_NAME}" "$(date -u +%s)" \
  | tr '/:@ ' '-' \
  | tr -cd '[:alnum:]._-')

if [ -z "${TRIGGER_ID}" ]; then
  TRIGGER_ID="cfd-$(date -u +%s)"
fi

DISPATCH_TS=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
ACTOR_LOGIN=$(gh api user --jq '.login')

INPUTS_JSON=$(printf '%s' "${WORKFLOW_INPUTS}" \
  | jq -ce 'if type == "object" then . else error("WORKFLOW_INPUTS must be a JSON object") end')

# ── snapshot the latest existing run ID so we can find our new one ──
BEFORE_ID=$(gh run list \
  --repo "${GITHUB_REPO}" \
  --workflow "${WORKFLOW_FILE}" \
  --event workflow_dispatch \
  --limit 1 \
  --json databaseId \
  --jq '.[0].databaseId // 0' 2>/dev/null || echo "0")

# ── dispatch the workflow ───────────────────────────────────────────
echo "Dispatching ${WORKFLOW_FILE} on ${GITHUB_REPO}@${WORKFLOW_REF}..."
echo "Trigger ID: ${TRIGGER_ID}"
echo "Trigger source: ${TRIGGER_SOURCE}"
echo "Workflow actor: ${ACTOR_LOGIN}"
echo "${INPUTS_JSON}" \
  | jq --arg ref "${WORKFLOW_REF}" '{ref: $ref, inputs: .}' \
  | gh api --method POST \
      "/repos/${GITHUB_REPO}/actions/workflows/${WORKFLOW_FILE}/dispatches" \
      --input -

# ── locate the newly created run ────────────────────────────────────
echo "Locating workflow run (previous latest ID: ${BEFORE_ID})..."
RUN_ID=""
attempt=0
while [ "${attempt}" -lt 60 ]; do
  RUN_ID=$(gh api \
    "/repos/${GITHUB_REPO}/actions/workflows/${WORKFLOW_FILE}/runs?event=workflow_dispatch&branch=${WORKFLOW_REF}&per_page=20" \
    2>/dev/null \
    | jq -r \
        --argjson before_id "${BEFORE_ID}" \
        --arg dispatch_ts "${DISPATCH_TS}" \
        --arg actor_login "${ACTOR_LOGIN}" \
        '.workflow_runs
         | map(
             select(
               (.id > $before_id)
               and (.created_at >= $dispatch_ts)
               and (.actor.login == $actor_login)
             )
           )
         | .[0].id // empty' || true)

  if [ -n "${RUN_ID}" ]; then
    break
  fi
  attempt=$((attempt + 1))
  sleep 10
done

if [ -z "${RUN_ID}" ]; then
  echo "ERROR: Dispatched run not found after 10 minutes."
  echo "Expected trigger_id=${TRIGGER_ID}"
  echo "Expected actor=${ACTOR_LOGIN}"
  echo "Workflow=${WORKFLOW_FILE} ref=${WORKFLOW_REF}"
  exit 1
fi

# ── watch the run until completion ──────────────────────────────────
echo "Watching: https://github.com/${GITHUB_REPO}/actions/runs/${RUN_ID}"
gh run watch "${RUN_ID}" --repo "${GITHUB_REPO}" --exit-status
