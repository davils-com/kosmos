# Build Configuration

<link-summary>
Build %product% variants locally with docker-bake.hcl and override tool versions with build-args.
</link-summary>

<web-summary>
Build any %product% variant locally with `docker buildx bake`, or a single target with
`docker build --target`. Tool versions are build-args centralised in docker-bake.hcl.
</web-summary>

<card-summary>
Build targets locally with docker-bake.hcl and override the bundled tool versions.
</card-summary>

You rarely need to build %product% yourself — the [variants](Variants.md) are published to
`%image%`. When you do (to test a change, or to pin a different tool version), the build is driven
by `docker-bake.hcl`, the single source of truth for targets and tags.

## Build with bake

```bash
# One variant:
docker buildx bake native

# Every variant:
docker buildx bake

# Inspect the resolved configuration without building:
docker buildx bake --print
```

## Build a single target directly

Each variant is a named stage in the `Dockerfile`, so a plain targeted build works too:

```bash
docker build --target native -t kosmos-native .
```

The default target (no `--target`) is **full**.

## Override tool versions

Versions are `build-arg`s with defaults in `docker-bake.hcl`. Override them per build:

<table>
    <tr><td>Argument</td><td>Default</td><td>Description</td></tr>
    <tr><td><code>GRADLE_VERSION</code></td><td><code>%gradle_version%</code></td><td>Bundled Gradle</td></tr>
    <tr><td><code>ANDROID_SDK_VERSION</code></td><td><code>%android_sdk%</code></td><td>Android platform</td></tr>
    <tr><td><code>BUILD_TOOLS_VERSION</code></td><td><code>%build_tools%</code></td><td>Android build-tools</td></tr>
    <tr><td><code>CMDLINE_TOOLS_VERSION</code></td><td><code>%cmdline_tools%</code></td><td>Android command-line tools</td></tr>
    <tr><td><code>USER_NAME</code> / <code>USER_UID</code> / <code>USER_GID</code></td><td><code>developer</code> / 1000 / 1000</td><td>Non-root build user</td></tr>
</table>

```bash
# Bake honours variables of the same name:
docker buildx bake native --set native.args.GRADLE_VERSION=9.6.0

# A plain build uses --build-arg:
docker build --target native --build-arg GRADLE_VERSION=9.6.0 -t kosmos-native .
```

## How the image stays small

%product% is multi-stage. Heavy tools (Gradle, the Android SDK, the Rust toolchain) are downloaded
and extracted in throwaway *builder* stages; the final variant stages copy only the finished
artifacts. Download archives, apt package lists and SDK caches never reach the shipped layers, and
the base OS is pinned by digest. The result: `base` is a fraction of the old everything-image, and a
job pulls only its variant.

## Tags produced by a release

The CI workflow passes `VERSION`, `MAJORMINOR` and `PUSH_LATEST` into bake so that a tagged release
publishes, per variant, `:<variant>-%version%`, `:<variant>-%major_minor%` and `:<variant>-latest`
(and the prefix-less equivalents for **full**). See [](Maintenance.md) for the release flow and
[](Security.md) for the scan-then-promote sequence.
