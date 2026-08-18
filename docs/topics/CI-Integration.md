# CI Integration

<link-summary>
Use %product% as the image for GitHub Actions and GitLab CI jobs.
</link-summary>

<web-summary>
Run your jobs inside %product% on GitHub Actions or GitLab CI. Pick the variant that matches your
toolchain and pin a version tag.
</web-summary>

<card-summary>
Wire %product% into GitHub Actions and GitLab CI as the job image.
</card-summary>

%product% is designed to be the container your CI jobs run inside. Pick the
[variant](Variants.md) that matches your toolchain and reference it by tag.

## GitLab CI

Set the image on a job (or globally). The Davils reusable Kotlin pipeline
(`davils/devops/gitlab-cicd`) already runs on %product%:

```yaml
build:
  image: %image%:native-%major_minor%
  script:
    - ./gradlew build --no-daemon
```

Everything the pipeline needs is already present — no `before_script` toolchain install. Because
the native variant carries Trivy, the pipeline's security jobs and any Kreate Trivy tasks work out
of the box.

## GitHub Actions

Run a job in the container with `container:`:

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    container:
      image: %image%:native-%major_minor%
    steps:
      - uses: actions/checkout@v4
      - run: ./gradlew build --no-daemon
```

## Choosing the tag

- Pin `:<variant>-%version%` for a fully reproducible pipeline.
- Use `:<variant>-%major_minor%` to pick up patch rebuilds (including base-image security
  patches) automatically.
- Avoid `:<variant>-latest` in CI — it moves across minor versions.

## Caching Gradle

The image ships Gradle, but prefer the project's wrapper (`./gradlew`) so the pinned version wins.
Cache `GRADLE_USER_HOME` between runs for speed; on GitLab set it inside the workspace
(`GRADLE_USER_HOME: "$CI_PROJECT_DIR/.gradle"`) so it can be cached.

## Which variant

| Job does… | Variant |
|---|---|
| Plain Kotlin/JVM build & test | `base` |
| JNI / CMake / Rust (e.g. Kreate) | `native` |
| Android assemble | `android` |
| Browser-driven tests | `chrome` |
| A mix of the above | `full` |

See [](Variants.md) for the full contents of each.
