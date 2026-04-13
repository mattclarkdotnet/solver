# Tests

## Purpose

This document explains how the automated test suite should support the strategy in `TESTING.md` for the current roadmap item. It is intentionally scoped to the first offline vertical slice described in `PLAN.md`.

## Test layers

- Parser unit tests cover normalization of the word-pattern syntax from `README.md`, including letters, single-character wildcards, multi-character wildcards, spaces, and hyphens.
- Search engine unit tests cover matching behavior against bundled local datasets, including common matches, no-match cases, phrase handling, and repeated searches.
- State-model tests cover the shared query state, tab transitions, and invalidation rules when the pattern changes.
- Persistence tests cover saving and restoring the current pattern and selected tool using on-device storage only.
- UI or behavioral tests cover the user-visible flows in `SCENARIOS.md`, especially empty input, invalid input, tab coherence, and offline operation.

## Current coverage target

- Start with fast unit tests for parsing and crossword matching because they define the core behavior of the first shipped slice.
- Add behavioral coverage for the highest-value user journeys before broadening into every future tool.
- Prefer fixtures built from small local word lists so tests stay deterministic and easy to understand.
- Keep network usage out of the test harness; offline-only behavior should be the default test environment, not a special-case mode.

## Initial suite outline

- `PatternParserTests`
  Covers valid patterns, invalid patterns, normalization, and edge cases around wildcard combinations.
- `CrosswordSearchTests`
  Covers exact-length matching, phrase matching, no-results behavior, and stability under repeated searches.
- `SolverSessionTests`
  Covers shared state updates, selected-tab behavior, and stale-result invalidation when the current pattern changes.
- `SolverPersistenceTests`
  Covers restoration of the latest on-device pattern and selected tool after app relaunch.
- `SolverAppUITests`
  Covers top-level user flows from `SCENARIOS.md` once the app shell is in place.

## Notable edge cases

- Repeated search actions with the same query.
- Unparseable user input.
- Empty input submitted to a solver tool.
- State restoration after app termination or relaunch.
- Unexpected local data values in bundled word lists.
- Large result sets that still need predictable ordering and presentation.

## Maintenance rules

- Any bug found in parsing, local search, persistence, or tab coordination should add or update a test before the fix is considered complete.
- Tests should describe behavior rather than implementation details so refactors do not force broad rewrites.
- Remove or rewrite tests when a feature changes meaning; do not preserve obsolete assertions.
- When a roadmap item graduates from `Now` to `Completed`, update this file so the documented suite matches the shipped feature set.

## Current gaps

- There is not yet a dedicated test target or executable suite in the scaffolded Xcode project.
- Behavioral scenarios are documented, but their automated coverage still needs to be implemented.
- Property testing is desirable for parser and matcher logic once the core types and APIs are stable.
