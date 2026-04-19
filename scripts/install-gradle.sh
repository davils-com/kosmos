#!/bin/bash

set -e

GRADLE_VERSION="$1"

echo "Installing Gradle ${GRADLE_VERSION} ..."
wget -P /tmp "https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip"
mkdir -p /opt/gradle
unzip -q "/tmp/gradle-${GRADLE_VERSION}-bin.zip" -d /opt/gradle
rm "/tmp/gradle-${GRADLE_VERSION}-bin.zip"
