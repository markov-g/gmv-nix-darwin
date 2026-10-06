# CLAUDE.md

@~/.codex/AGENTS.md

The shared rules above are the single source of truth across Claude Code,
Codex, and OpenCode. Edit `~/.codex/AGENTS.md` (repo path:
`modules/dotfiles/macos/.codex/AGENTS.md`) to change them for all three
harnesses at once. Everything below is Claude Code-specific and does not
apply to the other harnesses; if anything here ever conflicts with the
imported file, the imported file wins.

---

## Claude Code

### Memory Hygiene

- Use `#` during a session to capture a rule you want persisted immediately.
  Pick the right scope (user vs project) deliberately -- it writes to this
  file or the project's `CLAUDE.md`, not to `AGENTS.md`. A rule that should
  apply to Codex and OpenCode too still needs a manual edit to
  `~/.codex/AGENTS.md`; `#` does not propagate there.
- Auto memory (Claude's own notes on corrections and preferences, stored
  under `~/.claude/projects/<project>/memory/`) is separate from both this
  file and `AGENTS.md`. Review it periodically with `/memory`. It is
  machine-local and not version-controlled -- do not treat it as a substitute
  for writing a durable rule into `AGENTS.md`.
- If Claude isn't following an instruction, run `/doctor prompt-audit` to
  check for outdated or conflicting content across `CLAUDE.md`, `AGENTS.md`,
  skills, and rules before assuming the model just ignored it.

### Subagents

Subagent configs for Claude Code live in `~/.claude/agents/` (user) or
`.claude/agents/` (project) as markdown files -- a different mechanism from
Codex's `[agents]` table in `config.toml`, which the imported file's "Use
Subagents Liberally" section describes. The behavior (delegate liberally,
one task per subagent) is shared; only the config location differs.
