# Tests

## Purpose

This document explains how the automated test suite should support the strategy in `TESTING.md` for the current roadmap item. It is intentionally scoped to the current solution-details overlay slice described in `PLAN.md`.

## Test layers

- Parser unit tests cover normalization of the current crossword pattern syntax, including letters, single-character wildcards, multi-character wildcards, and spaces or hyphens as word separators.
- Search engine unit tests cover matching behavior against bundled local datasets, including single-word crossword matching, multi-word crossword matching, single-word and phrase anagram matching, Scrabble rack-plus-board matching, definitions lookup, thesaurus lookup, no-match cases, and repeated searches.
- State-model tests cover the shared query state, persisted launch behavior, and invalidation rules when the pattern changes.
- Persistence tests cover saving and restoring the current pattern, Scrabble-specific board fields, selected tool, and selected bundled word-list group using on-device storage only.
- Resource-contract tests cover loading bundled files from the selected group and verifying the implemented tools continue to resolve the chosen group coherently, including phrase-capable crossword data.
- Concurrency unit tests cover cooperative cancellation of long-running local searches and the latest-query-wins rule for superseded work.
- Lookup-composition unit tests cover combining local definition and thesaurus records into a single solution-details payload for displayed result words or phrases.
- UI or behavioral tests cover the user-visible flows in `SCENARIOS.md`, especially opening solution details from shared result rows, handling missing local details clearly, preserving the active tool state, and remaining offline under the selected group.

## Current coverage target

- Start with fast unit tests for parsing, crossword matching, anagram matching, Scrabble rack-plus-board matching, definitions lookup, and thesaurus lookup because they define the core behavior of the currently implemented tools.
- Keep cancellation coverage focused on the local search engines so regressions in execution behavior are caught without relying only on slower end-to-end tests.
- Add or update resource-loading coverage so group selection between `test` and `English` does not silently break bundled-data access.
- Keep the existing behavioral coverage for implemented tools so solution-details overlays do not weaken the current single-session confidence across the rest of the app.
- Prefer asserting behavior through stable local fixtures and bundled seed data rather than inspecting packaging details directly from UI tests.
- Prefer fixtures built from small local word lists so tests stay deterministic and easy to understand.
- Keep network usage out of the test harness; offline-only behavior should be the default test environment, not a special-case mode.

## Initial suite outline

- `PatternParserTests`
  Covers valid patterns, invalid patterns, normalization, and edge cases around wildcard combinations.
- `CrosswordSearchTests`
  Covers exact-length matching, space-separated and hyphen-separated phrase matching, no-results behavior, stability under repeated searches, and cooperative cancellation of long-running scans.
- `AnagramSearchTests`
  Covers exact-letter anagram matching, phrase anagram matching, exclusion of the source word or phrase, unsupported wildcard input, and filtering of non-anagram entries from the local dataset.
- `ScrabbleSearchTests`
  Covers subset-of-rack matching, blank-tile substitution, board-letter constraints, invalid Scrabble field input, and word ordering against the local test Scrabble list.
- `SolutionDetailsLookupServiceTests`
  Covers combining local definitions and thesaurus entries for both single words and phrases, plus clear empty-detail behavior when bundled records are missing.
- `DefinitionsLookupTests`
  Covers exact lookup, phrase lookup, unsupported input, and parsing of the bundled definitions-record format.
- `ThesaurusLookupTests`
  Covers exact lookup, phrase lookup, unsupported input, and parsing of the bundled thesaurus-record format.
- `SolverSessionTests`
  Covers shared state updates, selected-tab behavior, bundled-group persistence, and reset behavior for deterministic UI tests.
- `SolverAppUITests`
  Covers top-level user flows from `SCENARIOS.md` in one shared app session, including launch, switching bundled groups without leaving the current tool, live single-word and multi-word crossword matches, opening solution details from a shared result row, opening the `About` sheet from `More`, live single-word and phrase anagram matches, live Scrabble rack matches, live Scrabble board-letter matches, live definitions lookup, live thesaurus lookup, and inline invalid-input feedback.

## Notable edge cases

- Repeated live updates with the same query.
- Superseded searches continuing to completion and publishing stale results.
- Unparseable user input.
- A long press or hover on a shared result row failing to open the in-app overlay.
- The solution-details overlay showing stale data from a previously selected word-list group.
- The solution-details overlay dismissing by replacing or clearing the underlying results instead of preserving the active tool state.
- A result with only a definition or only a thesaurus entry failing to explain the missing local companion record.
- Space-separated or hyphen-separated crossword patterns that should match only phrase entries with the same segment count.
- Empty input shown in crossword, anagram, or Scrabble results regions.
- Empty input shown in the definitions results region.
- Wildcard input sent to the anagram tool.
- Separated phrase input sent to the anagram tool.
- A phrase anagram query returning the exact source phrase instead of only true rearrangements.
- Blank tiles used in the Scrabble rack.
- Unsupported non-rack characters sent to the Scrabble tool.
- Overlong start or end letters sent to the Scrabble tool.
- `Other letters` consuming an edge position only when that edge is otherwise unconstrained.
- The active tool changing unexpectedly when the user opens the in-app preferences control.
- Phrase entries being dropped from the selected crossword word list during loading.
- A multi-word crossword query accidentally matching a single-word entry or the wrong phrase shape.
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
