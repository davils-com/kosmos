#!/bin/bash

set -euo pipefail

echo "Installing CMake..."

apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    cmake \
    pkg-config \
    libsecret-1-dev

rm -rf /var/lib/apt/lists/*

echo "CMake installed successfully."
