# Trivy Security Scan & SBOM Generator

Executes automated vulnerability, misconfiguration, secret, and supply-chain security assessments using [Aqua Security Trivy](https://trivy.dev) across repository source files and referenced container images.

## Pipeline Stages

1. **Toolchain & DB Caching:** Installs a pinned Trivy CLI release via `aquasecurity/setup-trivy` with vulnerability database caching enabled.
2. **Filesystem Security Gate (`trivy fs`):**
   * Enforces a **blocking** secret scan (`CRITICAL,HIGH,MEDIUM`) to catch leaked API keys, tokens, and private keys.
   * Evaluates application dependencies (`vuln`) and IaC misconfigurations (`misconfig`), with optional SARIF export for GitHub Code Scanning.
3. **Full-Stack Container Image Audit & SBOM Export (`trivy image`):**
   * Automatically discovers and deduplicates all `image:` references across `docker-compose.yml`, `docker-compose.yaml`, `compose.yml`, and `compose.yaml`.
   * Generates standard **CycloneDX JSON SBOMs** (`*.cdx.json`) for every image **before** evaluating CVE exit codes so complete supply-chain artifacts are always produced.

## Usage

```yaml
- name: Run Trivy Security Scan & Generate SBOMs
  id: trivy
  uses: karthikeyan-karuppiah/devsecops-actions/trivy-security@v1
  with:
    severity: 'CRITICAL,HIGH'
    fs-scanners: 'vuln,secret,misconfig'
    enforce-fs-findings: 'true'
    enforce-image-cves: 'true'
    ignore-unfixed: 'true'
    sbom-dir: 'trivy-sboms'
    sarif-file: 'trivy-results.sarif'
```

## Inputs

| Input | Description | Required | Default |
| :--- | :--- | :---: | :--- |
| `trivy-version` | Pinned Trivy CLI release version to install. | No | `'v0.76.1'` |
| `severity` | Comma-separated vulnerability severities to evaluate (`UNKNOWN,LOW,MEDIUM,HIGH,CRITICAL`). | No | `'CRITICAL,HIGH'` |
| `fs-scanners` | Comma-separated Trivy filesystem scanners to run (`vuln,secret,misconfig`). | No | `'vuln,secret,misconfig'` |
| `enforce-fs-findings` | Fail the workflow if filesystem vulnerabilities or misconfigurations match `severity` (`'true'` or `'false'`). | No | `'true'` |
| `enforce-image-cves` | Fail the workflow if container image CVEs match `severity` (`'true'` or `'false'`). | No | `'false'` |
| `ignore-unfixed` | Ignore vulnerabilities without an upstream vendor fix (`'true'` or `'false'`). | No | `'false'` |
| `sbom-dir` | Output directory where CycloneDX JSON SBOM files will be written. | No | `'trivy-sboms'` |
| `sarif-file` | Optional file path to write aggregated SARIF results for GitHub Code Scanning. | No | `''` |

## Outputs

| Output | Description |
| :--- | :--- |
| `sbom-dir` | Directory path containing generated CycloneDX SBOM files (`*.cdx.json`). |
| `sarif-file` | Path to the generated SARIF report file (if `sarif-file` input was provided). |
