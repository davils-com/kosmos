# Security and Provenance

<link-summary>
How %product% images are scanned, signed and attested before any tag is promoted.
</link-summary>

<web-summary>
Every %product% image is built by digest, scanned by Trivy, signed with cosign and shipped with an
SBOM and SLSA provenance — and only then are the human-readable tags promoted onto it.
</web-summary>

<card-summary>
Scan-then-promote publishing: Trivy gate, SBOM, SLSA provenance and keyless cosign signatures.
</card-summary>

%product% treats the image as a supply-chain artifact. The publishing workflow is built so that a
tag can never point at an image that was not scanned and signed.

## Scan-then-promote

For each variant the CI workflow:

1. **Builds and pushes by digest** — the image is pushed to `%image%` *without* a human tag, and an
   SBOM and SLSA provenance (`mode=max`) are attached as attestations.
2. **Scans** the digest with Trivy. Findings are uploaded to GitHub code scanning as SARIF.
3. **Gates** on the result — a *fixable* `CRITICAL` or `HIGH` vulnerability fails the job.
4. **Signs** the digest keyless with [cosign](https://github.com/sigstore/cosign) via GitHub OIDC.
5. **Promotes** the tags — only now are `:<variant>-%version%`, `:<variant>-%major_minor%` and
   `:<variant>-latest` moved onto the scanned, signed digest.

Because tagging is the last step, an image that fails the scan never receives a tag.

## Verify a pulled image

### Signature

```bash
cosign verify %image%:native-%major_minor% \
  --certificate-identity-regexp 'https://github.com/davils-com/kosmos/.github/workflows/.*' \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com
```

### SBOM and provenance

The SBOM and provenance are attached to the image and also published as a CycloneDX workflow
artifact per variant. Inspect the attestations with:

```bash
docker buildx imagetools inspect %image%:native-%major_minor%
```

## Pinning and updates

- The base OS image is pinned by **digest** in the `Dockerfile`; Dependabot proposes digest bumps,
  which is how base-image security patches land.
- All GitHub Actions are pinned by commit SHA and kept current by Dependabot.
- Untagged manifests left behind by digest pushes and attestations are pruned weekly.

See [](Maintenance.md) for the update and cleanup mechanics.

## Reporting a vulnerability

Report suspected vulnerabilities privately through the repository's
[security policy](%repo%/security), not the public issue tracker.
