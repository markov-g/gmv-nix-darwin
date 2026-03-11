#!/usr/bin/env bash
# bootstrap-macos.sh — Master orchestrator for a fresh macOS setup.
#
# Run this ONCE on a brand-new machine (before Nix is installed):
#
#   1. Install Xcode Command Line Tools (required by Nix + git)
#   2. Clone this repo to ~/.config/nix-darwin  (if not already there)
#   3. Seed .zshenv (writable — needed by ServBay + other tools)
#   4. Install Determinate Nix (.pkg, headless)
#   5. Apply nix-darwin configuration (interactive — asks before running)
#   6. Install MacPorts (.pkg, headless)
#   7. Optionally install ServBay (local dev environment)
#   8. Print post-bootstrap checklist
#
# Usage (copy/paste into a fresh Terminal):
#   bash ~/.config/nix-darwin/modules/dotfiles/macos/bin/bootstrap-macos.sh
#
# Or, if the repo is not yet cloned, pipe from a raw git URL:
#   bash <(curl -fsSL https://raw.githubusercontent.com/r1pp3r/nix-darwin/main/modules/dotfiles/macos/bin/bootstrap-macos.sh)

set -euo pipefail

REPO_URL="${REPO_URL:-git@github.com:r1pp3r/nix-darwin.git}"
NIX_CONFIG_DIR="${HOME}/.config/nix-darwin"
BIN_DIR="${NIX_CONFIG_DIR}/modules/dotfiles/macos/bin"
LOG_PREFIX="[bootstrap]"

info()  { echo "${LOG_PREFIX} $*"; }
warn()  { echo "${LOG_PREFIX} WARNING: $*" >&2; }
fatal() { echo "${LOG_PREFIX} FATAL: $*" >&2; exit 1; }

# ask "question" — returns 0 (yes) or 1 (no)
ask() {
  local reply
  echo ""
  read -rp "${LOG_PREFIX} $1 [y/N] " reply
  [[ "${reply}" =~ ^[Yy] ]]
}

[[ "$(uname)" == "Darwin" ]] || fatal "This script is macOS-only."

# ── 1. Xcode Command Line Tools ───────────────────────────────────────────────
if ! xcode-select -p &>/dev/null; then
  info "Installing Xcode Command Line Tools..."
  xcode-select --install
  echo ""
  echo "  A dialog should have appeared. Complete the CLT installation,"
  echo "  then re-run this script."
  exit 0
else
  info "Xcode CLT already installed: $(xcode-select -p)"
fi

# ── 2. Clone config repo ──────────────────────────────────────────────────────
if [[ ! -d "${NIX_CONFIG_DIR}/.git" ]]; then
  info "Cloning nix-darwin config to ${NIX_CONFIG_DIR}..."
  mkdir -p "$(dirname "${NIX_CONFIG_DIR}")"
  git clone "${REPO_URL}" "${NIX_CONFIG_DIR}"
else
  info "Repo already present at ${NIX_CONFIG_DIR}"
fi

# ── 3. Seed .zshenv (writable — needed by ServBay + other tools) ──────────────
ZSHENV="${HOME}/.zshenv"
SEED="${NIX_CONFIG_DIR}/modules/dotfiles/macos/.zshenv.seed"
if [[ ! -f "${ZSHENV}" && -f "${SEED}" ]]; then
  info "Seeding ${ZSHENV} from .zshenv.seed..."
  cp "${SEED}" "${ZSHENV}"
fi

# ── 4. Install Determinate Nix ───────────────────────────────────────────────
if ! command -v nix &>/dev/null && ! [[ -d "/nix/store" ]]; then
  info "Nix not found — installing Determinate Nix..."
  bash "${BIN_DIR}/install-determinate-nix.sh"

  # Re-source nix profile so nix is on PATH for the rest of this script
  NIX_PROFILE="/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
  [[ -f "${NIX_PROFILE}" ]] && source "${NIX_PROFILE}"

  if ! command -v nix &>/dev/null; then
    echo ""
    echo "  Nix was installed but is not yet on PATH."
    echo "  Open a NEW terminal, then re-run:"
    echo "    bash ${NIX_CONFIG_DIR}/modules/dotfiles/macos/bin/bootstrap-macos.sh"
    exit 0
  fi
else
  # Nix exists but might not be on PATH — try sourcing
  if ! command -v nix &>/dev/null; then
    NIX_PROFILE="/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
    [[ -f "${NIX_PROFILE}" ]] && source "${NIX_PROFILE}"
  fi
  info "Nix already installed: $(nix --version)"
fi

# ── 5. Apply nix-darwin configuration ────────────────────────────────────────
HOSTNAME="$(scutil --get LocalHostName 2>/dev/null || hostname -s)"
FLAKE_TARGET="${NIX_CONFIG_DIR}#${HOSTNAME}"

if ask "Apply nix-darwin configuration for '${HOSTNAME}'? (This installs all packages, dotfiles, Homebrew casks)"; then
  if command -v darwin-rebuild &>/dev/null; then
    # darwin-rebuild is already on PATH (subsequent runs)
    info "Running: darwin-rebuild switch --flake '${FLAKE_TARGET}'"
    darwin-rebuild switch --flake "${FLAKE_TARGET}"
  else
    # First bootstrap: darwin-rebuild not yet installed — use nix run to bootstrap
    info "First-time bootstrap: using nix run to install nix-darwin..."
    info "Running: sudo -i nix run github:LnL7/nix-darwin#darwin-rebuild -- switch --flake '${FLAKE_TARGET}'"
    sudo -i nix run github:LnL7/nix-darwin#darwin-rebuild -- switch --flake "${FLAKE_TARGET}"
  fi
else
  info "Skipped nix-darwin. Apply manually when ready:"
  if command -v darwin-rebuild &>/dev/null; then
    info "  darwin-rebuild switch --flake '${FLAKE_TARGET}'"
  else
    info "  sudo -i nix run github:LnL7/nix-darwin#darwin-rebuild -- switch --flake '${FLAKE_TARGET}'"
  fi
fi

# ── 6. Install MacPorts ──────────────────────────────────────────────────────
if ! command -v port &>/dev/null && ! [[ -x "/opt/local/bin/port" ]]; then
  if ask "Install MacPorts?"; then
    bash "${BIN_DIR}/install-macports.sh"
  else
    info "Skipped MacPorts. Install later with: ~/bin/install-macports.sh"
  fi
else
  info "MacPorts already installed."
fi

# ── 7. Install ServBay (optional — local dev environment) ────────────────────
SERVBAY_APP="/Applications/ServBay.app"
if [[ ! -d "${SERVBAY_APP}" ]]; then
  if ask "Install ServBay (local dev environment — PHP, MySQL, Redis, Node, etc.)?"; then
    SERVBAY_URL="https://dl.servbay.com/release/latest/ServBayInstaller.dmg"
    SERVBAY_DMG="${HOME}/Downloads/ServBayInstaller.dmg"

    if [[ ! -f "${SERVBAY_DMG}" ]]; then
      info "Downloading ServBay..."
      curl -fL --progress-bar "${SERVBAY_URL}" -o "${SERVBAY_DMG}"
    else
      info "Already downloaded: ${SERVBAY_DMG}"
    fi

    info "Mounting ServBay DMG..."
    MOUNT_POINT="$(hdiutil attach "${SERVBAY_DMG}" -nobrowse -readonly | grep '/Volumes/' | awk -F'\t' '{print $NF}')"

    SERVBAY_PKG="$(find "${MOUNT_POINT}" -maxdepth 1 -name '*.pkg' -print -quit 2>/dev/null)"
    SERVBAY_APPDIR="$(find "${MOUNT_POINT}" -maxdepth 1 -name '*.app' -print -quit 2>/dev/null)"

    if [[ -n "${SERVBAY_PKG}" ]]; then
      info "Installing ServBay via pkg..."
      sudo installer -pkg "${SERVBAY_PKG}" -target /
    elif [[ -n "${SERVBAY_APPDIR}" ]]; then
      info "Copying ServBay.app to /Applications..."
      cp -R "${SERVBAY_APPDIR}" /Applications/
    else
      warn "Could not find .pkg or .app inside DMG. Open it manually:"
      warn "  open ${SERVBAY_DMG}"
    fi

    hdiutil detach "${MOUNT_POINT}" -quiet 2>/dev/null || true
    info "ServBay installed."
  else
    info "Skipped ServBay."
  fi
else
  info "ServBay already installed."
fi

# ── 8. Post-bootstrap checklist ───────────────────────────────────────────────
cat <<EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  POST-BOOTSTRAP CHECKLIST
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  [ ] Generate age key from your SSH key (enables sops-nix secrets):
        mkdir -p ~/.config/sops/age
        ssh-to-age -private-key -i ~/.ssh/id_ed25519 \\
          > ~/.config/sops/age/keys.txt

  [ ] Create / decrypt secrets file:
        cd ${NIX_CONFIG_DIR}
        sops secrets/secrets.yaml
      Then re-apply to decrypt secrets into place:
        sudo -i nix run github:LnL7/nix-darwin#darwin-rebuild -- switch \\
          --flake ${NIX_CONFIG_DIR}#${HOSTNAME}

  [ ] Configure powerlevel10k theme:
        p10k configure
        cp ~/.p10k.zsh ${NIX_CONFIG_DIR}/modules/dotfiles/macos/.p10k.zsh

  [ ] Clone development repos:
        ~/bin/clone-repos.sh

  [ ] Open a new terminal — full shell config takes effect from here.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
