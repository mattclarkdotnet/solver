# Plan

## Roadmap alignment
- This plan delivers the current `ROADMAP.md` `Now` item by adding offline definitions lookup inside the existing multi-tool shell, using bundled test dictionary data as the first definition source.

## Objective
- Ship a testable definitions workflow that reuses Solver's shared input/session architecture, looks up definitions from a separate bundled local definitions list, and presents useful offline results without introducing network dependencies.

## Assumptions
- Solver remains offline-only, so the definitions tool must work entirely from bundled or on-device data.
- “Using test dictionary data” means this slice can start with a deliberately small bundled dataset rather than a production-grade dictionary.
- This slice should use a dedicated bundled definitions list rather than reusing the crossword or Scrabble word lists.
- The bundled definitions list should use a simple record format that captures exactly three fields per entry: the looked-up word, its pronunciation, and one short definition.
- A suitable first format for that list is a plain-text line per entry such as `word|pronunciation|short definition`, which keeps the seed dataset easy to hand-edit and easy to parse in tests.
- For this slice, definitions lookup can reasonably target literal word or phrase input and treat unsupported wildcard-heavy or rack-style input as invalid for lookup.
- The existing crossword, anagram, and Scrabble tabs are considered stable enough that this slice should extend the shared shell rather than redesign it.

## Scenario mapping
- `Find definitions from local data`: GIVEN the bundled test dictionary contains an entry for the current input, WHEN the user opens the definitions tab with that input, THEN the app shows matching offline definition content.
- `No-result handling`: GIVEN the local test dictionary contains no entry for the current input, WHEN the user uses the definitions tool, THEN the app shows a clear empty state instead of stale lookup results.
- `Unsupported input handling`: GIVEN the current shared input is not suitable for definitions lookup, WHEN the definitions tab becomes active, THEN the app explains the limitation and avoids misleading output.
- `Shared session coherence`: GIVEN the user edits the current input and switches between implemented tabs, WHEN they return to any tool, THEN each tab stays in sync with the same persisted shared session state.
- `Offline operation`: GIVEN the device has no network connectivity, WHEN the user performs a definitions lookup, THEN the tool works normally because it depends only on local parsing, local lookup logic, and bundled test data.

## Exit criteria
- Add a definitions lookup service or equivalent pure lookup core that works against a dedicated bundled test definitions dataset.
- Define and implement the on-disk definitions-list format so each record includes a word, a pronunciation, and one short definition.
- Define what kinds of shared input are supported for definitions lookup and surface unsupported cases explicitly in the UI.
- Implement the definitions tab so it shows loading, empty, invalid, and result states consistent with the current shell.
- Reuse or extend the shared session/query flow without breaking the existing crossword, anagram, or Scrabble workflows.
- Add automated tests for definition lookup behavior, unsupported input handling, and user-visible definitions flows.
- Keep `DESIGN.md`, `TESTING.md`, `tests/SCENARIOS.md`, and `tests/TESTS.md` aligned with the implementation choices for this slice.

## Promotion rule
- Promote this plan when offline definitions lookup using the test dictionary data is implemented, tested, and documented, then move that roadmap item to `Completed`, advance the current `Next` item into `Now`, and replace `PLAN.md` with a new plan for the new `Now` item.
