# Design

## Language and tooling
- use idiomatic Swift
- use xCode compatible project structure
- minimise the use of external dependencies
- target iOS 26 and above

## Product constraints
- Solver is offline-only: shipped features must not require network access at runtime.
- Prefer bundled datasets and on-device processing for search, lookup, ranking, and preferences.
- Design features so they degrade by scope, not connectivity; if data is unavailable locally, the UI should explain that clearly rather than attempting an online fallback.

## Current architecture
- The app is a single iOS target built with SwiftUI and no external runtime dependencies.
- `SolverSession` owns the shared user-facing state for the current pattern and selected tool, and persists both values to on-device storage.
- Pattern handling is split into a pure parser and normalized query model so all solver tools can share the same interpretation rules.
- The first shipped solver feature is an offline crossword search service backed by a bundled text word list in the app bundle.
- The UI keeps the current pattern visible above a tab bar, with crossword search implemented now and the remaining tools represented as roadmap placeholders that already share the same session state.
