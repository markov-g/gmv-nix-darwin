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

# ── 1b. Check the pinned oh-my-opencode-slim plugin version ──────────────────
# This plugin is deliberately pinned (not "latest") in opencode.jsonc -- see
# the comment there for why. This check is the renewal reminder: it rides on
# a ritual you already run, so there's no separate habit to remember.
OPENCODE_JSONC="${HOME}/.config/opencode/opencode.jsonc"
if [ -f "${OPENCODE_JSONC}" ] && command -v curl &>/dev/null && command -v jq &>/dev/null; then
  PINNED="$(grep -o 'oh-my-opencode-slim@[0-9][0-9.]*' "${OPENCODE_JSONC}" | head -1 | cut -d@ -f2)"
  if [ -n "${PINNED}" ]; then
    LATEST="$(curl -fsSL --max-time 5 https://registry.npmjs.org/oh-my-opencode-slim 2>/dev/null | jq -r '."dist-tags".latest' 2>/dev/null || true)"
    if [ -n "${LATEST}" ] && [ "${LATEST}" != "${PINNED}" ]; then
      warn "oh-my-opencode-slim plugin pin is stale: pinned=${PINNED} latest=${LATEST}"
      warn "Review the changelog and schema diff, then bump both the plugin pin and \$schema in:"
      warn "  modules/dotfiles/macos/.config/opencode/opencode.jsonc"
      warn "  modules/dotfiles/macos/.config/opencode/oh-my-opencode-slim.jsonc"
    else
      info "oh-my-opencode-slim plugin pin is current (${PINNED})"
    fi
  fi
else
  info "Skipping oh-my-opencode-slim pin check (opencode.jsonc, curl, or jq unavailable)"
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
