# Plan

## Roadmap alignment
- This plan delivers the current `ROADMAP.md` `Now` item by adding offline anagram solving on top of the existing shared pattern/session architecture, using test crossword word-list data as the first dataset.

## Objective
- Ship a testable anagram-solver workflow inside the existing multi-tool shell that accepts the shared query input, searches the local test crossword word list for rearrangements, and presents results without any network dependency.

## Assumptions
- Solver remains offline-only, so the anagram solver must rely entirely on bundled or on-device data.
- The current crossword-tab live-search workflow and shared session behavior are considered stable enough to build on rather than redesign in this slice.
- “Using test crossword word list data” means the first anagram implementation can reuse the existing lightweight bundled dataset rather than waiting for production-grade word lists.
- The anagram tool should favor correctness, clear states, and testability over advanced ranking or performance work, which remain later roadmap items.

## Scenario mapping
- `Find anagrams from local data`: GIVEN the bundled test crossword word list contains rearrangements of a valid input, WHEN the user opens the anagram tool with that input, THEN the app shows matching offline anagram results.
- `No-result handling`: GIVEN the local test word list contains no anagrams for the current input, WHEN the user uses the anagram tool, THEN the app shows a clear empty state instead of stale matches.
- `Invalid and unsupported input`: GIVEN the current shared input cannot be used for an anagram search, WHEN the anagram tool becomes active, THEN the UI explains why and avoids misleading results.
- `Shared session coherence`: GIVEN the user edits the current pattern and switches between crossword and anagram tools, WHEN they return to either tab, THEN both tools stay in sync with the same persisted shared session state.
- `Offline operation`: GIVEN the device has no network connectivity, WHEN the user runs an anagram search, THEN the tool works normally because it uses only local parsing, local matching logic, and bundled test data.

## Exit criteria
- Add an anagram-solving service or equivalent pure matching core that works against the bundled test crossword word list.
- Define how the shared input is interpreted for anagram solving and surface unsupported cases explicitly in the UI.
- Implement the anagram tab so it shows loading, empty, invalid, and result states consistent with the existing shell.
- Reuse or extend the shared session/query flow without breaking the crossword workflow or tab persistence.
- Add automated tests for anagram matching behavior, unsupported input handling, and user-visible anagram flows.
- Keep `DESIGN.md`, `TESTING.md`, `tests/SCENARIOS.md`, and `tests/TESTS.md` aligned with the implementation choices for this slice.

## Promotion rule
- Promote this plan when offline anagram solving using the test crossword word list is implemented, tested, and documented, then move that roadmap item to `Completed`, advance the current `Next` item into `Now`, and replace `PLAN.md` with a new plan for the new `Now` item.
