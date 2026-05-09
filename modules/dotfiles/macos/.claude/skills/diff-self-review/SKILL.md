---
name: diff-self-review
description: Self-review of uncommitted changes before declaring a task done. Use proactively after finishing a coding task and before saying "done". Walks the diff like a reviewer would and flags scope creep, orphans, and missing verification.
allowed-tools: Read, Grep, Glob, Bash(git diff:*), Bash(git status:*), Bash(git log:*)
---

# Diff Self-Review

Before declaring a task done, walk the diff like a reviewer would. This skill enforces the Verify Before Declaring Done rule from CLAUDE.md.

## Step 1: Get the diff

Run `git status` and `git diff` to see all uncommitted changes. If the diff is empty, stop and tell the user there is nothing to review.

## Step 2: For each changed file, ask

- Does this change match the original task scope?
- Is there scope creep (changes adjacent to the task that were not requested)?
- Did I introduce orphans (unused imports, dead variables, unreferenced helpers I added)?
- Did I leave debug residue (print statements, console.log, TODO markers I added, commented-out code)?
- Are tests written or updated for behavioral changes?
- Are there obvious edge cases the change does not handle?
- Did I follow the project's existing style, or did I impose a new one?

## Step 3: Output the self-review

```
## Self-review

Scope: in scope | out of scope -> <list violations>
Orphans I introduced: none | <list>
Debug residue: none | <list with file:line>
Test coverage: adequate | missing for <list>
Edge cases addressed: yes | unhandled: <list>
Style consistency: yes | deviated in <list>

Verdict: ready for verify | needs cleanup
```

## Step 4a: If verdict is "needs cleanup"

List the specific cleanup items. Stop. Do not declare the task done. Do not invoke verify-in-container yet.

## Step 4b: If verdict is "ready for verify"

Tell the user the next step is verification in podman. Suggest invoking the verify-in-container skill, or remind them to run their podman verification command.

## Step 5: After verification passes

Once the user confirms verification passed in the container, the task is done. Close with the End-of-Task Change Summary format from CLAUDE.md.

## What this skill must not do

- Do not declare the task done before verification has run in the container.
- Do not rewrite the code to fix issues. Surface them; let the user decide.
- Do not invent issues. If the diff is clean, say so.
