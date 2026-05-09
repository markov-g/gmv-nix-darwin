#!/usr/bin/env bash
#
# ~/.claude/hooks/pre-bash-host-isolation.sh
#
# Defense-in-depth pre-flight check on every Bash tool call.
#
# Layered architecture (this script is layer 4):
#   1. CLAUDE.md             - tells Claude the rule (context, not enforcement)
#   2. permissions.deny/ask  - pattern-matches commands (start-of-command only)
#   3. sandbox               - OS-level bash isolation (filesystem + network)
#   4. this hook             - chain-aware command inspection + audit log
#
# Why this hook exists when settings.json already has a deny list:
#   - Bash permission patterns match the START of the command. A chained
#     command like `cat foo && rm -rf /` can pass a deny on `Bash(rm:*)`
#     because the command starts with `cat`. This hook splits chains.
#   - It logs every Bash attempt to ~/.claude/logs/bash-attempts.log for
#     audit and post-hoc review.
#   - It blocks bypass-attempt patterns (--dangerously-skip-permissions,
#     --no-sandbox, CLAUDE_CODE_DISABLE).
#
# Exit codes:
#   0  allow (settings.json permissions still apply afterwards)
#   2  block (stderr is surfaced to Claude as the reason)
#
# Requires: bash, jq, awk, sed.

set -euo pipefail

PAYLOAD=$(cat)

if ! command -v jq >/dev/null 2>&1; then
  echo "BLOCK: jq is required for the host-isolation hook but is not installed." >&2
  echo "Install it (macOS: 'brew install jq') and retry." >&2
  exit 2
fi

TOOL_NAME=$(printf '%s' "$PAYLOAD" | jq -r '.tool_name // ""')

# Only inspect Bash calls. Other tools pass through.
[[ "$TOOL_NAME" != "Bash" ]] && exit 0

COMMAND=$(printf '%s' "$PAYLOAD" | jq -r '.tool_input.command // ""')

# Audit log every attempt, even ones we allow.
LOG_DIR="$HOME/.claude/logs"
mkdir -p "$LOG_DIR"
printf '[%s] %s\n' "$(date -Iseconds 2>/dev/null || date)" "$COMMAND" \
  >>"$LOG_DIR/bash-attempts.log"

block() {
  echo "BLOCK: $1" >&2
  echo "Command: $COMMAND" >&2
  echo "Run anything that needs to execute code inside a podman container." >&2
  exit 2
}

# 1. Bypass-attempt patterns
case "$COMMAND" in
*"--dangerously-skip-permissions"*) block "command attempts to bypass permissions" ;;
*"--no-sandbox"*) block "command attempts to disable sandbox" ;;
*"CLAUDE_CODE_DISABLE"*) block "command sets a Claude Code bypass env var" ;;
esac

# 2. Command substitution can hide a forbidden command inside an allowed one
case "$COMMAND" in
*'$('*) block "command substitution \$(...) is not allowed on the host" ;;
*'`'*) block "command substitution with backticks is not allowed on the host" ;;
esac

# 3. Chain-aware first-word check.
# Split on &&, ||, ;, and | so each segment is examined separately.
SEGMENTS=$(printf '%s' "$COMMAND" | sed -E 's/(&&|\|\||;|\|)/\n/g')

while IFS= read -r segment; do
  # Extract the first word (skip empty/whitespace-only segments)
  FIRST=$(printf '%s' "$segment" | awk '{print $1}')
  [[ -z "$FIRST" ]] && continue

  case "$FIRST" in
  python | python3 | pip | pip3 | uv | poetry | pytest | tox)
    block "'$FIRST' executes Python or installs Python packages"
    ;;
  cargo | rustc | rustup)
    block "'$FIRST' compiles or runs Rust code"
    ;;
  dotnet | swift | swiftc | xcodebuild | xcrun)
    block "'$FIRST' compiles or runs .NET / Swift code"
    ;;
  npm | npx | yarn | pnpm | node | deno | bun)
    block "'$FIRST' runs JavaScript or installs packages"
    ;;
  make | cmake | gcc | g++ | clang | go | java | javac | mvn | gradle | ruby | gem | bundle)
    block "'$FIRST' compiles or runs code"
    ;;
  rm | rmdir | mv | chmod | chown)
    block "'$FIRST' mutates host filesystem state"
    ;;
  sudo | apt | apt-get | brew | port | systemctl | launchctl)
    block "'$FIRST' modifies the system or requires elevated privileges"
    ;;
  kill | pkill)
    block "'$FIRST' affects host processes"
    ;;
  curl | wget | ssh | scp | rsync)
    block "'$FIRST' performs network or remote operations"
    ;;
  git)
    # When git is invoked, check the subcommand. Read-only subcommands
    # pass; mutation subcommands are blocked here too as defense in depth.
    GIT_SUB=$(printf '%s' "$segment" | awk '{print $2}')
    case "$GIT_SUB" in
    push | commit | checkout | switch | reset | rebase | merge | pull | fetch | \
      clean | clone | stash | am | cherry-pick | revert | tag | notes | worktree)
      block "'git $GIT_SUB' mutates git or remote state"
      ;;
    esac
    ;;
  esac
done <<<"$SEGMENTS"

# All checks passed. settings.json permissions still gate the call.
exit 0
