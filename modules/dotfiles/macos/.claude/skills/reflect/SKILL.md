---
name: reflect
description: Reflect on recent sessions and propose updates to CLAUDE.md, skills, agents, hooks, or settings. Surfaces patterns from repeated corrections, the bash-attempts audit log, and locally-approved permissions that never got persisted. Always proposes changes for human approval before editing any file. Use at the end of a frustrating session, weekly as a maintenance pass, or whenever you have corrected the same mistake twice.
disable-model-invocation: true
allowed-tools: Read, Grep, Glob, Bash(git diff:*), Bash(git log:*), Bash(git status:*), Bash(cat:*), Bash(tail:*), Bash(wc:*), Bash(ls:*)
---

# Reflect

Periodic reflection on Claude Code's behavior. Reads the kit, the audit log, and recent session evidence. Proposes targeted changes. Applies only what the user approves.

This skill never edits files in the analysis phase. Write and Edit calls happen only after explicit per-change approval.

## Phase 1: Gather

Read these files when present:

User-level (always check):

- `~/.claude/CLAUDE.md` - global behavior policy
- `~/.claude/settings.json` - permissions, sandbox, hooks
- `~/.claude/agents/*.md` - subagent definitions
- `~/.claude/skills/*/SKILL.md` - user-level skills (do not read self)
- `~/.claude/operational-context.md` - if present
- `~/.claude/hooks/*.sh` - hook scripts

Project-level (check if in a repo):

- `./CLAUDE.md` - project-level overrides
- `.claude/settings.json` - project permissions
- `.claude/settings.local.json` - personal local overrides
- `.claude/agents/*.md` and `.claude/skills/*/SKILL.md`

Also pull these signals:

- `~/.claude/logs/bash-attempts.log` - the last 200 entries via `tail -200`. This is the highest-signal data source. Every blocked attempt is real evidence.
- Recent git activity: `git log --oneline -20` and `git status` for context on what was worked on.
- Auto memory directory: list contents of `~/.claude/projects/<project>/memory/` if present.

State a short summary of what was loaded. Do not dump file contents.

## Phase 2: Analyze

Look for these specific patterns. Each finding must be backed by evidence (a quote, a log line, or a session reference).

1. **Repeated corrections.** The same mistake corrected by the user twice or more in the recent session. Strong candidate for a new rule.
2. **Blocked Bash attempts in the audit log.** Cluster blocks by command type. Does the block reflect a Claude mistake (rule is right) or a rule that is too strict (rule needs loosening or moving to ask)?
3. **Locally-approved permissions.** Permissions the user manually approved during sessions but that never got persisted to settings.json. Candidates to move from per-prompt approval to permissions.allow or permissions.ask.
4. **Skills or agents that should have fired but did not.** If a skill exists for X and the user did X manually, the description needs sharper keywords or a more specific when_to_use field.
5. **AI-tells that slipped through.** Em dashes, curly quotes, ellipsis glyphs, negative parallelism, rule-of-three padding in Claude's responses. If patterns recur, the Anti-AI-Tells section may need a sharper example or a more specific rule.
6. **Rules that never fired.** Sections of CLAUDE.md or skills that have not been relevant for weeks. Apply the compression test: would removing this cause Claude to make a mistake? If no, cut.
7. **Inconsistencies between enforcement layers.** A rule in CLAUDE.md not backed by settings.json. A permission in settings.json that contradicts CLAUDE.md. A hook block that no longer matches the policy.

Do not invent failure modes. If there is no evidence, the suggestion is speculative and must be labeled as such.

## Phase 3: Propose

Present findings one at a time, in this format:

```
Finding [N/total]: <one-line description>
Severity: blocker | important | suggestion | speculative

Evidence:
  <specific quote, log line, or session reference>

Proposed change:
  File: <which file>
  Section: <which section, or "new section">
  Action: add | remove | edit | move-between-layers
  Diff:
    <exact before/after, or new content>

Compression test:
  Adding -> would Claude misbehave without this rule? <yes/no/maybe>
  Cutting -> has this rule fired in the last month? <yes/no/unknown>

Your call: approve | skip | modify
```

Cap at 5 proposals per pass. If more candidates exist, list the rest by severity at the end and stop. Reflection should be incremental.

Wait for the user's response on each proposal before moving to the next.

## Phase 4: Apply

For each approved change:

1. Restate the file and the exact diff.
2. Apply via Edit (or Write for new files).
3. Show the resulting section.
4. Move to the next approved change.

After all approved changes:

- Re-run the ASCII audit on changed markdown files: `LC_ALL=C grep -nP '[^\x00-\x7F]' <files>` should return nothing.
- Validate JSON if settings.json was edited.
- Close with the End-of-Task Change Summary format from CLAUDE.md.

## Anti-Patterns for This Skill

- Do not bulk-add rules. Zero to five per pass, severity-ordered.
- Do not propose stylistic changes that do not fix a documented failure.
- Do not auto-promote auto memory entries; surface them and let the user decide scope.
- Do not edit any file without explicit per-change approval.
- Do not call this skill recursively on itself.
- Do not propose changes to `~/.claude/.credentials.json`, `~/.claude.json`, or any auth file. Those are out of scope.

## When to invoke this

- After a session where you corrected Claude on the same thing twice.
- After hitting a rule you believe was wrong.
- Weekly, as a 10-minute maintenance pass.
- Before sharing a project's `.claude/` directory with a teammate.
- Never automatically. This skill modifies your config; you decide when.
