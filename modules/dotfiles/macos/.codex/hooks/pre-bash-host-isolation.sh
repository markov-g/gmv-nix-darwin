#!/usr/bin/env bash
#
# ~/.codex/hooks/pre-shell-host-isolation.sh
#
# Defense-in-depth pre-flight check on every Bash/shell tool call.
# Codex equivalent of the Claude Code pre-bash-host-isolation.sh hook.
#
# Layered architecture (this script is layer 4):
#   1. AGENTS.md                 - tells Codex the rule (context, not enforcement)
#   2. approval_policy           - global "ask before running" flag
#   3. sandbox_mode = read-only  - OS-level filesystem isolation
#   4. this hook                 - chain-aware command inspection + audit log
#
# Why this hook exists when sandbox_mode = "read-only" already blocks writes:
#   - sandbox_mode is filesystem-scoped. It does not catch network operations,
#     environment changes, or commands that just exfiltrate data.
#   - It logs every shell attempt to ~/.codex/logs/shell-attempts.log for
#     audit and post-hoc review.
#   - It blocks bypass-attempt patterns (--dangerously-bypass-approvals-and-sandbox,
#     --yolo, CODEX_SANDBOX bypasses).
#
# JSON schema:
#   Codex sends PreToolUse hooks a JSON payload via stdin. The exact schema
#   varies by Codex version. This script tries common field paths in order.
#
# Exit codes:
#   0  allow
#   2  block (stderr is surfaced to Codex as the reason)
#
# Requires: bash, jq, awk, sed.

set -euo pipefail

PAYLOAD=$(cat)

if ! command -v jq >/dev/null 2>&1; then
  echo "BLOCK: jq is required for the host-isolation hook but is not installed." >&2
  echo "Install it (macOS: 'brew install jq') and retry." >&2
  exit 2
fi

# Tool name. Try Codex's documented field, fall back to common alternatives.
TOOL_NAME=$(printf '%s' "$PAYLOAD" | jq -r '
  .tool_name //
  .tool.name //
  .name //
  ""
')

# Only inspect shell-like calls. Other tools pass through.
case "$TOOL_NAME" in
Bash | bash | shell | exec | local_shell) ;;
*) exit 0 ;;
esac

# Command. Try Codex's documented field, fall back to common alternatives.
COMMAND=$(printf '%s' "$PAYLOAD" | jq -r '
  .tool_input.command //
  .input.command //
  .arguments.command //
  .command //
  ""
')

# If we cannot extract a command, fail closed rather than open.
if [[ -z "$COMMAND" ]]; then
  echo "BLOCK: pre-shell hook could not extract command from payload." >&2
  echo "Payload schema may have changed; update the hook script." >&2
  exit 2
fi

# Audit log every attempt, even ones we allow.
LOG_DIR="$HOME/.codex/logs"
mkdir -p "$LOG_DIR"
printf '[%s] %s\n' "$(date -Iseconds 2>/dev/null || date)" "$COMMAND" \
  >>"$LOG_DIR/shell-attempts.log"

block() {
  echo "BLOCK: $1" >&2
  echo "Command: $COMMAND" >&2
  echo "Run anything that needs to execute code inside a podman container." >&2
  exit 2
}

# 1. Bypass-attempt patterns
case "$COMMAND" in
*"--dangerously-bypass-approvals-and-sandbox"*) block "command attempts to bypass approvals and sandbox" ;;
*"--yolo"*) block "command attempts yolo mode" ;;
*"CODEX_SANDBOX_NETWORK_DISABLED=0"*) block "command attempts to re-enable sandbox network" ;;
*"CODEX_SANDBOX="*) block "command tampers with Codex sandbox env" ;;
*"--dangerously-skip-permissions"*) block "command attempts to bypass permissions" ;;
*"--no-sandbox"*) block "command attempts to disable sandbox" ;;
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
    # pass; mutation subcommands are blocked here as defense in depth.
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

# All checks passed.
exit 0
