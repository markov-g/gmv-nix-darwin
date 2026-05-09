---
name: reflect
description: Reflect on recent Codex sessions and propose updates to AGENTS.md, config.toml, skills, hooks, or subagent configs. Surfaces patterns from repeated corrections, the shell-attempts audit log, locally-approved permissions that never got persisted, and skills that should have fired but did not. Always proposes changes for human approval before editing any file. Use at the end of a frustrating session, weekly as a maintenance pass, or whenever you have corrected the same mistake twice.
---

# Reflect

Periodic reflection on Codex's behavior. Reads the configuration kit,
the audit log, and recent session evidence. Proposes targeted changes.
Applies only what the user approves.

This skill never edits files in the analysis phase. Edit and Write
calls happen only after explicit per-change approval.

## Phase 1: Gather

Read these files when present.

User-level (always check):

- `~/.codex/AGENTS.md` - global behavior policy
- `~/.codex/AGENTS.override.md` - personal override (takes precedence
  over AGENTS.md when present)
- `~/.codex/config.toml` - approval policy, sandbox mode, hooks,
  features, skills enablement, subagents, project trust
- `~/.codex/skills/*/SKILL.md` - user-level skills (do not read self)
- `~/.codex/agents/*.toml` - subagent role configs
- `~/.codex/hooks/*.sh` - hook scripts

Project-level (check if in a repo):

- `./AGENTS.md` at the project root
- Any nested `./AGENTS.md` between project root and current working
  directory (Codex concatenates these in order)
- `./AGENTS.override.md` at any level
- `.codex/config.toml` - project trust settings, project-local hooks,
  project-local skills

Pull these signals:

- `~/.codex/logs/shell-attempts.log` (last 200 entries via
  `tail -200`). This is the highest-signal data source. Every blocked
  attempt is real evidence of either a Codex mistake or a rule that
  needs adjusting.
- Codex's own session log at `~/.codex/log/codex-tui.log` for context
  on what was attempted and approved during recent sessions.
- Recent git activity: `git log --oneline -20` and `git status` for
  context on what was worked on.
- The `[projects.*]` table in config.toml: which projects you have
  marked trusted, and whether any new repos appeared this week that
  warrant adding.

State a short summary of what was loaded. Do not dump file contents.

## Phase 2: Analyze

Look for these specific patterns. Each finding must be backed by
evidence (a quote, a log line, or a session reference).

1. **Repeated corrections.** The same mistake corrected by the user
   twice or more in the recent session. Strong candidate for a new
   rule.
2. **Blocked attempts in the audit log.** Cluster blocks by command
   type. Does the block reflect a Codex mistake (rule is right) or a
   rule that is too strict (rule needs loosening, or moving from the
   hook into `approval_policy = "on-request"` territory)?
3. **Locally-approved one-shot permissions.** Permissions the user
   manually approved during sessions but that never got persisted.
   Candidates: bump `approval_policy` for that command class, or
   refine the hook's allowlist.
4. **Skills or subagents that should have fired but did not.** If a
   skill exists for X and you did X manually instead, the skill
   description needs sharper keywords or it needs to be enabled in
   `[skills.<name>]` if currently disabled.
5. **AI-tells that slipped through.** Em dashes, curly quotes, ellipsis
   glyphs, negative parallelism, rule-of-three padding. If patterns
   recur, the Anti-AI-Tells section in AGENTS.md needs a sharper
   example or a more specific rule.
6. **Rules that never fired.** Sections of AGENTS.md or skills that
   have not been relevant for weeks. Apply the compression test:
   would removing this cause Codex to make a mistake? If no, cut.
7. **Inconsistencies between enforcement layers.** A rule in AGENTS.md
   not backed by config.toml. A `sandbox_mode` value that contradicts
   AGENTS.md guidance. A hook block that no longer matches the
   policy. A trusted project entry for a repo that was archived.
8. **Stale `[projects.*]` trust entries.** Repos you no longer work in
   that still carry trust. Candidates for removal.
9. **AGENTS.md size drift.** If the file has grown past 30 KiB, you
   are approaching the 32 KiB truncation threshold on older Codex
   versions. Check `wc -c ~/.codex/AGENTS.md` and consider whether
   any sections should move into a Skill instead.

Do not invent failure modes. If there is no evidence, the suggestion
is speculative and must be labeled as such.

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
  Adding -> would Codex misbehave without this rule? <yes/no/maybe>
  Cutting -> has this rule fired in the last month? <yes/no/unknown>

Your call: approve | skip | modify
```

Cap at 5 proposals per pass. If more candidates exist, list the rest
by severity at the end and stop. Reflection should be incremental.

Wait for the user's response on each proposal before moving to the
next.

## Phase 4: Apply

For each approved change:

1. Restate the file and the exact diff.
2. Apply via Edit (or Write for new files).
3. Show the resulting section.
4. Move to the next approved change.

After all approved changes:

- Re-run the ASCII audit on changed markdown files. Should return
  nothing:

  ```
  LC_ALL=C grep -nP '[^\x00-\x7F]' <changed-files>
  ```

- Validate config.toml if it was edited:

  ```
  python3 -c 'import tomllib; tomllib.load(open("'"$HOME"'/.codex/config.toml","rb"))'
  ```

- If AGENTS.md was edited, confirm size is still under
  `project_doc_max_bytes` (default 32 KiB, or whatever you set):

  ```
  wc -c ~/.codex/AGENTS.md
  ```

- Close with the End-of-Task Change Summary format from AGENTS.md.

## Anti-Patterns for This Skill

- Do not bulk-add rules. Zero to five per pass, severity-ordered.
- Do not propose stylistic changes that do not fix a documented
  failure.
- Do not edit any file without explicit per-change approval.
- Do not call this skill recursively on itself.
- Do not propose changes to `~/.codex/auth.json`, `~/.codex/.codex.json`,
  or any auth file. Those are out of scope.
- Do not add `[projects.<path>]` trust entries without explicit user
  approval; trust is a security boundary.
- Do not propose changes that would set `sandbox_mode` to anything
  less restrictive than `read-only` without explicit user approval.
  The default posture is host-isolation.

## When to invoke this

- After a session where you corrected Codex on the same thing twice.
- After hitting a hook block you believe was wrong.
- Weekly, as a 10-minute maintenance pass.
- Before sharing a project's `.codex/` directory with a teammate.
- Never automatically. This skill modifies your config; you decide
  when.
