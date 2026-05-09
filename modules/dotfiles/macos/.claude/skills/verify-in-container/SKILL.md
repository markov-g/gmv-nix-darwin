---
name: verify-in-container
description: Generates the podman command to verify changes (run tests, build, lint) without executing on the host. Use when the user wants to verify uncommitted code, run tests after changes, or check that a build still works. Reads project files to detect the stack.
allowed-tools: Read, Glob, Bash(cat:*), Bash(ls:*)
---

# Verify in Container

The user's CLAUDE.md forbids host execution. All verification happens in podman containers. This skill generates the right podman command for the current task.

## Step 1: Identify the project stack

Look for stack indicators in the project root:

- `pyproject.toml`, `requirements.txt`, `setup.py`, `setup.cfg` -> Python
- `Cargo.toml` -> Rust
- `Package.swift`, `*.xcodeproj`, `*.xcworkspace` -> Swift
- `*.csproj`, `*.sln`, `global.json`, `Directory.Build.props` -> .NET

If multiple are present (monorepo or polyglot), ask the user which to verify.

## Step 2: Identify the verification command

Default commands per stack. If the project has its own conventions in `Makefile`, `justfile`, `Taskfile`, or scripts in `package.json`, prefer those.

| Stack | Test | Build | Lint |
|-------|------|-------|------|
| Python | `pytest` | `python -m build` | `ruff check .` |
| Rust | `cargo test` | `cargo build` | `cargo clippy --all-targets` |
| Swift | `swift test` | `swift build` | `swift-format lint -r .` |
| .NET | `dotnet test` | `dotnet build` | `dotnet format --verify-no-changes` |

Read `~/.claude/operational-context.md` if present for the user's specific stack defaults; use those over the table above.

## Step 3: Pick the mount mode

- Read-only mount (`-v "$PWD:/app:ro"`) is the default. Use it for tests, lint, and read-only checks.
- Read-write mount (`-v "$PWD:/app"`) is only needed when the build writes to the working tree (cargo `target/`, .NET `bin/`/`obj/`, npm `node_modules/`). Even then, prefer mounting a writable subdirectory rather than the whole tree if possible.

## Step 4: Generate the podman command

Default form:

```
podman run --rm \
  -v "$PWD:/app:ro" \
  -w /app \
  <image> \
  <command>
```

Substitute `<image>` from the operational context if available, or ask the user which image to use.

## Step 5: Present the command

Output the exact command. Do not execute it. Tell the user:

"Run this in your terminal and tell me the output. I will not run it."

If the verification needs network access (downloading dependencies, fetching crates, restoring packages), point that out. Suggest baking dependencies into the image at build time rather than relying on runtime network in the verification step.

## What this skill must not do

- Never run the command on the host. The CLAUDE.md host-isolation rule is a hard rule.
- Never suggest workarounds to the host-isolation rule.
- If the user has no container image set up, say so and stop. Do not fabricate a command that won't run.
