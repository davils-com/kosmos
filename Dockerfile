FROM eclipse-temurin:17-jdk-jammy

ARG CMDLINE_TOOLS_VERSION=14742923_latest
ARG ANDROID_SDK_VERSION=36
ARG BUILD_TOOLS_VERSION=35.0.1
ARG GRADLE_VERSION=9.6.0

ARG USER_NAME=developer
ARG USER_UID=1000
ARG USER_GID=1000

RUN groupadd -g ${USER_GID} ${USER_NAME} && \
    useradd -m -u ${USER_UID} -g ${USER_GID} -s /bin/bash ${USER_NAME}

ENV ANDROID_SDK_ROOT=/sdk
ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo
ENV PATH=${PATH}:${CARGO_HOME}/bin

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        wget unzip tar ca-certificates libatomic1 build-essential \
        gnupg apt-transport-https fonts-liberation libasound2 libnss3 xdg-utils curl && \
    rm -rf /var/lib/apt/lists/*

COPY scripts/install-android-sdk.sh /install-android-sdk.sh
COPY scripts/install-cmake.sh /install-cmake.sh
COPY scripts/install-gradle.sh /install-gradle.sh
COPY scripts/install-headless-chrome.sh /install-headless-chrome.sh
COPY scripts/install-rustup.sh /install-rustup.sh
COPY scripts/install-trivy.sh /install-trivy.sh
RUN chmod +x /install-android-sdk.sh /install-cmake.sh /install-gradle.sh /install-headless-chrome.sh /install-rustup.sh /install-trivy.sh && \
    /install-android-sdk.sh "${CMDLINE_TOOLS_VERSION}" "${ANDROID_SDK_VERSION}" "${BUILD_TOOLS_VERSION}" "${ANDROID_SDK_ROOT}" && \
    /install-cmake.sh && \
    /install-gradle.sh "${GRADLE_VERSION}" && \
    /install-headless-chrome.sh && \
    /install-rustup.sh && \
    /install-trivy.sh && \
    mkdir -p /app ${CARGO_HOME} ${RUSTUP_HOME} && \
    chown -R ${USER_NAME}:${USER_NAME} /app ${ANDROID_SDK_ROOT} /opt/gradle ${CARGO_HOME} ${RUSTUP_HOME} && \
    rm /install-android-sdk.sh /install-cmake.sh /install-gradle.sh /install-headless-chrome.sh /install-rustup.sh /install-trivy.sh && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN if [ -f /opt/google/chrome/chrome-sandbox ]; then \
      chown root:root /opt/google/chrome/chrome-sandbox && \
      chmod 4755 /opt/google/chrome/chrome-sandbox; \
    fi

ENV GRADLE_HOME=/opt/gradle/gradle-${GRADLE_VERSION}
ENV CHROME_BIN=/usr/bin/google-chrome
ENV PATH=${PATH}:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/platform-tools:${GRADLE_HOME}/bin

WORKDIR /app
USER ${USER_NAME}
CMD ["bash"]
