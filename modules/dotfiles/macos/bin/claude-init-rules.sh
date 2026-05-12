#!/usr/bin/env bash
#
# ~/bin/claude-init-rules.sh
#
# Stamps path-scoped rule templates from ~/.claude/rules-templates/ into the
# current project's .claude/rules/ directory.
#
# Path-scoped rules are project-level (per Claude Code docs); user-level
# .claude/rules/ is unverified. This script bridges that: templates live in
# Nix-managed user-level storage, get copied into each project as needed.
#
# Usage:
#   claude-init-rules.sh <stack> [<stack>...]
#   claude-init-rules.sh --all
#   claude-init-rules.sh --list
#
# Stacks: python rust swift dotnet

set -euo pipefail

TEMPLATES_DIR="$HOME/.claude/rules-templates"
TARGET_DIR=".claude/rules"

if [[ ! -d "$TEMPLATES_DIR" ]]; then
  echo "Templates directory not found: $TEMPLATES_DIR" >&2
  echo "Check that home-manager has linked ~/.claude/rules-templates/" >&2
  exit 1
fi

usage() {
  echo "Usage: $0 <stack> [<stack>...]"
  echo "       $0 --all"
  echo "       $0 --list"
  echo ""
  echo "Available stacks:"
  for f in "$TEMPLATES_DIR"/*.md; do
    [[ -f "$f" ]] || continue
    basename "$f" .md | sed 's/^/  - /'
  done
}

if [[ $# -eq 0 ]]; then
  usage
  exit 1
fi

case "${1:-}" in
  --list|-l)
    echo "Available rule templates:"
    for f in "$TEMPLATES_DIR"/*.md; do
      [[ -f "$f" ]] || continue
      basename "$f" .md | sed 's/^/  - /'
    done
    exit 0
    ;;
  --all|-a)
    set -- $(cd "$TEMPLATES_DIR" && ls *.md | sed 's/\.md$//')
    ;;
  --help|-h)
    usage
    exit 0
    ;;
esac

mkdir -p "$TARGET_DIR"

created=0
skipped=0

for stack in "$@"; do
  src="$TEMPLATES_DIR/${stack}.md"
  dest="$TARGET_DIR/${stack}.md"

  if [[ ! -f "$src" ]]; then
    echo "Unknown stack: '$stack' (no template at $src)" >&2
    skipped=$((skipped + 1))
    continue
  fi

  if [[ -f "$dest" ]]; then
    echo "Exists, skipping: $dest"
    skipped=$((skipped + 1))
    continue
  fi

  cp "$src" "$dest"
  echo "Created: $dest"
  created=$((created + 1))
done

echo ""
echo "Done. Created $created, skipped $skipped."

if [[ $created -gt 0 ]]; then
  echo ""
  echo "Next steps:"
  echo "  1. Edit $TARGET_DIR/*.md and tailor to this project's conventions"
  echo "  2. git add $TARGET_DIR/"
  echo "  3. Commit the rules with the project, not user-level"
fi