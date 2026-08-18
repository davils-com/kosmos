#!/usr/bin/env bash
#
# Installs rustup + the stable toolchain with the minimal profile. Runs in a throwaway builder
# stage; only $RUSTUP_HOME and $CARGO_HOME are copied into the final image. The C toolchain
# (build-essential) that Rust needs for linking is installed in the consuming stage, not here.
set -euo pipefail

export RUSTUP_HOME="${RUSTUP_HOME:-/usr/local/rustup}"
export CARGO_HOME="${CARGO_HOME:-/usr/local/cargo}"

echo "Installing rustup + stable toolchain (minimal profile) ..."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \
  | sh -s -- -y --no-modify-path --profile minimal --default-toolchain stable

rm -rf "${RUSTUP_HOME}"/toolchains/*/share/doc 2>/dev/null || true
chmod -R a+rX "${RUSTUP_HOME}" "${CARGO_HOME}"

echo "rustup installed successfully."
