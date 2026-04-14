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
- Solver currently ships two offline search tools backed by the bundled test crossword word list: live crossword pattern search and single-word anagram solving.
- The UI keeps the multi-tool tab shell in place, and each implemented tab owns the visible pattern-entry workflow for its tool while still reading and writing the same shared session state.
- The crossword and anagram tabs each drive their results area from a small view-level state machine so empty input, invalid patterns, loading, no-match states, and successful offline matches are all explicit and testable.
- Anagram solving builds on top of the shared parser but narrows the supported input shape to one word made of literal letters only; wildcard and multi-word inputs are surfaced as explicit guidance instead of being guessed at.
