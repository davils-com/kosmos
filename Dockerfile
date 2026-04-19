FROM eclipse-temurin:25-jdk-jammy

ARG CMDLINE_TOOLS_VERSION=13114758_latest
ARG ANDROID_SDK_VERSION=36
ARG BUILD_TOOLS_VERSION=35.0.1
ARG GRADLE_VERSION=9.4.1

ARG USER_NAME=developer
ARG USER_UID=1000
ARG USER_GID=1000

ENV ANDROID_SDK_ROOT=/sdk
ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo
ENV PATH=${PATH}:${CARGO_HOME}/bin

RUN apt-get update && \
    apt-get install -y wget unzip tar ca-certificates libatomic1 && \
    rm -rf /var/lib/apt/lists/*

COPY scripts/install-android-sdk.sh /install-android-sdk.sh
COPY scripts/install-gradle.sh /install-gradle.sh
COPY scripts/install-headless-chrome.sh /install-headless-chrome.sh
COPY scripts/install-rustup.sh /install-rustup.sh
RUN chmod +x /install-android-sdk.sh /install-gradle.sh /install-headless-chrome.sh /install-rustup.sh

RUN /install-android-sdk.sh "${CMDLINE_TOOLS_VERSION}" "${ANDROID_SDK_VERSION}" "${BUILD_TOOLS_VERSION}" "${ANDROID_SDK_ROOT}"
RUN /install-gradle.sh "${GRADLE_VERSION}"
RUN /install-headless-chrome.sh
RUN /install-rustup.sh

RUN if [ -f /opt/google/chrome/chrome-sandbox ]; then \
      chown root:root /opt/google/chrome/chrome-sandbox && \
      chmod 4755 /opt/google/chrome/chrome-sandbox; \
    fi

RUN groupadd -g ${USER_GID} ${USER_NAME} && \
    useradd -m -u ${USER_UID} -g ${USER_GID} -s /bin/bash ${USER_NAME}

RUN mkdir -p /app ${CARGO_HOME} ${RUSTUP_HOME} && \
    chown -R ${USER_NAME}:${USER_NAME} /app ${ANDROID_SDK_ROOT} /opt/gradle ${CARGO_HOME} ${RUSTUP_HOME} || true

ENV GRADLE_HOME=/opt/gradle/gradle-${GRADLE_VERSION}
ENV CHROME_BIN=/usr/bin/google-chrome
ENV PATH=${PATH}:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/platform-tools:${GRADLE_HOME}/bin

WORKDIR /app
USER ${USER_NAME}
CMD ["bash"]
