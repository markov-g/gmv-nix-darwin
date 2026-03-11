#!/usr/bin/env bash
# install-determinate-nix.sh — Download the Determinate Nix macOS .pkg installer
# and open it for GUI installation.
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

if command -v nix &>/dev/null; then
  info "Nix is already installed: $(nix --version)"
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

# ── Open for installation ─────────────────────────────────────────────────────
info "Opening ${DEST} ..."
info "Complete the installer, then return here and re-run bootstrap-macos.sh"
open "${DEST}"
