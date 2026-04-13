# Tests

## Purpose

This document explains how the automated test suite should support the strategy in `TESTING.md` for the current roadmap item. It is intentionally scoped to the focused live-search crossword tab described in `PLAN.md`.

## Test layers

- Parser unit tests cover normalization of the word-pattern syntax from `README.md`, including letters, single-character wildcards, multi-character wildcards, spaces, and hyphens.
- Search engine unit tests cover matching behavior against bundled local datasets, including common matches, no-match cases, phrase handling, and repeated searches.
- State-model tests cover the shared query state, persisted launch behavior, and invalidation rules when the pattern changes.
- Persistence tests cover saving and restoring the current pattern and selected tool using on-device storage only.
- UI or behavioral tests cover the user-visible flows in `SCENARIOS.md`, especially the focused crossword layout, live results, invalid input, tab coherence, and offline operation.

## Current coverage target

- Start with fast unit tests for parsing and crossword matching because they define the core behavior of the first shipped slice.
- Add behavioral coverage for the crossword tab's live-search flow before broadening into every future tool.
- Prefer fixtures built from small local word lists so tests stay deterministic and easy to understand.
- Keep network usage out of the test harness; offline-only behavior should be the default test environment, not a special-case mode.

## Initial suite outline

- `PatternParserTests`
  Covers valid patterns, invalid patterns, normalization, and edge cases around wildcard combinations.
- `CrosswordSearchTests`
  Covers exact-length matching, phrase matching, no-results behavior, and stability under repeated searches.
- `SolverSessionTests`
  Covers shared state updates, selected-tab behavior, persistence, and reset behavior for deterministic UI tests.
- `SolverAppUITests`
  Covers top-level user flows from `SCENARIOS.md`, including launch, live crossword matches, and inline invalid-pattern feedback.

## Notable edge cases

- Repeated live updates with the same query.
- Unparseable user input.
- Empty input shown in the crossword results region.
- State restoration after app termination or relaunch.
- Unexpected local data values in bundled word lists.
- Large result sets that still need predictable ordering and presentation.

## Maintenance rules

- Any bug found in parsing, local search, persistence, or tab coordination should add or update a test before the fix is considered complete.
- Tests should describe behavior rather than implementation details so refactors do not force broad rewrites.
- Remove or rewrite tests when a feature changes meaning; do not preserve obsolete assertions.
- When a roadmap item graduates from `Now` to `Completed`, update this file so the documented suite matches the shipped feature set.

## Current gaps

- The UI suite currently focuses on the crossword tab and does not yet automate tab switching or restored-state journeys across the wider shell.
- Property testing is still desirable for parser and matcher logic once the current UI slice settles.
- Large-list performance and ranking coverage will need to expand when bigger bundled datasets arrive.
