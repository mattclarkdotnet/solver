# Plan

## Roadmap alignment
- This plan delivers the current `ROADMAP.md` `Now` item by adding offline thesaurus lookup inside the existing multi-tool shell, using bundled test thesaurus data as the first synonym source.

## Objective
- Ship a testable thesaurus workflow that reuses Solver's shared input/session architecture, looks up synonyms from a separate bundled local thesaurus list, and presents useful offline results without introducing network dependencies.

## Assumptions
- Solver remains offline-only, so the thesaurus tool must work entirely from bundled or on-device data.
- “Using test thesaurus data” means this slice can start with a deliberately small bundled dataset rather than a production-grade thesaurus.
- This slice should use a dedicated bundled thesaurus list rather than reusing the crossword, Scrabble, or definitions data files.
- For this slice, thesaurus lookup can target literal word or phrase input and treat wildcard-heavy or rack-style input as invalid for lookup.
- A suitable first thesaurus record should capture the looked-up word or phrase plus a short list of synonyms that can be displayed together in one result card.
- The existing crossword, anagram, Scrabble, and definitions tabs are considered stable enough that this slice should extend the shared shell rather than redesign it.

## Scenario mapping
- `Find synonyms from local data`: GIVEN the bundled test thesaurus contains an entry for the current input, WHEN the user opens the thesaurus tab with that input, THEN the app shows matching offline synonyms.
- `No-result handling`: GIVEN the local test thesaurus contains no entry for the current input, WHEN the user uses the thesaurus tool, THEN the app shows a clear empty state instead of stale synonym results.
- `Unsupported input handling`: GIVEN the current shared input is not suitable for thesaurus lookup, WHEN the thesaurus tab becomes active, THEN the app explains the limitation and avoids misleading output.
- `Shared session coherence`: GIVEN the user edits the current input and switches between implemented tabs, WHEN they return to any tool, THEN each tab stays in sync with the same persisted shared session state.
- `Offline operation`: GIVEN the device has no network connectivity, WHEN the user performs a thesaurus lookup, THEN the tool works normally because it depends only on local parsing, local lookup logic, and bundled test data.

## Exit criteria
- Add a thesaurus lookup service or equivalent pure lookup core that works against a dedicated bundled test thesaurus dataset.
- Define and implement the on-disk thesaurus-list format for this slice so each record can drive a simple offline synonym result.
- Define what kinds of shared input are supported for thesaurus lookup and surface unsupported cases explicitly in the UI.
- Implement the thesaurus tab so it shows loading, empty, invalid, and result states consistent with the current shell.
- Reuse or extend the shared session/query flow without breaking the existing crossword, anagram, Scrabble, or definitions workflows.
- Add automated tests for thesaurus lookup behavior, unsupported input handling, and user-visible thesaurus flows.
- Keep `DESIGN.md`, `TESTING.md`, `tests/SCENARIOS.md`, and `tests/TESTS.md` aligned with the implementation choices for this slice.

## Promotion rule
- Promote this plan when offline thesaurus lookup using the test thesaurus data is implemented, tested, and documented, then move that roadmap item to `Completed`, advance the current `Next` item into `Now`, and replace `PLAN.md` with a new plan for the new `Now` item.
