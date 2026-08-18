<h1 align="center">Kosmos</h1>

<p align="center">
  <a href="https://opensource.org/licenses/Apache-2.0">
    <img src="https://img.shields.io/badge/License-Apache_2.0-Redtronics?style=for-the-badge&logo=apache&labelColor=white&color=blue" alt="License">
  </a>
  <a href="https://adoptium.net/temurin/releases/?version=17">
    <img src="https://img.shields.io/badge/JDK-17-Redtronics?style=for-the-badge&logo=eclipseadoptium&labelColor=white&color=purple" alt="JDK 17">
  </a>
  <a href="https://gradle.org">
    <img src="https://img.shields.io/badge/Gradle-9.7.0-Redtronics?style=for-the-badge&logo=gradle&labelColor=white&color=02303A" alt="Gradle">
  </a>
  <a href="https://davils-com.github.io/kosmos/">
    <img src="https://img.shields.io/badge/Docs-GitHub_Pages-Redtronics?style=for-the-badge&logo=readthedocs&labelColor=white&color=FF8D09" alt="Documentation">
  </a>
</p>

<p align="center">
  <strong>Kosmos</strong> is a comprehensive Docker-based development environment designed for modern cross-platform engineering.
  It provides a ready-to-use stack for Android, Java/Kotlin, Rust, and Web Automation, ensuring consistency across development and CI/CD pipelines.
</p>

---

## Table of Contents

- [Overview](#overview)
- [Core Features](#core-features)
- [Quick Start](#quick-start)
- [Environment Reference](#environment-reference)
- [Build Configuration](#build-configuration)
- [Project Structure](#project-structure)
- [Contributing](#contributing)
- [License & Ethics](#license--ethics)

---

## Overview

Developing across multiple ecosystems like Android, JVM, and Rust can be challenging due to complex toolchain dependencies. **Kosmos** eliminates this "works on my machine" syndrome by:

*   **Standardizing the Toolchain**: Provides pre-configured versions of JDK, Android SDK, and Gradle.
*   **Integrating Native Support**: Full Rust toolchain inclusion for native development and cross-compilation.
*   **Automating Web Testing**: Pre-installed Headless Chrome for robust web automation and integration testing.
*   **Ensuring Security**: Designed with non-root user execution as a default for improved container security.

---

## Core Features

### Android Development
Kosmos comes with a full Android SDK stack optimized for modern builds:
- **Android SDK**: Pre-installed Platform version 36.
- **Build Tools**: Version 36.1.0 included by default.
- **Command-Line Tools**: Includes `sdkmanager`, `platform-tools`, and `cmdline-tools` for automated management.

### Java & Kotlin Ecosystem
Built on top of industry-standard runtimes:
- **Eclipse Temurin JDK 17**: High-performance, open-source Java distribution.
- **Gradle 9.7.0**: Optimized build system for JVM and Android projects.
- **Ready for Kotlin**: Fully compatible with Kotlin Multiplatform and JVM targets.

### Rust Toolchain
Seamless integration for native systems programming:
- **Rustup & Cargo**: Full access to the Rust ecosystem.
- **Native Interop**: Ideal for projects using JNI or Rust-based Kotlin Multiplatform components.
- **Cross-Compilation**: Ready for building native binaries within the container.

### Web Automation
Headless browser support for modern web workflows:
- **Google Chrome**: Pre-installed for headless execution.
- **Automation Ready**: Compatible with Selenium, Playwright, and Puppeteer.
- **System Binaries**: Environment variable `CHROME_BIN` is pre-configured for easy tool discovery.

---

## Documentation

Full documentation is published to **[davils-com.github.io/kosmos](https://davils-com.github.io/kosmos/)**
(built from `docs/` with Writerside). It covers the variants, build configuration, security and
provenance, CI integration, and maintenance.

---

## Image Variants

Kosmos is a multi-stage image with several build targets, so a CI job pulls only the toolchain
it actually needs instead of the whole multi-GB stack. The plain (prefix-less) tag always points
at `full`, so existing `kosmos:<version>` references keep resolving to the everything-image.

| Variant | Tag pattern | Contains | Typical use |
|:--------|:------------|:---------|:------------|
| `base` | `:base-<ver>` | JDK 17, Gradle, Trivy, git | Plain Kotlin/JVM builds |
| `native` | `:native-<ver>` | `base` + CMake, build-essential, Rust/Cargo | JNI / C-interop (e.g. Kreate) |
| `android` | `:android-<ver>` | `base` + Android SDK | Android builds |
| `chrome` | `:chrome-<ver>` | `base` + headless Chrome | Web/UI automation |
| `full` | `:<ver>`, `:latest` | `native` + Android SDK + Chrome | Everything (default) |

Each variant is published as `:<variant>-<version>`, `:<variant>-<major.minor>` and
`:<variant>-latest`.

---

## Quick Start

### Pull a variant
```bash
# Smallest image that can run a JNI/native Kotlin build:
docker pull ghcr.io/davils-com/kosmos:native-1.1
# The full everything-image:
docker pull ghcr.io/davils-com/kosmos:1.1
```

### Build locally
All variants are defined in `docker-bake.hcl`:

```bash
docker buildx bake native        # one variant
docker buildx bake               # every variant
docker build --target native -t kosmos-native .   # or a plain targeted build
```

### Start the Container
Run an interactive shell inside the environment, mounting your current directory:

```bash
docker run -it --rm -v $(pwd):/app ghcr.io/davils-com/kosmos:native-1.1
```

---

## Environment Reference

| Variable | Path | Description |
|:---------|:-----|:------------|
| `ANDROID_SDK_ROOT` | `/sdk` | Root directory for Android SDK tools and platforms |
| `GRADLE_HOME` | `/opt/gradle/gradle-9.7.0` | Location of the Gradle installation |
| `CHROME_BIN` | `/usr/bin/google-chrome` | Path to the Google Chrome binary |
| `CARGO_HOME` | `/usr/local/cargo` | Storage for Rust Cargo binaries and packages |
| `RUSTUP_HOME` | `/usr/local/rustup` | Directory for Rust toolchains and metadata |

*Note: The system `PATH` is automatically updated to include Android tools, Gradle, and Cargo binaries.*

---

## Build Configuration

You can customize the installed versions by passing `--build-arg` during the build process:

| Argument | Default Value | Description |
|:---------|:--------------|:------------|
| `CMDLINE_TOOLS_VERSION` | `15859902_latest` | Android command-line tools version |
| `ANDROID_SDK_VERSION` | `36` | Target Android Platform version |
| `BUILD_TOOLS_VERSION` | `36.1.0` | Android Build Tools version |
| `GRADLE_VERSION` | `9.7.0` | Installed Gradle version |
| `USER_NAME` | `developer` | Default non-root user name |
| `USER_UID` | `1000` | UID for the non-root user |
| `USER_GID` | `1000` | GID for the non-root user |

### Custom Build Example
```bash
docker build --build-arg GRADLE_VERSION=8.10.2 -t kosmos-dev:custom .
```

---

## Security & Provenance

Every published digest is built, scanned and signed before any human-readable tag is moved onto
it (scan-then-promote), so an unscanned image can never win a tag:

- **Vulnerability gate**: Trivy scans each image; a fixable `CRITICAL`/`HIGH` fails the build.
  Results are uploaded to GitHub code scanning.
- **SBOM**: a CycloneDX SBOM is attached as an attestation and published as a workflow artifact.
- **Provenance**: SLSA provenance (`mode=max`) is attached at build time.
- **Signing**: images are signed keyless with [cosign](https://github.com/sigstore/cosign) via
  GitHub OIDC.

Verify a pulled image:

```bash
# Signature (keyless — verify against the GitHub Actions OIDC identity):
cosign verify ghcr.io/davils-com/kosmos:native-1.1 \
  --certificate-identity-regexp 'https://github.com/davils-com/kosmos/.github/workflows/.*' \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com

# SBOM / provenance attestations:
docker buildx imagetools inspect ghcr.io/davils-com/kosmos:native-1.1
```

Base-image digest and GitHub Actions are pinned and kept current by Dependabot; untagged
manifests are pruned weekly (`.github/workflows/cleanup-ghcr.yml`).

---

## Project Structure

- `Dockerfile`: Multi-stage image definition with the `base`/`native`/`android`/`chrome`/`full` targets.
- `docker-bake.hcl`: Target and tag definitions (source of truth for builds).
- `scripts/`: Modular shell scripts for component installation.
- `.github/workflows/`: Build/scan/sign/publish and GHCR cleanup.
- `.github/dependabot.yml`: Base-image and Actions update automation.
- `README.md`: This documentation.

---

## Contributing

We welcome contributions to improve the Kosmos environment!

- **Issue Reporting**: Use the GitHub issue tracker for bugs and feature requests.
- **Pull Requests**: Ensure any changes to installation scripts are tested and documented.

---

## License & Ethics

- **License**: Published under the **Apache License 2.0**. See `LICENSE` for details.
- **Code of Conduct**: We adhere to our [Code of Conduct](CODE_OF_CONDUCT.md).

---

<p align="center">
  Maintained by <a href="https://github.com/davils-com"><b>Davils</b></a>
</p>
