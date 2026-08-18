# Getting Started

<link-summary>
Pull a %product% variant, run a container, and build inside it.
</link-summary>

<web-summary>
Pull a %product% variant from GHCR, run an interactive container, or use it as your CI image. No
build required — the images are published to `%image%`.
</web-summary>

<card-summary>
Pull a variant, run a container, and build your project inside %product%.
</card-summary>

%product% is published to the GitHub Container Registry at `%image%`. You do not need to build it —
pull the [variant](Variants.md) you need.

## Pull a variant

```bash
# Smallest image that can run a JNI / native Kotlin build:
docker pull %image%:native-%major_minor%

# Plain Kotlin/JVM build:
docker pull %image%:base-%major_minor%

# The full everything-image (plain tag = full):
docker pull %image%:%major_minor%
```

Each variant is published as three moving tags — `:<variant>-%version%`, `:<variant>-%major_minor%`
and `:<variant>-latest` — plus the plain tags (`:%version%`, `:%major_minor%`, `:latest`) which
always point at **full**.

## Run an interactive container

Mount your project and drop into a shell. The image runs as the non-root user `developer`:

```bash
docker run -it --rm -v "$(pwd):/app" %image%:native-%major_minor%
```

```bash
# Inside the container:
java -version      # Temurin JDK %jdk%
gradle -v          # Gradle %gradle_version%
cmake --version    # native variant
cargo --version    # native variant
```

## Build your project

Because the toolchain is already present, a build is just your usual Gradle invocation:

```bash
docker run --rm -v "$(pwd):/app" %image%:native-%major_minor% \
  ./gradlew build --no-daemon
```

## Verify what you pulled

Every published image is signed and carries an SBOM and provenance. To verify the signature:

```bash
cosign verify %image%:native-%major_minor% \
  --certificate-identity-regexp 'https://github.com/davils-com/kosmos/.github/workflows/.*' \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com
```

See [](Security.md) for the full provenance story.

## Next steps

- [](Variants.md) — pick the right image for your job.
- [](CI-Integration.md) — wire %product% into GitHub Actions or GitLab CI.
- [](Build-Configuration.md) — build or customise the image locally.
