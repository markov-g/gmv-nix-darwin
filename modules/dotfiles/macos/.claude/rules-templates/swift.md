---
name: swift-rules
description: Conventions for Swift files. Loaded only when editing Swift source or package files.
globs:
  - "**/*.swift"
  - "**/Package.swift"
  - "**/Package.resolved"
  - "**/project.pbxproj"
---
# Swift rules

## Concurrency
- On Swift 6 with strict concurrency: every closure captured across actors needs `@Sendable`. Do not silence with `@unchecked Sendable` without a comment justifying the invariants.
- `Task { ... }` inherits the current actor; `Task.detached { ... }` does not. Choose deliberately.
- Avoid `DispatchQueue.main.async` in async contexts; use `await MainActor.run` or annotate the function `@MainActor`.

## SwiftUI
- Prefer the `@Observable` macro (iOS 17+, macOS 14+) over `ObservableObject` unless the deployment target requires the older API.
- Do not call `objectWillChange.send()` manually in `@Observable` types. The macro handles it.
- `@State` for value types owned by the view, `@Bindable` for reference types you do not own, `@Environment` for cross-view state.
- Avoid view work in initializers or `body`. SwiftUI re-runs `body` frequently; expensive work belongs in the model or `.task { }`.

## Optionals
- Prefer shorthand `if let foo {` on Swift 5.7+.
- Avoid force-unwrap (`!`) in production code. `try!` is acceptable in tests; never in app code.
- `String(describing: optional)` includes the `Optional(...)` wrapper; usually you want `?? "fallback"`.

## Common foot-guns
- `Date()` without explicit calendar uses the user's local calendar; surprises in tests across timezones.
- `print()` ships in release builds. Use `Logger` from the `os` framework with a category.
- `Codable` synthesized keys are case-sensitive and match property names exactly. Use `CodingKeys` enum for any rename.
- Soft-deprecated SwiftUI APIs you should never reach for: `foregroundColor()` (use `.foregroundStyle()`), `Text` `+` concatenation (use string interpolation in a single `Text`), `NavigationView` (use `NavigationStack`).