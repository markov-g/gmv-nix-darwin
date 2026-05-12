---
name: python-rules
description: Conventions for Python files. Loaded only when editing Python source or config.
globs:
  - "**/*.py"
  - "**/pyproject.toml"
  - "**/requirements*.txt"
  - "**/setup.cfg"
  - "**/setup.py"
---
# Python rules

## Package management
- Use the project's existing tool: uv, poetry, pip-tools, or pip. Do not introduce a new one.
- Lockfile is source of truth. If it exists, never edit `pyproject.toml` deps without regenerating the lock.

## Tests
- Use the existing framework (pytest, unittest). Do not introduce a parallel runner.
- Mark slow or integration tests with `@pytest.mark.<marker>`. Plain `def test_*` is unit-test territory; unit tests never make real network calls.
- Use the project's fixtures and fakes for IO boundaries.

## Types
- Use type hints. If the codebase uses `from __future__ import annotations`, match it.
- Prefer `X | None` over `Optional[X]` on 3.10+.
- Do not add `Any` to silence mypy. Either type it properly or `# type: ignore[<rule>]` with a one-line comment explaining why.

## Style
- Respect the project's formatter (black, ruff format). Do not change formatter config without asking.
- Respect the project's linter rules. Errors before warnings.
- Imports: stdlib, third-party, local; one blank line between groups.

## Common foot-guns
- `datetime.utcnow()` is naive and deprecated on 3.12+. Use `datetime.now(UTC)`.
- Mutable default args (`def f(x: list = [])`) are a classic trap. Use a `None` sentinel.
- f-strings with `=` (`f"{x=}"`) are debug-only. Do not ship in user-visible strings.
- `print()` in library code; use `logging` with a module-level logger.