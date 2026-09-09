#!/bin/bash
# rtk-if-available.sh -- RTK (Rust Token Killer) hook, conditional on PATH presence.
#
# RTK compresses Bash output before the model sees it (60-90% token savings).
# This hook runs RTK if installed; exits 0 silently if RTK is absent.
# Install RTK: brew install rtk  (or via a Nix flake on supported machines)
#
# Wired as PreToolUse Bash hook in:
#   ~/.claude/settings.json (Claude Code)
#   ~/.codex/config.toml   (Codex)
#
# Exit 0 = allow (RTK absent or RTK processed and passed through).
# RTK itself exits non-zero on errors, which will block the tool call.

if command -v rtk >/dev/null 2>&1; then
  exec rtk hook
fi

exit 0
