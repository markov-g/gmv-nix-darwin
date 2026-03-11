#!/usr/bin/env bash
# install-macports.sh — Download and install the latest MacPorts .pkg for the
# running macOS version from the command line (no GUI needed).
#
# MacPorts cannot be managed declaratively through Nix like Homebrew; it must
# be installed imperatively. Once installed, opt-in via ~/.profile.macports.
#
# Usage:  ~/bin/install-macports.sh

set -euo pipefail

LOG_PREFIX="[install-macports]"
info()  { echo "${LOG_PREFIX} $*"; }
fatal() { echo "${LOG_PREFIX} FATAL: $*" >&2; exit 1; }

[[ "$(uname)" == "Darwin" ]] || fatal "macOS only."

# Check if MacPorts is already installed — either on PATH or at the well-known location
if command -v port &>/dev/null; then
  info "MacPorts already installed: $(port version)"
  exit 0
elif [[ -x "/opt/local/bin/port" ]]; then
  info "MacPorts is already installed (/opt/local/bin/port exists). Activate it with:"
  info "  source ~/.profile.macports"
  exit 0
fi

# ── Detect macOS version ──────────────────────────────────────────────────────
MACOS_VERSION="$(sw_vers -productVersion)"
MACOS_MAJOR="$(echo "${MACOS_VERSION}" | cut -d. -f1)"

case "${MACOS_MAJOR}" in
  26) MACOS_NAME="Tahoe"    ;;
  15) MACOS_NAME="Sequoia"  ;;
  14) MACOS_NAME="Sonoma"   ;;
  13) MACOS_NAME="Ventura"  ;;
  12) MACOS_NAME="Monterey" ;;
  11) MACOS_NAME="BigSur"   ;;
  *)  fatal "Unsupported macOS ${MACOS_VERSION}" ;;
esac

info "Detected macOS ${MACOS_MAJOR} (${MACOS_NAME})"

# ── Fetch latest release from GitHub ─────────────────────────────────────────
info "Fetching latest MacPorts release info..."
RELEASE_JSON="$(curl -fsSL "https://api.github.com/repos/macports/macports-base/releases/latest")"

VERSION="$(echo "${RELEASE_JSON}" | grep '"tag_name"' | head -1 | sed 's/.*"v\([^"]*\)".*/\1/')"
[[ -n "${VERSION}" ]] || fatal "Could not determine latest MacPorts version from GitHub API."
info "Latest version: ${VERSION}"

# ── Build download URL ────────────────────────────────────────────────────────
# Format: MacPorts-2.9.3-15-Sequoia.pkg
PKG_NAME="MacPorts-${VERSION}-${MACOS_MAJOR}-${MACOS_NAME}.pkg"
DOWNLOAD_URL="https://github.com/macports/macports-base/releases/download/v${VERSION}/${PKG_NAME}"
DEST="${HOME}/Downloads/${PKG_NAME}"

# ── Download ──────────────────────────────────────────────────────────────────
if [[ -f "${DEST}" ]]; then
  info "Already downloaded: ${DEST}"
else
  info "Downloading ${PKG_NAME}..."
  curl -fL --progress-bar "${DOWNLOAD_URL}" -o "${DEST}" || \
    fatal "Download failed. Verify: ${DOWNLOAD_URL}"
fi

# ── Install from command line ─────────────────────────────────────────────────
info "Installing ${PKG_NAME} (will prompt for sudo password)..."
sudo installer -pkg "${DEST}" -target /

cat <<'EOF'

MacPorts installed. Opt in by running:
  source ~/.profile.macports

Or make it persistent (e.g. for a dedicated MacPorts shell) by adding to ~/.zprofile.local:
  [ -f ~/.profile.macports ] && source ~/.profile.macports
EOF
