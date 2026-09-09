#!/bin/zsh
# ~/.herdr-start.sh -- nix-managed via home.nix (symlink to Nix store)
#
# Source env and launch or attach to the persistent Herdr session.
# "herdr" handles both cases transparently (launch or attach).
#
# On fresh server start: Herdr server inherits this env; all sessions get it.
# On reattach:           server already has its env; sourcing here is a no-op.
#
# Workspace topology is NOT loaded here.
# Run ~/herdr-load-workspaces.sh explicitly to recreate project workspaces.

source ~/.profile.homebrew         2>/dev/null
[[ -f ~/.zshenv ]]      && source ~/.zshenv
[[ -f ~/.claude.env ]]  && source ~/.claude.env
setopt allexport
[[ -f ~/.codex.env ]]   && source ~/.codex.env
unsetopt allexport
[[ -f ~/.gemini.env ]]  && source ~/.gemini.env
[[ -f ~/.profile.nix ]] && source ~/.profile.nix

exec herdr
