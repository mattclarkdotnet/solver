# Tests

## Purpose

This document explains how the automated test suite should support the strategy in `TESTING.md` for the current roadmap item. It is intentionally scoped to the current bottom-status-bar slice described in `PLAN.md`.

## Test layers

- Parser unit tests cover normalization of the word-pattern syntax from `README.md`, including letters, single-character wildcards, multi-character wildcards, spaces, and hyphens.
- Search engine unit tests cover matching behavior against bundled local datasets, including crossword matching, anagram matching, Scrabble rack-plus-board matching, definitions lookup, thesaurus lookup, no-match cases, and repeated searches.
- State-model tests cover the shared query state, persisted launch behavior, and invalidation rules when the pattern changes.
- Persistence tests cover saving and restoring the current pattern, Scrabble-specific board fields, selected tool, and selected bundled word-list group using on-device storage only.
- Resource-contract tests cover loading bundled files from the selected group and verifying the implemented tools continue to resolve the chosen group coherently.
- Concurrency unit tests cover cooperative cancellation of long-running local searches and the latest-query-wins rule for superseded work.
- UI or behavioral tests cover the user-visible flows in `SCENARIOS.md`, especially the bottom status bar, in-place word-list switching, secondary `Preferences`/`Help`/`About` actions, coherent results under the selected group, and offline operation.

## Current coverage target

- Start with fast unit tests for parsing, crossword matching, anagram matching, Scrabble rack-plus-board matching, definitions lookup, and thesaurus lookup because they define the core behavior of the currently implemented tools.
- Keep cancellation coverage focused on the local search engines so regressions in execution behavior are caught without relying only on slower end-to-end tests.
- Add or update resource-loading coverage so group selection between `test` and `English` does not silently break bundled-data access.
- Keep the existing behavioral coverage for implemented tools so the bottom status bar and secondary sheets do not weaken end-to-end confidence.
- Prefer asserting behavior through stable local fixtures and bundled seed data rather than inspecting packaging details directly from UI tests.
- Prefer fixtures built from small local word lists so tests stay deterministic and easy to understand.
- Keep network usage out of the test harness; offline-only behavior should be the default test environment, not a special-case mode.

## Initial suite outline

- `PatternParserTests`
  Covers valid patterns, invalid patterns, normalization, and edge cases around wildcard combinations.
- `CrosswordSearchTests`
  Covers exact-length matching, phrase matching, no-results behavior, stability under repeated searches, and cooperative cancellation of long-running scans.
- `AnagramSearchTests`
  Covers exact-letter anagram matching, exclusion of the source word, unsupported input shapes, and filtering of non-anagram entries from the local dataset.
- `ScrabbleSearchTests`
  Covers subset-of-rack matching, blank-tile substitution, board-letter constraints, invalid Scrabble field input, and word ordering against the local test Scrabble list.
- `DefinitionsLookupTests`
  Covers exact lookup, phrase lookup, unsupported input, and parsing of the bundled definitions-record format.
- `ThesaurusLookupTests`
  Covers exact lookup, phrase lookup, unsupported input, and parsing of the bundled thesaurus-record format.
- `SolverSessionTests`
  Covers shared state updates, selected-tab behavior, bundled-group persistence, and reset behavior for deterministic UI tests.
- `SolverAppUITests`
  Covers top-level user flows from `SCENARIOS.md` in one shared app session, including launch, the bottom status bar, switching bundled groups without leaving the current tool, opening the `About` sheet from `More`, live crossword matches, live anagram matches, live Scrabble rack matches, live Scrabble board-letter matches, live definitions lookup, live thesaurus lookup, and inline invalid-input feedback.

## Notable edge cases

- Repeated live updates with the same query.
- Superseded searches continuing to completion and publishing stale results.
- Unparseable user input.
- Empty input shown in crossword, anagram, or Scrabble results regions.
- Empty input shown in the definitions results region.
- Wildcard input sent to the anagram tool.
- Multi-word input sent to the anagram tool.
- Blank tiles used in the Scrabble rack.
- Unsupported non-rack characters sent to the Scrabble tool.
- Overlong start or end letters sent to the Scrabble tool.
- `Other letters` consuming an edge position only when that edge is otherwise unconstrained.
- The active tool changing unexpectedly when the user opens the in-app preferences control.
- The bottom status bar disappearing behind tool content or keyboard changes.
- The `More` action changing the selected tool or clearing shared input.
- A word-list change allowing results from the previous group to overwrite the current group's results.
- The selected bundled group failing to persist across relaunch.
- Resource loading depending on a bundle path that changes when Xcode reorganizes packaged synchronized-folder contents.
- The `English` grouped resources colliding with `test` resources when the bundle is flattened.
- Invalid record formatting in the bundled definitions dataset.
- Wildcard-heavy input sent to the definitions tool.
- Invalid record formatting in the bundled thesaurus dataset.
- Wildcard-heavy input sent to the thesaurus tool.
- State restoration after app termination or relaunch.
- Unexpected local data values in bundled word lists.
- Large result sets that still need predictable ordering and presentation.

## Maintenance rules

- Any bug found in parsing, local search, persistence, or tab coordination should add or update a test before the fix is considered complete.
- Tests should describe behavior rather than implementation details so refactors do not force broad rewrites.
- Remove or rewrite tests when a feature changes meaning; do not preserve obsolete assertions.
- When a roadmap item graduates from `Now` to `Completed`, update this file so the documented suite matches the shipped feature set.

## Current gaps

- Property testing is still desirable for parser and matcher logic once the current UI slice settles.
- Large-list performance and ranking coverage will need to expand when bigger bundled datasets arrive.
