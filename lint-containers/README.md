# Lint Containers & Compose

Provides a multi-layered static analysis and security posture gate for containerized infrastructure repositories across YAML files, Docker Compose manifests, and Dockerfiles.

## Pipeline Stages

1. **YAML Syntax & Formatting (`yamllint`):** Validates structural YAML integrity across workflows and service definitions.
2. **Docker Compose Schema Validation (`docker compose config --no-interpolate --quiet`):** Verifies Compose syntax and service schemas across `docker-compose.yml`, `docker-compose.yaml`, `compose.yml`, and `compose.yaml` without failing on missing `.env` runtime variables.
3. **CIS & OWASP Compose Security Audit (`compose-lint`):** Installs `compose-lint` inside an isolated virtual environment (PEP 668 compliant) and audits Compose manifests for privileged mode, Docker socket mounts, host networking, hardcoded secrets, and missing resource limits.
4. **Conditional Dockerfile Linting (`hadolint`):** Detects `Dockerfile`, `*.dockerfile`, and `Dockerfile.*` files and runs Hadolint best-practice checks (cleanly skipped if no Dockerfiles exist).

## Usage

```yaml
- name: Lint Containers & Compose
  uses: karthikeyan-karuppiah/devsecops-actions/lint-containers@v1
  with:
    enforce-compose-lint: 'true'
    run-yamllint: 'true'
    hadolint-threshold: 'warning'
```

## Inputs

| Input | Description | Required | Default |
| :--- | :--- | :---: | :--- |
| `enforce-compose-lint` | Fail the workflow if `compose-lint` detects security misconfigurations (`'true'` or `'false'`). | No | `'false'` |
| `compose-lint-version` | Pinned `compose-lint` PyPI package version to install (uses latest if empty). | No | `''` |
| `run-yamllint` | Enable repository-wide YAML linting via `yamllint` (`'true'` or `'false'`). | No | `'true'` |
| `yamllint-config-file` | Optional path to a custom `.yamllint` configuration file (uses built-in defaults if empty). | No | `''` |
| `hadolint-threshold` | Minimum severity threshold to fail Hadolint (`error`, `warning`, `info`, `style`, `ignore`). | No | `'warning'` |

## Outputs

| Output | Description |
| :--- | :--- |
| `compose-files-found` | Indicates whether any Docker Compose files were detected and linted (`'true'` or `'false'`). |
| `dockerfiles-found` | Indicates whether any Dockerfiles were detected and linted (`'true'` or `'false'`). |
