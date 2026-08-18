# Image Variants

<link-summary>
The five %product% build targets — base, native, android, chrome, full — and when to use each.
</link-summary>

<web-summary>
%product% ships as five layered variants: base, native, android, chrome and full. Each pulls only
the toolchain it needs, so a plain JVM job does not download the Android SDK or Chrome.
</web-summary>

<card-summary>
base, native, android, chrome and full — what each contains and when to reach for it.
</card-summary>

%product% is a multi-stage image. Rather than one everything-image, each variant is a build target
that carries only the toolchain a class of jobs needs. The variants form a chain: `native` and the
other add-ons extend `base`, and `full` combines them.

## The variants

<table>
    <tr>
        <td>Variant</td>
        <td>Tag pattern</td>
        <td>Adds over base</td>
        <td>Use for</td>
    </tr>
    <tr>
        <td><code>base</code></td>
        <td><code>:base-%major_minor%</code></td>
        <td>— (JDK %jdk%, Gradle %gradle_version%, Trivy, git)</td>
        <td>Plain Kotlin / JVM builds</td>
    </tr>
    <tr>
        <td><code>native</code></td>
        <td><code>:native-%major_minor%</code></td>
        <td>CMake, build-essential, Rust/Cargo</td>
        <td>JNI and C-interop projects</td>
    </tr>
    <tr>
        <td><code>android</code></td>
        <td><code>:android-%major_minor%</code></td>
        <td>Android SDK (%android_sdk%), build-tools %build_tools%</td>
        <td>Android builds</td>
    </tr>
    <tr>
        <td><code>chrome</code></td>
        <td><code>:chrome-%major_minor%</code></td>
        <td>Headless Google Chrome</td>
        <td>Web / UI automation</td>
    </tr>
    <tr>
        <td><code>full</code></td>
        <td><code>:%major_minor%</code>, <code>:latest</code></td>
        <td>native + Android SDK + Chrome</td>
        <td>Everything (default)</td>
    </tr>
</table>

## Tags

Each variant publishes three moving tags:

- `:<variant>-%version%` — the exact release.
- `:<variant>-%major_minor%` — the latest patch of a minor line.
- `:<variant>-latest` — the latest release of that variant.

**full** additionally owns the prefix-less tags — `:%version%`, `:%major_minor%`, `:latest` — so
any existing `%image%:<version>` reference keeps resolving to the everything-image. Pin
`:<variant>-%version%` in production for reproducibility; use `:<variant>-%major_minor%` to pick up
patches automatically.

## Choosing a variant

- A JVM library or service with no native or Android code → **base**.
- A project with JNI headers, CMake, or Rust/Cargo (for example Kreate) → **native**.
- An Android application → **android**.
- Browser-driven tests (Selenium, Playwright, Puppeteer) → **chrome**.
- A monorepo that touches several of the above, or when in doubt → **full**.

> Trivy ships in **every** variant, not just `full`: it is both the scanner the CI security jobs
> call and the binary that toolchain plugins (such as Kreate's Trivy tasks) shell out to.
>
{style="note"}

To build a variant yourself, see [](Build-Configuration.md).
