#!/usr/bin/env bash
# ==============================================================================
# Wrapper to run `gh act` locally on workflows using GitHub's `$/` action syntax.
#
# WHY THIS SCRIPT EXISTS:
#   1. `gh-actions-lock` requires same-repo actions to use `$/` (e.g., `$/my-action`)
#      instead of `./` so it can deterministically lock nested dependencies at the
#      workflow's commit rather than trusting mutable workspace paths.
#   2. `nektos/act` (via `gh act`) does not yet support the `$/` syntax and fails
#      with: "Expected format {org}/{repo}[/path]@ref". It only accepts `./` for
#      local actions.
#   3. `nektos/act` sends an empty `push` webhook payload by default, leaving
#      `github.event.head_commit.message` blank unless supplied via `-e`, which
#      causes Conventional Commit gate actions (`validate-push-commit`) to fail.
#   4. Editing `.github/workflows/` directly in the repo risks accidentally
#      committing `./` changes or dirtying `git status`.
#
# HOW IT WORKS:
#   Moves to the repository root, copies `.github/workflows/` into an isolated
#   temp directory, translates `$/` to `./` in the copies, generates a simulated
#   `push` event JSON payload from your real `HEAD` commit message, runs
#   `gh act -W` against that temp folder, and deletes all temp files on exit.
# ==============================================================================

# Exit immediately if any command fails (-e), treat unset variables as errors (-u),
# and fail a pipeline if any command inside it fails (-o pipefail).
# Why: Prevents `gh act` from running against partially copied or broken workflow files.
set -euo pipefail

# Always execute from the Git repository root.
# Why: Ensures `.github/workflows/` is found reliably even if you invoke this
# script from inside a subdirectory.
cd "$(git rev-parse --show-toplevel)"

# Create a secure, isolated temporary directory (e.g., /tmp/tmp.XXXXXXXXXX).
# Why: Keeps your actual `.github/workflows/` directory untouched so `git status`
# stays clean and you never accidentally commit local workarounds.
TMP_DIR=$(mktemp -d)

# Register a cleanup trap that deletes the temporary directory when the script exits.
# How: The EXIT signal fires regardless of whether `gh act` succeeds, fails, or is
# interrupted with Ctrl+C, ensuring no temporary files are left behind.
trap 'rm -rf "$TMP_DIR"' EXIT

# Copy all workflow files into the temporary directory.
# Why: `gh act` allows overriding the workflow location via `-W`, while still
# mounting your real repository root as the workspace inside the Docker container.
cp -r .github/workflows/* "$TMP_DIR/"

# Find all YAML workflow files in the temp folder and rewrite `uses: $/` to `uses: ./`.
# Why: Bridges the syntax gap between `gh-actions-lock` (`$/`) and `act` (`./`)
# without modifying your tracked source files.
# How: `find` locates `.yml`/`.yaml` files and passes them in batches (`+`) to `sed -i`,
# which performs an in-place regex substitution on the copied files.
find "$TMP_DIR" -type f \( -name '*.yml' -o -name '*.yaml' \) \
  -exec sed -i 's|uses: \$/|uses: ./|g' {} +

# Build a simulated GitHub `push` event payload using your real `HEAD` commit message.
# Why: `act` does not populate `github.event.head_commit.message` from local Git
# history automatically, so `validate-push-commit` would fail with an empty header.
# How: Python reads `git log -1 --pretty=%B` and safely serializes it into valid
# JSON inside `$TMP_DIR/event.json` (handling quotes and multi-line commit bodies).
python3 -c '
import json, subprocess, sys
msg = subprocess.check_output(["git", "log", "-1", "--pretty=%B"], text=True).strip()
payload = {
    "head_commit": {"message": msg},
    "commits": [{"message": msg}]
}
with open(sys.argv[1], "w") as f:
    json.dump(payload, f)
' "$TMP_DIR/event.json"

# Attach the generated event payload unless the caller explicitly passed `-e` or `--eventpath`.
# Why: Allows you to override the event file for custom test cases while making
# default `.github/scripts/run-act.sh` runs validate your actual commit message.
EVENT_ARGS=()
if [[ ! " $* " =~ " -e " && ! " $* " =~ " --eventpath " ]]; then
  EVENT_ARGS=(-e "$TMP_DIR/event.json")
fi

# Execute `gh act` pointing at the rewritten workflows in the temp directory.
# How: `-W "$TMP_DIR"` tells `act` to load workflows from our temp copy,
# `"${EVENT_ARGS[@]}"` passes the simulated `push` payload if needed, and `"$@"`
# forwards every argument you passed to this script (such as `pull_request` or `-j`).
gh act -W "$TMP_DIR" "${EVENT_ARGS[@]}" "$@"
