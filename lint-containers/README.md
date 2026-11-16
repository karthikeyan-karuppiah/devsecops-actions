# Lint Containers & Compose

A multi-layered static analysis and security posture action for containerized infrastructure repositories using YAML, Docker Compose, and Dockerfiles.

## Pipeline Stages

1. **YAML Linting (`yamllint`):** Checks structural YAML syntax across workflows and configuration files.
2. **Compose Schema Verification (`docker compose config`):** Validates syntax and variable interpolation for all `docker-compose.yml`, `compose.yml`, and `compose.yaml` files.
3. **Compose Security Audit (`compose-lint`):** Evaluates Compose services against OWASP and CIS Docker Benchmark rules (privileged containers, Docker socket mounts, missing capability drops, `0.0.0.0` port bindings, missing resource limits).
4. **Conditional Dockerfile Linting (`hadolint`):** Automatically detects any `Dockerfile*` files and runs Hadolint best-practice checks.

---

## Usage

### Audit Mode (Non-Blocking Compose Security Warnings)
```yaml
- name: Lint YAML, Compose & Dockerfiles
  uses: karthikeyan-karuppiah/devsecops-actions/lint-containers@v1
```

### Strict Enforcement Mode (Fail Build on Security Findings)
```yaml
- name: Lint YAML, Compose & Dockerfiles
  uses: karthikeyan-karuppiah/devsecops-actions/lint-containers@v1
  with:
    enforce-compose-lint: 'true'
    run-yamllint: 'true'
    hadolint-threshold: 'warning'
```

---

## Inputs

| Input | Description | Required | Default |
| :--- | :--- | :---: | :--- |
| `enforce-compose-lint` | Fail the workflow if `compose-lint` detects security misconfigurations (`"true"` or `"false"`). | No | `'false'` |
| `run-yamllint` | Enable repository-wide YAML linting via `yamllint` (`"true"` or `"false"`). | No | `'true'` |
| `hadolint-threshold` | Minimum severity threshold to fail Hadolint (`error`, `warning`, `info`, `style`, `ignore`). | No | `'warning'` |

---

## Outputs

| Output | Description |
| :--- | :--- |
| `dockerfiles-found` | Indicates whether any Dockerfiles were detected and linted (`"true"` or `"false"`). |
