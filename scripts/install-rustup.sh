#!/bin/bash

set -euo pipefail
echo "Installing Rustup and Rust toolchain ..."

apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    build-essential

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
rm -rf /var/lib/apt/lists/*
echo "Rustup installed successfully."
