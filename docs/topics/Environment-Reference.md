# Environment Reference

<link-summary>
Environment variables, paths, and the tool versions each %product% variant ships.
</link-summary>

<web-summary>
The environment variables, filesystem paths and bundled tool versions provided by %product%,
and which variant each belongs to.
</web-summary>

<card-summary>
Environment variables, paths, and the tools each variant provides.
</card-summary>

## User

Every variant runs as the non-root user **`developer`** (UID 1000, GID 1000) with `/app` as the
working directory. Mount your project at `/app`.

## Environment variables

<table>
    <tr><td>Variable</td><td>Value</td><td>Present in</td></tr>
    <tr><td><code>GRADLE_HOME</code></td><td><code>/opt/gradle/gradle-%gradle_version%</code></td><td>all</td></tr>
    <tr><td><code>RUSTUP_HOME</code></td><td><code>/usr/local/rustup</code></td><td>native, full</td></tr>
    <tr><td><code>CARGO_HOME</code></td><td><code>/usr/local/cargo</code></td><td>native, full</td></tr>
    <tr><td><code>ANDROID_SDK_ROOT</code></td><td><code>/sdk</code></td><td>android, full</td></tr>
    <tr><td><code>CHROME_BIN</code></td><td><code>/usr/bin/google-chrome</code></td><td>chrome, full</td></tr>
</table>

`PATH` is extended with Gradle, and — where present — Cargo, the Android command-line tools and
platform-tools.

## Bundled tools by variant

<table>
    <tr><td>Tool</td><td>Version</td><td>base</td><td>native</td><td>android</td><td>chrome</td><td>full</td></tr>
    <tr><td>Temurin JDK</td><td>%jdk%</td><td>✓</td><td>✓</td><td>✓</td><td>✓</td><td>✓</td></tr>
    <tr><td>Gradle</td><td>%gradle_version%</td><td>✓</td><td>✓</td><td>✓</td><td>✓</td><td>✓</td></tr>
    <tr><td>Trivy</td><td>latest</td><td>✓</td><td>✓</td><td>✓</td><td>✓</td><td>✓</td></tr>
    <tr><td>git</td><td>distro</td><td>✓</td><td>✓</td><td>✓</td><td>✓</td><td>✓</td></tr>
    <tr><td>CMake + build-essential</td><td>distro</td><td>—</td><td>✓</td><td>—</td><td>—</td><td>✓</td></tr>
    <tr><td>Rust / Cargo</td><td>stable</td><td>—</td><td>✓</td><td>—</td><td>—</td><td>✓</td></tr>
    <tr><td>Android SDK</td><td>%android_sdk% / build-tools %build_tools%</td><td>—</td><td>—</td><td>✓</td><td>—</td><td>✓</td></tr>
    <tr><td>Google Chrome</td><td>stable</td><td>—</td><td>—</td><td>—</td><td>✓</td><td>✓</td></tr>
</table>

> The Gradle in the image is a convenience. Projects that ship a Gradle wrapper should invoke
> `./gradlew`, so the pinned wrapper version wins over the image's Gradle.
>
{style="note"}

## Platform

Images are published for **linux/amd64**. There is no arm64 build; run under emulation if you need
it on Apple Silicon, or raise an issue to discuss adding the architecture.
