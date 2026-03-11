##############################################################################
# ~/.zprofile — login shell setup
#
# PACKAGE MANAGER ISOLATION POLICY
# ─────────────────────────────────
# This file sets up the BASE environment: system PATH + Nix tools only.
# Homebrew/MacPorts/Fink/pkgsrc binaries are NOT in PATH by default.
# Activate a package manager for the current session by sourcing explicitly:
#
#   source ~/.profile.homebrew   → Homebrew + NVM + jenv + conda + SDKMAN
#   source ~/.profile.macports   → MacPorts
#   source ~/.profile.fink       → Fink
#   source ~/.profile.pkgsrc     → pkgsrc
#   source ~/.profile.portage    → Gentoo Portage
#   source ~/.profile.kubectl    → helm + eksctl completions
##############################################################################

# ── 0. Locale — must be UTF-8 for Nerd Fonts / wide Unicode in tmux ──────────
# macOS GUI sessions set this automatically; SSH sessions often don't.
export LANG="${LANG:-en_US.UTF-8}"
export LC_ALL="${LC_ALL:-en_US.UTF-8}"

# ── 1. System PATH (reads /etc/paths + /etc/paths.d/ — includes Nix via /etc/paths.d/nix)
[[ -x /usr/libexec/path_helper ]] && eval $(/usr/libexec/path_helper -s)

# ── 2. BREW_PREFIX — variable only, NOT added to PATH here ───────────────────
# Reference for scripts. PATH additions happen only in ~/.profile.homebrew.
export BREW_PREFIX="${HOME}/PACKAGEMGMT/Homebrew"

# ── 3. User identity ──────────────────────────────────────────────────────────
export DEVEL_FULL_NAME="Georgi Markov"
export DEVEL_EMAIL=georgi.markov@siemens.com
export DEVEL_USER_NAME=gmarkov
export NAS_DEVENV=/Volumes/Mobility\ PTC\ BOS/devenv

# ── 4. ~/bin (personal scripts) ───────────────────────────────────────────────
export PATH="${HOME}/bin:${PATH}"

# ── 5. pipx tools ─────────────────────────────────────────────────────────────
export PATH="${PATH}:${HOME}/.local/bin"

# ── 6. JetBrains Toolbox scripts ──────────────────────────────────────────────
export PATH="${PATH}:${HOME}/Library/Application Support/JetBrains/Toolbox/scripts"

# ── 7. Docker CLI plugins ─────────────────────────────────────────────────────
export PATH="${PATH}:${HOME}/.docker/bin"

# ── 8. Mojo / Modular (if installed) ─────────────────────────────────────────
export MODULAR_HOME="${HOME}/.modular"
export PATH="${MODULAR_HOME}/pkg/packages.modular.com_mojo/bin:${PATH}"

# ── 9. Rust / Cargo ───────────────────────────────────────────────────────────
# Also set in ~/.zshenv (seed template) for non-login/non-interactive contexts.
export RUSTUP_HOME="${HOME}/.rustup"
export CARGO_HOME="${HOME}/.cargo"
export PATH="${CARGO_HOME}/bin:${PATH}"

# ── 10. LM Studio CLI ─────────────────────────────────────────────────────────
export PATH="${PATH}:${HOME}/.cache/lm-studio/bin:${HOME}/.lmstudio/bin"

# ── 11. direnv (Nix-managed) ─────────────────────────────────────────────────
eval "$(direnv hook zsh)"

# ── 12. OrbStack (container runtime — adds kubectl/helm/orbctl to PATH) ───────
source ~/.orbstack/shell/init.zsh 2>/dev/null || :

# ── 13. kubectl completion (after OrbStack so kubectl is in PATH) ─────────────
# helm + eksctl completions → source ~/.profile.kubectl
command -v kubectl >/dev/null && source <(kubectl completion zsh)

# ── 14. fzf (Nix system package — no Homebrew path needed) ───────────────────
source <(fzf --zsh)

export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="${FZF_DEFAULT_COMMAND}"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

_fg="#CBE0F0"; _bg="#011628"; _bg_h="#143652"; _pur="#B388FF"; _blu="#06BCE4"; _cyn="#2CF9ED"
export FZF_DEFAULT_OPTS="--color=fg:${_fg},bg:${_bg},hl:${_pur},fg+:${_fg},bg+:${_bg_h},hl+:${_pur},info:${_blu},prompt:${_cyn},pointer:${_cyn},marker:${_cyn},spinner:${_cyn},header:${_cyn}"
unset _fg _bg _bg_h _pur _blu _cyn

_fzf_preview="if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi"
export FZF_CTRL_T_OPTS="--preview '${_fzf_preview}'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"
unset _fzf_preview

_fzf_compgen_path() { fd --hidden --exclude .git . "$1"; }
_fzf_compgen_dir()  { fd --type=d --hidden --exclude .git . "$1"; }

_fzf_comprun() {
  local command=$1; shift
  case "$command" in
    cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
    export|unset) fzf --preview "eval 'echo \${}'"  "$@" ;;
    ssh)          fzf --preview 'dig {}'             "$@" ;;
    *)            fzf --preview "if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi" "$@" ;;
  esac
}

# fzf-git.sh (cloned by home.nix activation at bootstrap)
[ -f ~/.fzf-git.sh/fzf-git.sh ] && source ~/.fzf-git.sh/fzf-git.sh

# ── 15. Tool aliases (using Nix-managed binaries — no hardcoded paths) ────────
alias eza='eza --color=always --long --git --icons=always -F'
alias rd='rawdog --dry-run'
alias aider='aider --dry-run'

# Nix aliases (bat as cat, eza as ls)
[ -f ~/.profile.nix ] && source ~/.profile.nix

# ── 16. Machine-local overrides (NOT managed by Nix — safe for apps to write to)
# ServBay and other tools that inject env blocks should use ~/.zprofile.local.
[ -f ~/.zprofile.local ] && source ~/.zprofile.local
