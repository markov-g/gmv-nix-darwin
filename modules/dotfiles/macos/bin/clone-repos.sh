#!/usr/bin/env bash
# clone-repos.sh — Clone development repositories to ~/git-repos/.
#
# Prerequisite SSH keys (from ~/.ssh/config):
#   ~/.ssh/id_ed25519            — used for github.com  (default key)
#   ~/.ssh/id_rsa_code_siemens_com — used for code.siemens.com
#
# This script checks that the required keys exist before attempting clones.
#
# Usage:
#   ~/bin/clone-repos.sh
#
# Customise the repo lists in the sections below, or set env vars:
#   GITHUB_USER=<your-github-handle>
#   SIEMENS_USER=<your-siemens-username>

set -euo pipefail

LOG_PREFIX="[clone-repos]"
info()  { echo "${LOG_PREFIX} $*"; }
warn()  { echo "${LOG_PREFIX} WARNING: $*" >&2; }
fatal() { echo "${LOG_PREFIX} FATAL: $*" >&2; exit 1; }

GITHUB_USER="${GITHUB_USER:-r1pp3r}"
SIEMENS_USER="${SIEMENS_USER:-}"

GITHUB_BASE="${HOME}/git-repos/github.com"
SIEMENS_BASE="${HOME}/git-repos/code.siemens.com"

# ── SSH key checks ────────────────────────────────────────────────────────────
check_ssh_key() {
  local keyfile="$1"
  local label="$2"
  if [[ ! -f "${keyfile}" ]]; then
    warn "SSH key not found: ${keyfile} (needed for ${label})"
    return 1
  fi
  if [[ "$(stat -f '%A' "${keyfile}")" != "600" ]]; then
    warn "SSH key has wrong permissions: ${keyfile} — fixing to 0600"
    chmod 600 "${keyfile}"
  fi
  return 0
}

HAS_GITHUB_KEY=true
HAS_SIEMENS_KEY=true

check_ssh_key "${HOME}/.ssh/id_ed25519"              "github.com"       || HAS_GITHUB_KEY=false
check_ssh_key "${HOME}/.ssh/id_rsa_code_siemens_com" "code.siemens.com" || HAS_SIEMENS_KEY=false

# ── Test SSH connectivity ─────────────────────────────────────────────────────
test_ssh() {
  local host="$1"
  # ssh exits 1 with "successfully authenticated" for GitHub/GitLab; 255 = real failure
  if ! ssh -o BatchMode=yes -o ConnectTimeout=8 -T "${host}" 2>&1 | grep -qiE "successfully authenticated|Welcome"; then
    # Some hosts return non-zero even on success; check stderr for the success message
    local output
    output="$(ssh -o BatchMode=yes -o ConnectTimeout=8 -T "${host}" 2>&1)" || true
    echo "${output}" | grep -qiE "successfully authenticated|Welcome|Hi " && return 0
    return 1
  fi
}

if $HAS_GITHUB_KEY; then
  if ! test_ssh "git@github.com" 2>/dev/null; then
    warn "Cannot authenticate to github.com with ~/.ssh/id_ed25519"
    warn "Ensure your public key is added to https://github.com/settings/keys"
    HAS_GITHUB_KEY=false
  fi
fi

# ── Clone helper ──────────────────────────────────────────────────────────────
clone_or_pull() {
  local url="$1"
  local dest="$2"

  if [[ -d "${dest}/.git" ]]; then
    info "Already cloned: ${dest} — fetching latest..."
    git -C "${dest}" fetch --all --prune 2>/dev/null || warn "Fetch failed for ${dest} (skipping)"
    git -C "${dest}" pull --ff-only 2>/dev/null || warn "Pull failed (non-fast-forward) for ${dest}"
  else
    info "Cloning ${url}"
    info "  → ${dest}"
    mkdir -p "$(dirname "${dest}")"
    git clone --depth=50 "${url}" "${dest}" || warn "Clone failed for ${url} (skipping)"
  fi
}

# ── 1. This config repo ───────────────────────────────────────────────────────
NIX_CONFIG="${HOME}/.config/nix-darwin"
if [[ ! -d "${NIX_CONFIG}/.git" ]]; then
  if $HAS_GITHUB_KEY; then
    clone_or_pull "git@github.com:${GITHUB_USER}/nix-darwin.git" "${NIX_CONFIG}"
  else
    warn "Skipping nix-darwin config clone (no GitHub SSH key)"
  fi
else
  info "nix-darwin config already present at ${NIX_CONFIG}"
fi

# ── 2. GitHub repos ───────────────────────────────────────────────────────────
# Add repos in the form "org/repo" — cloned to ~/git-repos/github.com/org/repo
GITHUB_REPOS=(
  "${GITHUB_USER}/nix-darwin"
  # "${GITHUB_USER}/dotfiles"
  # "some-org/some-repo"
)

if $HAS_GITHUB_KEY; then
  for repo in "${GITHUB_REPOS[@]}"; do
    dest="${GITHUB_BASE}/${repo}"
    clone_or_pull "git@github.com:${repo}.git" "${dest}"
  done
else
  warn "Skipping GitHub repos (no valid SSH key / connectivity)"
fi

# ── 3. code.siemens.com repos ─────────────────────────────────────────────────
# Uses ~/.ssh/id_rsa_code_siemens_com (via Host entry in ~/.ssh/config)
# Add repos in the form "group/subgroup/repo"
SIEMENS_REPOS=(
  # Fill in your project paths, e.g.:
  # "myteam/myproject"
  # "myteam/another-repo"
)

if [[ ${#SIEMENS_REPOS[@]} -gt 0 ]]; then
  if ! $HAS_SIEMENS_KEY; then
    warn "Skipping code.siemens.com repos — ~/.ssh/id_rsa_code_siemens_com not found"
    warn "Generate it: ssh-keygen -t ed25519 -f ~/.ssh/id_rsa_code_siemens_com -C 'code.siemens.com'"
    warn "Then add the public key to your code.siemens.com profile."
  elif [[ -z "${SIEMENS_USER}" ]]; then
    warn "SIEMENS_USER is not set. Skipping code.siemens.com repos."
    warn "Re-run with: SIEMENS_USER=your.username ~/bin/clone-repos.sh"
  else
    for repo in "${SIEMENS_REPOS[@]}"; do
      dest="${SIEMENS_BASE}/${repo}"
      # Uses the 'code.siemens.com' Host alias from ~/.ssh/config
      clone_or_pull "git@code.siemens.com:${repo}.git" "${dest}"
    done
  fi
fi

# ── Summary ───────────────────────────────────────────────────────────────────
info ""
info "Done. Repos are in ${HOME}/git-repos/"
