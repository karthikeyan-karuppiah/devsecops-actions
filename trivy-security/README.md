# Trivy Secret & Image Security Scan

Performs automated filesystem secret detection, container image CVE vulnerability scanning, and CycloneDX SBOM generation using [Aqua Security Trivy](https://github.com).

## Pipeline Stages

1. **Toolchain & DB Cache:** Installs the pinned Trivy CLI version and caches the vulnerability database across workflow runs.
2. **Filesystem Secret Scan (Blocking):** Scans repository files for leaked API keys, tokens, and private credentials (`--exit-code 1`).
3. **Container Image CVE Scan & SBOM Export:** Extracts unique `image:` references from Docker Compose files, scans each image for known CVEs, and writes a CycloneDX JSON SBOM (`*.cdx.json`) per image.

---

## Usage

### Basic Usage (Blocking Secrets, Non-Blocking Image CVEs)
```yaml
- name: Run Trivy Secret & Container Scans
  uses: karthikeyan-karuppiah/github-actions/trivy-security@v1
```

### Strict Mode with SBOM Artifact Upload
```yaml
- name: Run Trivy Secret & Container Scans
  id: trivy
  uses: karthikeyan-karuppiah/github-actions/trivy-security@v1
  with:
    trivy-version: 'v0.76.1'
    severity: 'CRITICAL,HIGH'
    enforce-image-cves: 'true'
    sbom-dir: 'trivy-sboms'

- name: Upload CycloneDX SBOMs
  if: always()
  uses: actions/upload-artifact@v4
  with:
    name: container-sboms
    path: \${{ steps.trivy.outputs.sbom-dir }}/*.cdx.json
    if-no-files-found: ignore
```

---

## Inputs

| Input | Description | Required | Default |
| :--- | :--- | :---: | :--- |
| `trivy-version` | Pinned Trivy CLI release version to install. | No | `'v0.76.1'` |
| `severity` | Comma-separated vulnerability severities to evaluate (`UNKNOWN,LOW,MEDIUM,HIGH,CRITICAL`). | No | `'CRITICAL,HIGH'` |
| `enforce-image-cves` | Fail the workflow if container image CVEs match the severity filter (`"true"` or `"false"`). | No | `'false'` |
| `sbom-dir` | Output directory where CycloneDX JSON SBOM files will be written. | No | `'trivy-sboms'` |

---

## Outputs

| Output | Description |
| :--- | :--- |
| `sbom-dir` | Directory path containing generated CycloneDX SBOM files (`*.cdx.json`). |
