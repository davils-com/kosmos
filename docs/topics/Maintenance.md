# Maintenance and Updates

<link-summary>
How %product% releases, updates and registry cleanup work — and what stays manual.
</link-summary>

<web-summary>
How %product% is versioned and released, how base-image and Action updates are automated with
Dependabot, how the registry is pruned, and which tool bumps stay manual.
</web-summary>

<card-summary>
Releases, the tag scheme, automated updates, registry cleanup, and the manual bumps.
</card-summary>

## Releasing

A release is a Git **tag** push. The build workflow then, for every variant, builds, scans, signs
and promotes the tags (see [](Security.md)). Tags follow semantic versioning; the tag name may
carry a leading `v`, which is stripped for the image tag.

### Tag scheme

| Tag | Points at |
|---|---|
| `:<variant>-%version%` | the exact release of a variant |
| `:<variant>-%major_minor%` | the latest patch of that variant's minor line |
| `:<variant>-latest` | the latest release of that variant |
| `:%version%` / `:%major_minor%` / `:latest` | **full** (backward-compatible plain tags) |

## Automated updates

[Dependabot](%repo%/blob/main/.github/dependabot.yml) opens PRs for:

- **Base image** — the `eclipse-temurin` digest pinned in the `Dockerfile`. This is how base-OS
  security patches arrive.
- **GitHub Actions** — every Action is pinned by commit SHA and kept current.

## Manual updates

Dependabot does **not** track the toolchain versions baked into the image — Gradle, the Android
command-line and build-tools, Trivy and Chrome. Bump these with a normal PR:

- Gradle and Android versions live in [`docker-bake.hcl`](%repo%/blob/main/docker-bake.hcl).
- Trivy and Chrome are installed from their upstream apt repositories by the scripts in
  [`scripts/`](%repo%/tree/main/scripts) and track their repository's current release.

After bumping, cut a new version tag so the change is built, scanned and published.

## Registry cleanup

Publishing by digest — plus SBOM and provenance attestations — leaves untagged manifest versions
behind. A [scheduled workflow](%repo%/blob/main/.github/workflows/cleanup-ghcr.yml) prunes untagged
container versions weekly, so the package does not accumulate dangling storage. Tagged releases are
never touched.

> For an organisation-owned package the default `GITHUB_TOKEN` may lack delete rights. If the
> cleanup job cannot remove versions, provide a PAT with `delete:packages`.
>
{style="note"}

## Keeping the image small

The size discipline is structural, not a maintenance chore: multi-stage builds keep archives and
caches out of the shipped layers (see [](Build-Configuration.md)). When adding a tool, install it
in a builder stage and copy only the finished artifact, or scope it to the variant that needs it
rather than `base`.
