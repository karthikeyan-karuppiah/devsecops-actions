# Validate Push Commit Message

Enforces the [Conventional Commits](https://conventionalcommits.org) specification on direct branch `push` events to maintain a clean Git history and guarantee compatibility with automated release tools such as [Release Please](https://github.com).

## Features

* **Push-Only Execution:** Automatically skips `pull_request` events so PR title validation can be handled independently without triggering full CI runs on title edits.
* **Header-Only Inspection:** Validates only the first line of `head_commit.message`, allowing multi-line commit bodies and footers.
* **Smart Bypasses:** Ignores standard Git merge commits (`Merge ...`) and automated Release Please commits (`chore(release): ...`).
* **Injection Safe:** Reads commit metadata via environment variables (`env:`) rather than direct shell interpolation.

---

## Usage

```yaml
- name: Validate Push Commit Message
  if: github.event_name == 'push'
  uses: karthikeyan-karuppiah/devsecops-actions/validate-push-commit@v1
  with:
    allowed-types: 'feat|fix|perf|revert|docs|style|chore|refactor|test|build|ci'
    enforce-lowercase-subject: 'true'
```

---

## Inputs

| Input | Description | Required | Default |
| :--- | :--- | :---: | :--- |
| `allowed-types` | Pipe-separated list of permitted Conventional Commit prefixes. | No | `feat\|fix\|perf\|revert\|docs\|style\|chore\|refactor\|test\|build\|ci` |
| `enforce-lowercase-subject` | Require the description after `: ` to start with a lowercase letter (`"true"` or `"false"`). | No | `'true'` |

---

## Examples

### Valid Commit Headers
* `feat: add automated backup script`
* `fix(nginx): resolve reverse proxy timeout`
* `feat(api)!: drop legacy v1 endpoint`

### Invalid Commit Headers (When `enforce-lowercase-subject: 'true'`)
* `Updated docker compose` *(missing `<type>:` prefix)*
* `feat: Add automated backup script` *(subject starts with an uppercase letter)*
