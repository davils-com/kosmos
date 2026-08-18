# Overview

<link-summary>
What %product% is, the problems it removes, and how its image variants are layered.
</link-summary>

<web-summary>
%product% is a multi-stage Docker base image for Davils' Kotlin, Android and Rust CI. It ships JDK,
Gradle, a native toolchain, the Android SDK and headless Chrome as separate variants, so each
pipeline pulls only the layer it needs.
</web-summary>

<card-summary>
The problems %product% removes and how its five build variants are layered.
</card-summary>

Building across the JVM, native (JNI / C-interop) and Android worlds means keeping a matching set
of toolchains — JDK, Gradle, CMake, Rust, the Android SDK — aligned across every developer machine
and every CI runner. Installing them per job is slow and drifts; baking them all into one image
makes every job pull multiple gigabytes it mostly does not use.

**%product%** solves both. It is a single, reproducible base image published as
`%image%`, built once and shared, and split into **variants** so a job pulls only the toolchain it
needs.

## The variants at a glance

The variants form a layered chain rather than five unrelated images:

- **base** — JDK %jdk%, Gradle %gradle_version%, Trivy, git. The smallest image; enough for a plain
  Kotlin/JVM build.
- **native** — `base` plus CMake, `build-essential` and the Rust/Cargo toolchain, for JNI and
  C-interop projects.
- **android** — `base` plus the Android SDK.
- **chrome** — `base` plus headless Google Chrome, for web and UI automation.
- **full** — everything (`native` + Android SDK + Chrome). This is what the plain, prefix-less tag
  points at, so existing `%image%:<version>` references keep resolving to the everything-image.

See [](Variants.md) for the full breakdown and [](Getting-Started.md) to pull one.

## What it is not

- It is **not** a runtime image. %product% is a *build* environment — it carries JDKs and SDKs, not
  a slim production runtime. Ship your application on a minimal runtime image of its own.
- It does **not** pin every transitive apt package. Tool versions (Gradle, Android tools, Trivy,
  Chrome) are fixed and reviewable; the base OS layer is pinned by digest and updated deliberately.

## How it is built and published

Every variant is defined in one `docker-bake.hcl` and built by a single CI workflow that
**scans, signs and attests before it tags** — a fixable `CRITICAL`/`HIGH` vulnerability fails the
build, an SBOM and SLSA provenance are attached, and the image is signed with cosign. See
[](Security.md).
