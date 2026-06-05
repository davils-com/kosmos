<h1 align="center">Kosmos</h1>

<p align="center">
  <a href="https://opensource.org/licenses/Apache-2.0">
    <img src="https://img.shields.io/badge/License-Apache_2.0-Redtronics?style=for-the-badge&logo=apache&labelColor=white&color=blue" alt="License">
  </a>
  <a href="https://adoptium.net/temurin/releases/?version=17">
    <img src="https://img.shields.io/badge/JDK-17-Redtronics?style=for-the-badge&logo=eclipseadoptium&labelColor=white&color=purple" alt="JDK 17">
  </a>
  <a href="https://gradle.org">
    <img src="https://img.shields.io/badge/Gradle-9.5.1-Redtronics?style=for-the-badge&logo=gradle&labelColor=white&color=02303A" alt="Gradle">
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
- **Build Tools**: Version 35.0.1 included by default.
- **Command-Line Tools**: Includes `sdkmanager`, `platform-tools`, and `cmdline-tools` for automated management.

### Java & Kotlin Ecosystem
Built on top of industry-standard runtimes:
- **Eclipse Temurin JDK 17**: High-performance, open-source Java distribution.
- **Gradle 9.5.1**: Optimized build system for JVM and Android projects.
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

## Quick Start

### Build the Image
Clone the repository and build the image locally:

```bash
docker build -t kosmos-dev .
```

### Start the Container
Run an interactive shell inside the environment, mounting your current directory:

```bash
docker run -it --rm -v $(pwd):/app kosmos-dev
```

---

## Environment Reference

| Variable | Path | Description |
|:---------|:-----|:------------|
| `ANDROID_SDK_ROOT` | `/sdk` | Root directory for Android SDK tools and platforms |
| `GRADLE_HOME` | `/opt/gradle/gradle-9.5.1` | Location of the Gradle installation |
| `CHROME_BIN` | `/usr/bin/google-chrome` | Path to the Google Chrome binary |
| `CARGO_HOME` | `/usr/local/cargo` | Storage for Rust Cargo binaries and packages |
| `RUSTUP_HOME` | `/usr/local/rustup` | Directory for Rust toolchains and metadata |

*Note: The system `PATH` is automatically updated to include Android tools, Gradle, and Cargo binaries.*

---

## Build Configuration

You can customize the installed versions by passing `--build-arg` during the build process:

| Argument | Default Value | Description |
|:---------|:--------------|:------------|
| `CMDLINE_TOOLS_VERSION` | `14742923_latest` | Android command-line tools version |
| `ANDROID_SDK_VERSION` | `36` | Target Android Platform version |
| `BUILD_TOOLS_VERSION` | `35.0.1` | Android Build Tools version |
| `GRADLE_VERSION` | `9.5.1` | Installed Gradle version |
| `USER_NAME` | `developer` | Default non-root user name |
| `USER_UID` | `1000` | UID for the non-root user |
| `USER_GID` | `1000` | GID for the non-root user |

### Custom Build Example
```bash
docker build --build-arg GRADLE_VERSION=8.10.2 -t kosmos-dev:custom .
```

---

## Project Structure

- `Dockerfile`: The main container image definition.
- `scripts/`: Modular shell scripts for component installation.
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
