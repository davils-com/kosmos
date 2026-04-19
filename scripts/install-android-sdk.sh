#!/bin/bash

set -e

CMDLINE_TOOLS_VERSION="$1"
ANDROID_SDK_VERSION="$2"
BUILD_TOOLS_VERSION="$3"
ANDROID_SDK_ROOT="$4"

echo "Installing Android SDK to ${ANDROID_SDK_ROOT}"
mkdir -p "${ANDROID_SDK_ROOT}" "${HOME}/.android"

echo "Downloading commandline tools ${CMDLINE_TOOLS_VERSION} ..."
wget -O /cmdline-tools.zip "https://dl.google.com/android/repository/commandlinetools-linux-${CMDLINE_TOOLS_VERSION}.zip"

mkdir -p "${ANDROID_SDK_ROOT}/cmdline-tools"
unzip -q /cmdline-tools.zip -d "${ANDROID_SDK_ROOT}/cmdline-tools"
rm /cmdline-tools.zip

mkdir -p "${ANDROID_SDK_ROOT}/cmdline-tools/latest"
if [ -d "${ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools" ]; then
  mv "${ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools"/* "${ANDROID_SDK_ROOT}/cmdline-tools/latest/" || true
fi

export ANDROID_SDK_ROOT
export PATH="${PATH}:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin"

echo "sdkmanager version:"
sdkmanager --version || true

yes | sdkmanager --sdk_root="${ANDROID_SDK_ROOT}" --licenses
sdkmanager --sdk_root="${ANDROID_SDK_ROOT}" \
  "platform-tools" \
  "platforms;android-${ANDROID_SDK_VERSION}" \
  "build-tools;${BUILD_TOOLS_VERSION}"
