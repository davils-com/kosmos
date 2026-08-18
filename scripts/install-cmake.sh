#!/usr/bin/env bash
#
# Installs the native build toolchain used by JNI / C-interop projects: a C/C++ compiler,
# CMake and the pkg-config + libsecret headers Kreate's native pipeline links against.
set -euo pipefail

echo "Installing native build toolchain (build-essential, CMake) ..."

apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    pkg-config \
    libsecret-1-dev

rm -rf /var/lib/apt/lists/*

echo "Native build toolchain installed successfully."
