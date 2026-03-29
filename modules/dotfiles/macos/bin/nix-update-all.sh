#!/usr/bin/env bash
# nix-update-all.sh — Update everything the Nix way:
#
#   1. Upgrade the Determinate Nix daemon (if installed)
#   2. Update all flake inputs (flake.lock)
#   3. darwin-rebuild switch (applies new system config + Homebrew upgrades)
#   4. Nix garbage collection
#
# NOTE: Homebrew formulae and casks are managed declaratively by nix-homebrew.
#       darwin-rebuild switch already runs `brew upgrade` via homebrew.nix
#       onActivation settings — do NOT run `brew upgrade` manually.
#
# Usage:
#   ~/bin/nix-update-all.sh
#   ~/bin/nix-update-all.sh --no-gc   (skip garbage collection)

set -euo pipefail

LOG_PREFIX="[nix-update-all]"
info() { echo "${LOG_PREFIX} $*"; }
warn() { echo "${LOG_PREFIX} WARNING: $*" >&2; }

NO_GC=false
for arg in "$@"; do
  case "$arg" in --no-gc) NO_GC=true ;; esac
done

NIX_CONFIG="${HOME}/.config/nix-darwin"
HOSTNAME="$(scutil --get LocalHostName 2>/dev/null || hostname -s)"

# ── 1. Determinate Nix daemon upgrade ─────────────────────────────────────────
if command -v determinate-nixd &>/dev/null; then
  info "Upgrading Determinate Nix daemon..."
  sudo determinate-nixd upgrade || warn "determinate-nixd upgrade failed (continuing)"
fi

# ── 2. Update all flake inputs → flake.lock ───────────────────────────────────
# This updates nixpkgs, home-manager, nix-darwin, homebrew taps, sops-nix, etc.
info "Updating flake inputs in ${NIX_CONFIG}..."
nix flake update --flake "${NIX_CONFIG}"

# ── 3. darwin-rebuild switch ──────────────────────────────────────────────────
# Applies updated Nix packages, macOS defaults, Home Manager dotfiles,
# AND runs brew update + brew upgrade (via homebrew.nix onActivation settings).
info "Applying configuration: darwin-rebuild switch --flake '${NIX_CONFIG}#${HOSTNAME}'..."
sudo -i darwin-rebuild switch --flake "${NIX_CONFIG}#${HOSTNAME}"

# ── 4. Nix garbage collection ─────────────────────────────────────────────────
if ! $NO_GC; then
  info "Collecting Nix garbage (removing generations older than 7 days)..."
  sudo nix-collect-garbage --delete-older-than 7d || warn "GC failed (non-fatal)"
  nix-collect-garbage     --delete-older-than 7d  || warn "GC failed (non-fatal)"
fi

info ""
info "All updates complete. Open a new terminal to pick up any shell changes."
