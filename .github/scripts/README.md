# Local GitHub Actions Testing Guide (`run-act.sh`)

Run your GitHub Actions workflows locally inside Docker containers using `.github/scripts/run-act.sh` before pushing changes to GitHub.

## Prerequisites

1. **Docker Engine** running locally (Docker Desktop, OrbStack, or Colima).
2. **GitHub CLI (`gh`)** authenticated (`gh auth login`).
3. **`gh-act` extension** installed:
   ```bash
   gh extension install nektos/gh-act
   ```

---

## How `run-act.sh` Works

1. Copies `.github/workflows/` into an isolated `/tmp` directory (keeping your working tree and `git status` clean).
2. Translates `uses: $/` (required by `gh-actions-lock`) into `uses: ./` (required by `nektos/act`).
3. Automatically generates a realistic webhook `event.json` payload tailored to the event you invoke (`push` or `workflow_run`).
4. Cleans up all temporary files automatically on exit.

---

## Common Test Combinations

### 1. Simulate a `push` Event (Default CI Pipeline)
Runs all workflows triggered by `on: push` using your latest local `HEAD` commit message:
```bash
./.github/scripts/run-act.sh
# Equivalent to:
./.github/scripts/run-act.sh push
```

### 2. Simulate a `pull_request` Event
Runs all workflows triggered by `on: pull_request`:
```bash
./.github/scripts/run-act.sh pull_request
```

### 3. Simulate a Chained `workflow_run` (CD / Release Pipeline)
Automatically generates a completed `CI` success payload for your current repository and branch so `release.yml` passes its origin and status guardrails:

* **Dry Run (Recommended first — validates `if:` conditions without calling GitHub APIs):**
  ```bash
  ./.github/scripts/run-act.sh workflow_run \
    -s RELEASE_PLEASE_TOKEN="\$(gh auth token)" \
    -n
  ```

* **Live Run (Executes Release Please against GitHub):**
  > **Warning:** Without `-n`, `release-please-action` communicates with the real GitHub API and will create/update release PRs or cut live tags if pending commits exist.
  ```bash
  ./.github/scripts/run-act.sh workflow_run \
    -s RELEASE_PLEASE_TOKEN="\$(gh auth token)"
  ```

---

## Targeted Debugging & Filtering

### List All Available Workflows and Jobs
Inspect which jobs `act` detects without running anything:
```bash
./.github/scripts/run-act.sh -l
./.github/scripts/run-act.sh workflow_run -l
```

### Run a Single Specific Job (`-j`)
Skip unrelated jobs and run only one job ID:
```bash
./.github/scripts/run-act.sh -j <job_id>
```

### Run Only One Workflow File
Because `run-act.sh` uses `-W "$TMP_DIR"` internally, filter by **event** (`push`, `pull_request`, `workflow_run`) or **job ID** (`-j`) rather than passing a second `-W` flag.

---

## Advanced Edge-Case & Guardrail Testing

Pass your own custom event file via `-e` to override the script's built-in payload generator and test failure modes or security gates.

### Test That Fork PRs Are Blocked (`workflow_run`)
Verify that your `if:` origin guardrail skips the release job when a CI run originates from a fork:
```bash
cat << 'EOF' > /tmp/fork-event.json
{
  "action": "completed",
  "workflow_run": {
    "name": "CI",
    "conclusion": "success",
    "event": "pull_request",
    "head_branch": "main",
    "head_repository": {
      "full_name": "external-contributor/devsecops-actions"
    }
  },
  "repository": {
    "full_name": "karthikeyan-karuppiah/devsecops-actions"
  }
}
EOF

./.github/scripts/run-act.sh workflow_run -e /tmp/fork-event.json -n
```

### Test That Failed CI Runs Are Blocked (`workflow_run`)
Verify that `release.yml` does not run if `CI` concluded with `failure`:
```bash
cat << 'EOF' > /tmp/failed-ci-event.json
{
  "action": "completed",
  "workflow_run": {
    "name": "CI",
    "conclusion": "failure",
    "event": "push",
    "head_branch": "main",
    "head_repository": {
      "full_name": "karthikeyan-karuppiah/devsecops-actions"
    }
  },
  "repository": {
    "full_name": "karthikeyan-karuppiah/devsecops-actions"
  }
}
EOF

./.github/scripts/run-act.sh workflow_run -e /tmp/failed-ci-event.json -n
```

### Test an Invalid Commit Message (`push`)
Verify that your Conventional Commit validation gate catches non-compliant commit messages:
```bash
cat << 'EOF' > /tmp/bad-commit-event.json
{
  "head_commit": { "message": "wip: broken commit header" },
  "commits": [{ "message": "wip: broken commit header" }]
}
EOF

./.github/scripts/run-act.sh push -e /tmp/bad-commit-event.json
```

---

## Troubleshooting

| Symptom | Cause | Fix |
| :--- | :--- | :--- |
| `Cannot connect to the Docker daemon` | Docker Desktop/Engine is stopped | Start Docker before running `run-act.sh` |
| `Job 'Release Please' skipped` | `event.json` did not match `if:` conditions | Pass `workflow_run` as the first argument (`./.github/scripts/run-act.sh workflow_run`) |
| `Expected format {org}/{repo}[/path]@ref` | `act` was invoked directly instead of via `run-act.sh` | Always run via `./.github/scripts/run-act.sh` so `$/` is rewritten to `./` |
| `Authentication failed` / `403` in Release step | Missing or expired token | Pass `-s RELEASE_PLEASE_TOKEN="$(gh auth token)"` |
