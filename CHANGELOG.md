# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## 1.1.0

### Added
- **Multi-variant image**: build targets `base`, `native`, `android`, `chrome` and `full`, so a
  consumer pulls only the toolchain it needs. Plain tags (`:<ver>`, `:latest`) still point at
  `full` for backward compatibility; variants publish as `:<variant>-<ver>` / `-<major.minor>` /
  `-latest`. Defined in `docker-bake.hcl`.
- **Native toolchain** in `native`/`full`: CMake, `pkg-config`, `libsecret-1-dev`,
  `build-essential` (for JNI / C-interop, e.g. Kreate).
- **Supply-chain hardening** in CI: scan-then-promote flow — every variant is built by digest and
  Trivy-gated (SARIF to code scanning) in one phase, and tag promotion + keyless cosign signing run
  in a separate phase that only starts once all variants pass, so a single failed build publishes
  nothing. Includes CycloneDX SBOM + SLSA provenance attestations.
- **Automation**: Dependabot (base-image digest + Actions), weekly GHCR cleanup of untagged
  manifests, `.dockerignore`.
- **Documentation**: Writerside doc set under `docs/`, published to GitHub Pages via
  `.github/workflows/writerside.yml`.

### Changed
- **Tool versions bumped to latest**: Gradle `9.5.1` → `9.7.0`, Android build-tools `35.0.1` →
  `36.1.0`, command-line tools → `15859902`. JDK stays 17 (LTS target) and Android platform 36.
- **Multi-stage build**: tools are downloaded/extracted in throwaway builder stages and only the
  finished artifacts are copied into the final layers — zips, apt lists and SDK caches no longer
  ship. Base image pinned by digest.
- `rustup` installed with the `minimal` profile; docs stripped.
- All GitHub Actions pinned by commit SHA; CI builds `linux/amd64`.

### Fixed
- `RUn` typo in the Dockerfile.

## 1.0.2

### Added
- Integrated Trivy for automated vulnerability scanning of the Docker image.

### Changed
- Updated Dockerfile base image to `eclipse-temurin:17-jdk-jammy` for improved compatibility and security.

## 1.0.1

### Added
- Comprehensive English documentation in `README.md` including project overview, features, and usage instructions.

### Changed
- Updated Dockerfile to use Eclipse Temurin 17 JDK as the base image.
- Upgraded Gradle from 9.4.1 to 9.5.1.
- Upgraded Android Command-Line Tools to version 14742923_latest.
- Renamed `scripts/install-chore-headless.sh` to `scripts/install-headless-chrome.sh` for clarity.
- Simplified GitHub Actions workflow by removing branch triggers and optimizing tag handling.

## 1.0.0

### Added
- Initial release of the Kosmos development environment.
- Docker-based setup with support for Android, Rust, and Gradle development.
- Android SDK (Version 36) and Build Tools (35.0.1) installation support.
- Rust toolchain installation script and integration.
- Gradle (9.4.1) installation and configuration.
- Google Chrome Headless support for automated testing.
- GitHub Actions workflow for building and pushing Docker images to GitHub Container Registry.
- Project documentation including License (Apache 2.0) and Code of Conduct.
