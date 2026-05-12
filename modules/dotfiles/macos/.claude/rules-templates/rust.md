---
name: rust-rules
description: Conventions for Rust files. Loaded only when editing Rust source or Cargo files.
globs:
  - "**/*.rs"
  - "**/Cargo.toml"
  - "**/Cargo.lock"
---
# Rust rules

## Workspace and crates
- If the project is a workspace, never modify `[workspace.dependencies]` without updating every crate that references the moved dep.
- Match the workspace's existing edition. Mixed editions in one workspace are a debugging nightmare.
- Do not add a new crate to the workspace without confirming. Compile time is shared.

## Errors
- Match the project's pattern: `thiserror` for libraries, `anyhow` for binaries. Do not mix in one crate.
- Avoid `unwrap()` in non-test code. Use `?` plus a meaningful error variant.
- Never silently drop a `Result` with `let _ = ...`. Either handle it or `.expect("reason")`.

## Async
- If the project uses tokio, do not introduce async-std (or vice versa). Mixing async runtimes deadlocks.
- `block_on` inside an async context panics in tokio. Use `.await`.
- `tokio::spawn` requires `Send + 'static`. If you hit a Send error, the fix is usually scope, not `Arc<Mutex<...>>`.

## Tests
- `#[tokio::test]` for async, `#[test]` for sync. Do not mark sync tests `#[tokio::test]`; it wastes a runtime per test.
- Doctests run by default. Mark with `no_run`, `ignore`, or `compile_fail` deliberately, not to silence noise.

## Common foot-guns
- `String` vs `&str`: never clone a `&str` to pass to a function expecting `&str`. Pass it directly.
- `Vec::new()`, `Vec::with_capacity(0)`, and `vec![]` all do not allocate. Pick one and stay consistent.
- `unsafe` requires a comment justifying the invariants. Never `unsafe` without that comment.
- `?` on `Option` in a function returning `Result` needs `.ok_or(err)?`, not bare `?`.