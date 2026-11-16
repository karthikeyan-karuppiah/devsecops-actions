# Validate Push Commit Message

Enforces the [Conventional Commits v1.0.0](https://conventionalcommits.org) specification on direct branch `push` events to maintain a clean Git history and guarantee compatibility with automated semantic release engines (such as Release Please).

## Features

* **Zero Git History Required:** Evaluates commit headers directly from the GitHub webhook event payload (`github.event.commits` / `head_commit`), working seamlessly with shallow clones (`fetch-depth: 1`).
* **Full Push Coverage:** Validates every commit in a multi-commit push by default (`check-all-commits: 'true'`).
* **Smart Bypass Rules:** Automatically skips Git merge commits (`Merge ...`), Git revert headers (`Revert "..."`), and Release Please release commits (`chore(<branch>): release ...`).
* **Script-Injection Hardened:** Passes untrusted commit messages strictly via environment variables (`env:`).

## Usage

```yaml
- name: Validate Push Commit Message
  if: github.event_name == 'push'
  uses: karthikeyan-karuppiah/devsecops-actions/validate-push-commit@v1
  with:
    allowed-types: 'feat|fix|perf|revert|docs|style|chore|refactor|test|build|ci'
    enforce-lowercase-subject: 'true'
    check-all-commits: 'true'
```

## Inputs

| Input | Description | Required | Default |
| :--- | :--- | :---: | :--- |
| `allowed-types` | Pipe-separated list of permitted Conventional Commit prefixes. | No | `'feat\|fix\|perf\|revert\|docs\|style\|chore\|refactor\|test\|build\|ci'` |
| `enforce-lowercase-subject` | Require the subject description after `": "` to begin with a lowercase character (`'true'` or `'false'`). | No | `'true'` |
| `check-all-commits` | Validate every commit in the push payload instead of only `head_commit` (`'true'` or `'false'`). | No | `'true'` |

## Outputs

| Output | Description |
| :--- | :--- |
| `commit-type` | Parsed Conventional Commit type of the head commit (e.g., `feat`, `fix`, `ci`). |
| `skipped` | Whether validation was bypassed due to a merge or automated release commit (`'true'` or `'false'`). |
