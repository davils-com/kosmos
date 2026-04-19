#!/bin/bash

set -euo pipefail
echo "Installing Google Chrome (headless-capable) ..."

apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    gnupg \
    ca-certificates \
    apt-transport-https \
    fonts-liberation \
    libasound2 \
    libnss3 \
    xdg-utils

install -d -m 0755 /etc/apt/keyrings
wget -qO- https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor > /etc/apt/keyrings/google-linux-signing.gpg
chmod 0644 /etc/apt/keyrings/google-linux-signing.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/google-linux-signing.gpg] https://dl.google.com/linux/chrome/deb/ stable main" \
  > /etc/apt/sources.list.d/google-chrome.list

apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends google-chrome-stable

google-chrome --version
rm -rf /var/lib/apt/lists/*
