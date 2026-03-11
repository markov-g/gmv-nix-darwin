#!/usr/bin/env bash
# install-determinate-nix.sh — Download and install the Determinate Nix macOS
# .pkg from the command line (no GUI needed).
#
# Determinate Nix is a reliable, production-grade Nix distribution for macOS:
# https://determinate.systems/nix
#
# The .pkg is a Universal binary (works on both Apple Silicon and Intel).
# Download URL: https://install.determinate.systems/determinate-pkg/stable/Universal
#
# Usage:  ~/bin/install-determinate-nix.sh

set -euo pipefail

LOG_PREFIX="[install-nix]"
info()  { echo "${LOG_PREFIX} $*"; }
fatal() { echo "${LOG_PREFIX} FATAL: $*" >&2; exit 1; }

[[ "$(uname)" == "Darwin" ]] || fatal "macOS only."

# Check if Nix is already installed — either on PATH or at the well-known location
if command -v nix &>/dev/null; then
  info "Nix is already installed: $(nix --version)"
  exit 0
elif [[ -d "/nix/store" ]]; then
  info "Nix is already installed (/nix/store exists). Source the daemon profile to use it:"
  info "  source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
  exit 0
fi

# ── Download the Universal .pkg from Determinate Systems ─────────────────────
DOWNLOAD_URL="https://install.determinate.systems/determinate-pkg/stable/Universal"
DEST="${HOME}/Downloads/Determinate-Nix.pkg"

if [[ -f "${DEST}" ]]; then
  info "Already downloaded: ${DEST}"
else
  info "Downloading Determinate Nix .pkg installer..."
  curl -fL --progress-bar "${DOWNLOAD_URL}" -o "${DEST}"
fi

# ── Install from command line ─────────────────────────────────────────────────
info "Installing ${DEST} (will prompt for sudo password)..."
sudo installer -pkg "${DEST}" -target /
