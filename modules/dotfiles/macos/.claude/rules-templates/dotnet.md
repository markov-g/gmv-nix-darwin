---
name: dotnet-rules
description: Conventions for .NET files. Loaded only when editing C#, project, or solution files.
globs:
  - "**/*.cs"
  - "**/*.csproj"
  - "**/*.sln"
  - "**/Directory.Build.props"
  - "**/Directory.Packages.props"
  - "**/global.json"
---
# .NET rules

## Project structure
- Respect the existing `<TargetFramework>`. Do not bump major versions casually; it breaks NuGet resolution downstream.
- `Directory.Build.props` and `Directory.Packages.props` carry shared settings. Edit project-level files only when truly project-specific; prefer central edits.
- If the repo uses Central Package Management (`ManagePackageVersionsCentrally = true`), do not add `<Version>` to individual project files.

## Async
- Suffix async methods with `Async`. The non-async caller is a hint; the suffix is the contract.
- Avoid `.Result` and `.Wait()` in async code; they deadlock under SynchronizationContext (legacy ASP.NET, WPF).
- `ConfigureAwait(false)` in library code unless you specifically need the captured context.
- `async void` only for event handlers. Otherwise return `Task` or `ValueTask`.

## Nullable
- If `<Nullable>enable</Nullable>` is set, respect it. Suppressing with `null!` or `!` is a code smell; if used, comment why.
- Do not add `?` to make warnings go away. Model the actual nullability.

## Testing
- Match the existing framework: xUnit, NUnit, or MSTest. Do not introduce a parallel.
- `Theory` with `InlineData` over multiple `Fact` methods when testing the same logic across inputs.
- Integration tests live in a separate project, not mixed with unit tests.

## Common foot-guns
- `DateTime.Now` is local; usually you want `DateTime.UtcNow` or `DateTimeOffset.Now`.
- `IEnumerable<T>` evaluated multiple times re-runs the query. If iterating twice, materialize with `.ToList()`.
- `string.IsNullOrWhiteSpace` over `string.IsNullOrEmpty` for user input.
- `Equals` on records does field comparison; `==` on classes does reference comparison. Know which type you have.
- `using var` scope ends at the enclosing block, not the next semicolon. Disposal timing matters.