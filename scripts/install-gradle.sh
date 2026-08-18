#!/usr/bin/env bash
#
# Installs a fixed Gradle version into /opt/gradle. Runs in a throwaway builder stage; only
# /opt/gradle is copied into the final image, so nothing else here affects image size.
set -euo pipefail

GRADLE_VERSION="${1:?gradle version required}"

echo "Installing Gradle ${GRADLE_VERSION} ..."
tmp="$(mktemp -d)"
trap 'rm -rf "${tmp}"' EXIT

wget -q -O "${tmp}/gradle.zip" \
  "https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip"

mkdir -p /opt/gradle
unzip -q "${tmp}/gradle.zip" -d /opt/gradle

echo "Gradle ${GRADLE_VERSION} installed to /opt/gradle."
