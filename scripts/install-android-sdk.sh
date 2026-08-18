#!/usr/bin/env bash
#
# Installs the Android SDK (command-line tools, platform-tools, one platform, one build-tools)
# into $ANDROID_SDK_ROOT. Runs in a throwaway builder stage; only $ANDROID_SDK_ROOT is copied
# into the final image. Deliberately does NOT use `set -o pipefail`: the `yes | sdkmanager`
# licence pipe exits via SIGPIPE, which pipefail would turn into a spurious failure.
set -eu

CMDLINE_TOOLS_VERSION="$1"
ANDROID_SDK_VERSION="$2"
BUILD_TOOLS_VERSION="$3"
ANDROID_SDK_ROOT="$4"

echo "Installing Android SDK to ${ANDROID_SDK_ROOT}"
mkdir -p "${ANDROID_SDK_ROOT}" "${HOME}/.android"

echo "Downloading commandline tools ${CMDLINE_TOOLS_VERSION} ..."
wget -q -O /tmp/cmdline-tools.zip \
  "https://dl.google.com/android/repository/commandlinetools-linux-${CMDLINE_TOOLS_VERSION}.zip"

mkdir -p "${ANDROID_SDK_ROOT}/cmdline-tools"
unzip -q /tmp/cmdline-tools.zip -d "${ANDROID_SDK_ROOT}/cmdline-tools"
rm -f /tmp/cmdline-tools.zip

mkdir -p "${ANDROID_SDK_ROOT}/cmdline-tools/latest"
if [ -d "${ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools" ]; then
  mv "${ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools"/* "${ANDROID_SDK_ROOT}/cmdline-tools/latest/" || true
  rmdir "${ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools" || true
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
rm -rf \
  "${ANDROID_SDK_ROOT}/.downloadIntermediates" \
  "${ANDROID_SDK_ROOT}/.temp" \
  "${HOME}/.android/cache" 2>/dev/null || true

echo "Android SDK installed successfully."
