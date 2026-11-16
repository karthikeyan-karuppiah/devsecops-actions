# Reusable GitHub Actions

A collection of modular, security-hardened composite GitHub Actions for DevSecOps, container linting, vulnerability scanning, and Conventional Commit enforcement.

## Available Actions

| Action | Description | Documentation |
| :--- | :--- | :--- |
| **`validate-push-commit`** | Enforces Conventional Commits formatting on direct branch `push` events. | [View Docs](./validate-push-commit/README.md) |
| **`lint-containers`** | Runs `yamllint`, `docker compose config`, CIS/OWASP `compose-lint`, and `hadolint`. | [View Docs](./lint-containers/README.md) |
| **`trivy-security`** | Scans source files for leaked secrets, audits Compose container images for CVEs, and generates CycloneDX SBOMs. | [View Docs](./trivy-security/README.md) |

---

## Quick Start

Add these actions to your workflow inside `.github/workflows/ci.yml`:

```yaml
name: Continuous Integration

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

permissions: {}

jobs:
  lint-and-scan:
    runs-on: ubuntu-latest
    permissions:
      contents: read

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4
        with:
          persist-credentials: false

      # 1. Exact Version Tag (`@v0.0.1` / `@v0.1.0`):
      # Recommended during initial `0.x.y` development to lock onto a specific release.
      - name: Validate Push Commit Message
        if: github.event_name == 'push'
        uses: karthikeyan-karuppiah/devsecops-actions/validate-push-commit@v0.0.1

      # 2. Floating Major Tag (`@v1`):
      # Recommended once v1.0.0 is released to automatically receive non-breaking updates.
      - name: Lint YAML, Compose & Dockerfiles
        uses: karthikeyan-karuppiah/devsecops-actions/lint-containers@v1
        with:
          enforce-compose-lint: 'false'

      # 3. Immutable Commit SHA (`@<40-char-sha>`):
      # Recommended for strict supply-chain security (or generated via `gh actions-lock`).
      - name: Run Trivy Secret & Container Scans
        uses: karthikeyan-karuppiah/devsecops-actions/trivy-security@<full-40-char-commit-sha> # v0.0.1
        with:
          enforce-image-cves: 'false'
```

---

## Versioning & Supply-Chain Security

Every `uses:` reference follows GitHub's standard `<owner>/<repo>/<path>@<ref>` structure:

```text
karthikeyan-karuppiah / devsecops-actions / trivy-security @ v0.0.1
└─────────┬─────────┘   └─────┬──────┘   └──────┬───────┘   └─┬──┘
     GitHub Owner         Repo Name        Subfolder       Git Ref (Tag/Branch/SHA)
```

* **Version Tags (`@v0.0.1`, `@v1`):** Following [GitHub's Action Release Guidelines](https://github.com), the `@<ref>` suffix specifies which release snapshot to execute (`@v0.x.y` for initial releases, or `@v1` for the latest non-breaking v1 release).
* **Commit SHA Pinning:** Following [GitHub's Security Hardening Guidelines](https://github.com), production workflows should pin actions to an immutable 40-character commit SHA (or verify them with [`gh-actions-lock`](https://github.com)):
  ```yaml
  uses: karthikeyan-karuppiah/devsecops-actions/trivy-security@<full-40-char-commit-sha> # v0.0.1
  ```
