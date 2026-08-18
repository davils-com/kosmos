# syntax=docker/dockerfile:1
#
# Kosmos — multi-stage, multi-variant CI base image.
#
# Build a specific variant with `--target` (or the docker-bake.hcl targets):
#   base    JDK 17 + Gradle + Trivy                         (smallest)
#   native  base + CMake + build-essential + Rust/Cargo     (JNI / C-interop, e.g. Kreate)
#   android base + Android SDK
#   chrome  base + headless Google Chrome
#   full    native + Android SDK + Chrome                   (default; the historical "everything" image)
#
# Downloads happen in throwaway builder stages; the final stages copy only the finished
# artifacts, so zips, apt lists and SDK caches never reach the shipped layers.

# Pinned by digest so the base is reproducible and Dependabot can bump it deliberately.
ARG BASE_IMAGE=eclipse-temurin:17-jdk-jammy@sha256:9283f99ad21802850dd7420a865c495642a804c5a201f73377aef232ef12bccb

# ============================================================================================
# Builder stages (discarded — only their output is copied out)
# ============================================================================================
FROM ${BASE_IMAGE} AS downloader
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates wget curl unzip tar \
    && rm -rf /var/lib/apt/lists/*

FROM downloader AS gradle-dl
ARG GRADLE_VERSION=9.7.0
COPY scripts/install-gradle.sh /tmp/
RUN bash /tmp/install-gradle.sh "${GRADLE_VERSION}"

FROM downloader AS rust-dl
ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo
COPY scripts/install-rustup.sh /tmp/
RUN bash /tmp/install-rustup.sh

FROM downloader AS android-dl
ARG CMDLINE_TOOLS_VERSION=15859902_latest
ARG ANDROID_SDK_VERSION=36
ARG BUILD_TOOLS_VERSION=36.1.0
ENV ANDROID_SDK_ROOT=/sdk
COPY scripts/install-android-sdk.sh /tmp/
RUN bash /tmp/install-android-sdk.sh \
      "${CMDLINE_TOOLS_VERSION}" "${ANDROID_SDK_VERSION}" "${BUILD_TOOLS_VERSION}" "${ANDROID_SDK_ROOT}"

# ============================================================================================
# base — JDK 17 + Gradle + Trivy, non-root user
# ============================================================================================
FROM ${BASE_IMAGE} AS base

LABEL org.opencontainers.image.source="https://github.com/davils-com/kosmos" \
      org.opencontainers.image.description="Kosmos CI base image (JDK 17, Gradle, Trivy)" \
      org.opencontainers.image.licenses="Apache-2.0"

ARG USER_NAME=developer
ARG USER_UID=1000
ARG USER_GID=1000
ARG GRADLE_VERSION=9.7.0
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates git unzip tar libatomic1 curl gnupg \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd -g ${USER_GID} ${USER_NAME} \
    && useradd -m -u ${USER_UID} -g ${USER_GID} -s /bin/bash ${USER_NAME}

# Gradle (files only, from the builder stage).
COPY --from=gradle-dl /opt/gradle /opt/gradle

# Trivy — the security scanner Kreate's Gradle tasks shell out to and the CI SBOM job uses,
# so it belongs in every variant.
COPY scripts/install-trivy.sh /tmp/
RUN bash /tmp/install-trivy.sh && rm -f /tmp/install-trivy.sh

ENV GRADLE_HOME=/opt/gradle/gradle-${GRADLE_VERSION}
ENV PATH=${PATH}:${GRADLE_HOME}/bin

WORKDIR /app
RUN chown ${USER_NAME}:${USER_NAME} /app
USER ${USER_NAME}
CMD ["bash"]

# ============================================================================================
# native — base + CMake + build-essential + Rust/Cargo  (JNI / C-interop)
# ============================================================================================
FROM base AS native
USER root

ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo
ENV PATH=${PATH}:${CARGO_HOME}/bin

COPY scripts/install-cmake.sh /tmp/
RUN bash /tmp/install-cmake.sh && rm -f /tmp/install-cmake.sh

COPY --from=rust-dl /usr/local/rustup /usr/local/rustup
COPY --from=rust-dl /usr/local/cargo /usr/local/cargo
# cargo writes to CARGO_HOME (registry cache) at build time, so it must be user-writable.
RUN chown -R developer:developer /usr/local/rustup /usr/local/cargo

USER developer

# ============================================================================================
# android — base + Android SDK
# ============================================================================================
FROM base AS android
USER root

ENV ANDROID_SDK_ROOT=/sdk
COPY --from=android-dl /sdk /sdk
RUN chown -R developer:developer /sdk
ENV PATH=${PATH}:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/platform-tools

USER developer

# ============================================================================================
# chrome — base + headless Google Chrome
# ============================================================================================
FROM base AS chrome
USER root

COPY scripts/install-headless-chrome.sh /tmp/
RUN bash /tmp/install-headless-chrome.sh && rm -f /tmp/install-headless-chrome.sh
RUN if [ -f /opt/google/chrome/chrome-sandbox ]; then \
      chown root:root /opt/google/chrome/chrome-sandbox && \
      chmod 4755 /opt/google/chrome/chrome-sandbox; \
    fi
ENV CHROME_BIN=/usr/bin/google-chrome

USER developer

# ============================================================================================
# full — native + Android SDK + Chrome  (default target; historical "everything" image)
# ============================================================================================
FROM native AS full
USER root

# Android SDK
ENV ANDROID_SDK_ROOT=/sdk
COPY --from=android-dl /sdk /sdk
RUN chown -R developer:developer /sdk
ENV PATH=${PATH}:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/platform-tools

# Chrome
COPY scripts/install-headless-chrome.sh /tmp/
RUN bash /tmp/install-headless-chrome.sh && rm -f /tmp/install-headless-chrome.sh
RUN if [ -f /opt/google/chrome/chrome-sandbox ]; then \
      chown root:root /opt/google/chrome/chrome-sandbox && \
      chmod 4755 /opt/google/chrome/chrome-sandbox; \
    fi
ENV CHROME_BIN=/usr/bin/google-chrome

USER developer
