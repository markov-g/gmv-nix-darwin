#!/usr/bin/env bash
# bootstrap-macos.sh — Master orchestrator for a fresh macOS setup.
#
# Run this ONCE on a brand-new machine (before Nix is installed):
#
#   1. Install Xcode Command Line Tools (required by Nix + git)
#   2. Clone this repo to ~/.config/nix-darwin  (if not already there)
#   3. Download + open the Determinate Nix DMG installer
#   4. After Nix is installed, bootstrap nix-darwin with:
#        sudo -i nix run github:LnL7/nix-darwin#darwin-rebuild -- switch \
#          --flake /Users/$USER/.config/nix-darwin#<hostname>
#   5. On subsequent runs: darwin-rebuild switch (now on PATH)
#   6. Print post-bootstrap checklist
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
if ! command -v nix &>/dev/null; then
  info "Nix not found — launching Determinate Nix installer..."
  bash "${BIN_DIR}/install-determinate-nix.sh"

  # Re-source nix profile in case the installer ran non-interactively
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
  info "Nix already installed: $(nix --version)"
fi

# ── 5. Apply nix-darwin configuration ────────────────────────────────────────
HOSTNAME="$(scutil --get LocalHostName 2>/dev/null || hostname -s)"
FLAKE_TARGET="${NIX_CONFIG_DIR}#${HOSTNAME}"

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

# ── 6. Post-bootstrap checklist ───────────────────────────────────────────────
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

  [ ] (Optional) Install MacPorts:
        ~/bin/install-macports.sh

  [ ] Clone development repos:
        ~/bin/clone-repos.sh

  [ ] Open a new terminal — full shell config takes effect from here.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
