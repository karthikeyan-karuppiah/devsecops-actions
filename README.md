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

      - name: Validate Push Commit Message
        if: github.event_name == 'push'
        uses: karthikeyan-karuppiah/github-actions/validate-push-commit@v1

      - name: Lint YAML, Compose & Dockerfiles
        uses: karthikeyan-karuppiah/github-actions/lint-containers@v1
        with:
          enforce-compose-lint: 'false'

      - name: Run Trivy Secret & Container Scans
        uses: karthikeyan-karuppiah/github-actions/trivy-security@v1
        with:
          enforce-image-cves: 'false'
```

---

## Versioning & Supply-Chain Security

* **Semantic Versioning:** Releases follow [SemVer](https://semver.org) (`v1.0.0`, `v1.1.0`) alongside a floating major tag (`@v1`).
* **SHA Pinning:** For production environments or repositories enforcing [`gh-actions-lock`](https://github.com), pin actions to an immutable commit SHA:
  ```yaml
  uses: karthikeyan-karuppiah/github-actions/trivy-security@<full-commit-sha> # v1.0.0
  ```
