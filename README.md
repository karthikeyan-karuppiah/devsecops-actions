# Reusable GitHub Actions

[![CI](https://github.com/karthikeyan-karuppiah/devsecops-actions/actions/workflows/ci.yml/badge.svg)](https://github.com/karthikeyan-karuppiah/devsecops-actions/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/karthikeyan-karuppiah/devsecops-actions)](https://github.com/karthikeyan-karuppiah/devsecops-actions/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

A collection of modular, security-hardened composite GitHub Actions for DevSecOps, container linting, vulnerability scanning, and Conventional Commit enforcement.

## Available Actions

| Action | Description | Documentation |
| :--- | :--- | :--- |
| **`validate-push-commit`** | Enforces Conventional Commits formatting on direct branch `push` events across single or multi-commit payloads. | [View Docs](./validate-push-commit/README.md) |
| **`lint-containers`** | Runs `yamllint`, `docker compose config --no-interpolate`, CIS/OWASP `compose-lint`, and `hadolint`. | [View Docs](./lint-containers/README.md) |
| **`trivy-security`** | Scans source files for leaked secrets, CVEs, and IaC misconfigs; audits Compose container images; exports CycloneDX SBOMs and SARIF reports. | [View Docs](./trivy-security/README.md) |

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
      security-events: write # Required only if uploading Trivy SARIF results to GitHub Code Scanning

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4
        with:
          persist-credentials: false

      # 1. Floating Major Tag (`@v1`):
      # Recommended for v1.x releases to automatically receive non-breaking security updates.
      - name: Validate Push Commit Message
        if: github.event_name == 'push'
        uses: karthikeyan-karuppiah/devsecops-actions/validate-push-commit@v1

      # 2. Exact Version Tag (`@v1.0.0`):
      # Recommended when locking onto a specific immutable release tag.
      - name: Lint YAML, Compose & Dockerfiles
        uses: karthikeyan-karuppiah/devsecops-actions/lint-containers@v1.0.0
        with:
          enforce-compose-lint: 'false'

      # 3. Immutable Commit SHA (`@<40-char-sha>`):
      # Recommended for strict supply-chain security (or generated via `gh actions-lock`).
      - name: Run Trivy Secret & Container Scans
        id: trivy
        uses: karthikeyan-karuppiah/devsecops-actions/trivy-security@<full-40-char-commit-sha> # v1.0.0
        with:
          enforce-image-cves: 'false'
          sarif-file: 'trivy-results.sarif'

      # Optional: Upload SARIF report to GitHub Security > Code Scanning
      - name: Upload SARIF to GitHub Code Scanning
        if: always() && hashFiles('trivy-results.sarif') != ''
        uses: github/codeql-action/upload-sarif@v3
        with:
          sarif_file: \${{ steps.trivy.outputs.sarif-file }}

      # Optional: Persist generated CycloneDX SBOMs as workflow artifacts
      - name: Upload CycloneDX SBOMs
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: cyclonedx-sboms
          path: \${{ steps.trivy.outputs.sbom-dir }}/*.cdx.json
          if-no-files-found: ignore
```

---

## Versioning & Supply-Chain Security

Every `uses:` reference follows GitHub's standard `<owner>/<repo>/<path>@<ref>` structure:

```text
karthikeyan-karuppiah / devsecops-actions / trivy-security @ v1
└─────────┬─────────┘   └─────┬──────┘   └──────┬───────┘   └┬┘
     GitHub Owner         Repo Name        Subfolder      Git Ref (Tag/Branch/SHA)
```

* **Floating Major Tags (`@v1`):** Following [GitHub's Action Release Guidelines](https://docs.github.com/en/actions/how-tos/create-and-publish-actions/release-and-maintain-actions), every semantic release (`v1.0.0`, `v1.1.0`, etc.) automatically updates the floating `v1` pointer so consumers receive non-breaking improvements without editing workflow files.
* **Exact Release Tags (`@v1.0.0`):** Pin to a full semantic version tag when you want explicit control over upgrades.
* **Commit SHA Pinning & Lockfiles:** Following [GitHub's Security Hardening Guidelines](https://docs.github.com/en/actions/reference/security/secure-use), production workflows should pin actions to an immutable 40-character commit SHA or manage them via [Workflow Dependency Lockfiles (`gh actions-lock`)](https://docs.github.com/en/actions/concepts/security/dependency-lockfiles):
  ```yaml
  uses: karthikeyan-karuppiah/devsecops-actions/trivy-security@<full-40-char-commit-sha> # v1.0.0
  ```

---

## Least-Privilege Permissions Matrix

All actions follow zero-trust principles and require minimal `GITHUB_TOKEN` scopes:

| Action | Required Permissions | Notes |
| :--- | :--- | :--- |
| **`validate-push-commit`** | `contents: read` (or `permissions: {}`) | Reads commit metadata directly from the `github.event` webhook payload. |
| **`lint-containers`** | `contents: read` | Reads repository YAML, Compose files, and Dockerfiles from the checked-out workspace. |
| **`trivy-security`** | `contents: read` (`security-events: write` optional) | `security-events: write` is only required if uploading the optional `sarif-file` to GitHub Code Scanning. |

---

## Security & Contributing

* **Security Policy:** Please review [SECURITY.md](./SECURITY.md) to report vulnerabilities privately via GitHub Security Advisories.
* **Contributing:** All commits to `main` must follow the [Conventional Commits](https://conventionalcommits.org) specification (`feat:`, `fix:`, `ci:`, `docs:`, `chore:`) and pass `actionlint` and `gh actions-lock verify`.
