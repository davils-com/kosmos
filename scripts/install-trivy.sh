#!/bin/bash

set -euo pipefail
echo "Installing Trivy ..."

apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    wget   \
    gnupg \
    apt-transport-https

wget -qO - https://get.trivy.dev/deb/public.key \
    | gpg --dearmor \
    | tee /usr/share/keyrings/trivy.gpg > /dev/null

echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://get.trivy.dev/deb generic main" \
    > /etc/apt/sources.list.d/trivy.list

apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends trivy

rm -rf /var/lib/apt/lists/*
echo "Trivy installed successfully."
