# Plan

## Roadmap alignment
- This plan delivers the current `ROADMAP.md` `Now` item by replacing the Xcode placeholder UI with the first production slice of Solver: shared pattern entry, parsing, tab navigation, and crossword search backed entirely by bundled offline word-list data.

## Objective
- Ship a testable vertical slice of Solver for iOS 26+ that lets a user enter a word pattern, understand how it is interpreted, switch between solver tabs, and get crossword search results from bundled on-device data with no network dependency.

## Assumptions
- Solver is an offline-only app, so every shipped feature in this plan must work entirely from bundled or on-device data.
- Definitions, thesaurus, and Scrabble validation can be deferred until later roadmap items even if the UI reserves space for those tools.
- The first implementation should prioritize iPhone usability while remaining compatible with iPad layouts.
- `SCENARIOS.md` and `TESTS.md` will be created alongside the implementation work for this roadmap item.

## Scenario mapping
- `Pattern entry and parsing`: GIVEN a user enters letters, single-letter wildcards, multi-letter wildcards, and hyphenated phrases, WHEN the pattern is parsed, THEN the app preserves the intended structure and exposes a normalized query for solver features.
- `Crossword results from shared query`: GIVEN a valid pattern, WHEN the user opens the crossword tab, THEN the app returns matching words or phrases from the selected crossword word list.
- `Offline operation`: GIVEN the device has no network connectivity, WHEN the user uses the implemented solver features, THEN the app continues to function normally because the feature uses only local data and logic.
- `Empty and invalid input handling`: GIVEN an empty or unparseable pattern, WHEN the user attempts to search, THEN the app shows clear guidance instead of misleading results or crashes.
- `Tab coherence`: GIVEN a user changes the current pattern, WHEN they switch between tabs, THEN each tool reads the same shared query state without losing the current input.
- `Basic persistence`: GIVEN the app is backgrounded or relaunched during normal use, WHEN the user returns, THEN the last active pattern and selected tool are restored if persistence has already been completed for this slice.

## Exit criteria
- Replace the scaffolded `Item` sample with a production app shell built around a shared solver query model.
- Implement a parser for the README word-pattern syntax, including letters, `.`, `?`, spaces, `+`, `*`, and hyphens.
- Add a crossword search engine over at least one bundled word list and surface ranked or grouped results in the UI.
- Provide loading, empty, and invalid-input states that are explicit and testable.
- Add unit tests for parsing and search behavior, including repeated events and unparseable input.
- Prove the implemented feature set has no runtime dependency on network access.
- Add behavioral scenarios and test-suite documentation in `tests/SCENARIOS.md` and `tests/TESTS.md`.
- Keep `DESIGN.md`, `TESTING.md`, `ROADMAP.md`, and code comments aligned with the implementation choices for this slice.

## Promotion rule
- Promote this plan when the `Now` roadmap item is complete, tested, and documented; then move that item to `Completed`, advance the current `Next` item into `Now`, and replace `PLAN.md` with a new plan for the new `Now` item.
