#!/usr/bin/env bash
# install-determinate-nix.sh — Download the latest Determinate Nix macOS DMG
# and open it so you can complete the GUI installation.
#
# Determinate Nix is a reliable, production-grade Nix distribution for macOS:
# https://determinate.systems/nix
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

# ── Fetch latest release from GitHub ─────────────────────────────────────────
info "Fetching latest Determinate Nix release info..."
RELEASE_JSON="$(curl -fsSL "https://api.github.com/repos/DeterminateSystems/nix-installer/releases/latest")"

VERSION="$(echo "${RELEASE_JSON}" | grep '"tag_name"' | head -1 | sed 's/.*"tag_name": *"\([^"]*\)".*/\1/')"
[[ -n "${VERSION}" ]] || fatal "Could not determine latest version from GitHub API."
info "Latest version: ${VERSION}"

# ── Find the macOS DMG asset ──────────────────────────────────────────────────
# Asset name pattern: nix-installer-<version>-x86_64-apple-darwin.dmg
# or: nix-installer-aarch64-apple-darwin.dmg  (Apple Silicon)
ARCH="$(uname -m)"   # arm64 on Apple Silicon
case "${ARCH}" in
  arm64)  ASSET_ARCH="aarch64-apple-darwin" ;;
  x86_64) ASSET_ARCH="x86_64-apple-darwin" ;;
  *)      fatal "Unknown architecture: ${ARCH}" ;;
esac

# Try to find a .dmg or .pkg asset for this platform in the release
DOWNLOAD_URL="$(echo "${RELEASE_JSON}" \
  | grep '"browser_download_url"' \
  | grep "${ASSET_ARCH}" \
  | grep -E '\.(dmg|pkg)"' \
  | head -1 \
  | sed 's/.*"browser_download_url": *"\([^"]*\)".*/\1/')"

# Fallback: universal .dmg
if [[ -z "${DOWNLOAD_URL}" ]]; then
  DOWNLOAD_URL="$(echo "${RELEASE_JSON}" \
    | grep '"browser_download_url"' \
    | grep -E '\.(dmg|pkg)"' \
    | head -1 \
    | sed 's/.*"browser_download_url": *"\([^"]*\)".*/\1/')"
fi

[[ -n "${DOWNLOAD_URL}" ]] || fatal "No DMG/PKG asset found for ${ASSET_ARCH} in release ${VERSION}.
Check: https://github.com/DeterminateSystems/nix-installer/releases"

FILENAME="$(basename "${DOWNLOAD_URL}")"
DEST="${HOME}/Downloads/${FILENAME}"

# ── Download ──────────────────────────────────────────────────────────────────
if [[ -f "${DEST}" ]]; then
  info "Already downloaded: ${DEST}"
else
  info "Downloading ${FILENAME}..."
  curl -fL --progress-bar "${DOWNLOAD_URL}" -o "${DEST}"
fi

# ── Open for installation ─────────────────────────────────────────────────────
info "Opening ${DEST} ..."
info "Complete the installer, then return here and re-run bootstrap-macos.sh"
open "${DEST}"
