# Plan

## Roadmap alignment
- This plan delivers the current `ROADMAP.md` `Now` item by refining the existing Scrabble word finder tab so it keeps the main rack input and adds separate `start letter`, `end letter`, and `other letters` inputs for board constraints.

## Objective
- Ship a testable Scrabble word-finder workflow that keeps the existing offline bundled word-list rack search, while adding board-letter constraints for starting letter, ending letter, and already-placed interior letters.

## Assumptions
- Solver remains offline-only, so the Scrabble finder must continue to work entirely from bundled or on-device data.
- This slice refines the existing Scrabble search tab rather than replacing it with a different tool or data source.
- The current main Scrabble input remains the player's rack, including the existing `?` blank-tile behavior.
- For this slice, `start letter` and `end letter` should each accept zero or one literal letter representing fixed board letters, while `other letters` should accept zero or more literal letters that are already present somewhere in the word from the board.
- A valid Scrabble match for this slice is any bundled test Scrabble word that can be formed using the rack plus the fixed board letters, starts with the chosen start letter when present, ends with the chosen end letter when present, and contains all supplied `other letters` somewhere in the word.
- If `start letter` is empty, an `other letters` character may satisfy the first letter of the word; likewise, if `end letter` is empty, an `other letters` character may satisfy the last letter of the word.
- For example, if the rack is `star` and `other letters` is `e`, then `stare` should be a valid result even though the `e` lands at the end of the word; however, if the rack is `star`, `end letter` is `e`, and `other letters` is also `e`, then `star` must not appear because the explicit end-letter constraint and the separate `other letters` constraint both still need to be satisfied.
- Board letters are constraints supplied by the board state, not tiles consumed from the rack.
- Unsupported characters, multi-character edge fields, and ambiguous interpretation of `other letters` should be treated explicitly rather than inferred silently.
- The existing crossword, anagram, definitions, and thesaurus tabs are considered stable enough that this slice should focus on the Scrabble tab only.

## Scenario mapping
- `Find words with rack plus board constraints`: GIVEN the bundled test Scrabble list contains words matching the current rack and board letters, WHEN the user fills the rack plus `start letter`, `end letter`, or `other letters` on the Scrabble tab, THEN the app shows matching offline words live.
- `Optional-field behavior`: GIVEN one or more of the three board-letter fields are left empty, WHEN the user searches with the remaining rack and board inputs, THEN the app treats the empty board fields as unconstrained rather than failing unnecessarily.
- `No-result handling`: GIVEN the bundled test Scrabble list contains no words that fit the current field combination, WHEN the user edits the Scrabble fields, THEN the app shows a clear empty state instead of stale results.
- `Unsupported input handling`: GIVEN one of the Scrabble fields contains unsupported content, WHEN the Scrabble tab becomes active, THEN the app explains the limitation inline and avoids misleading output.
- `Shared session coherence`: GIVEN the user switches between implemented tabs, WHEN they return to the Scrabble tab, THEN the Scrabble-specific field state remains coherent with the app's persisted on-device session model.
- `Offline operation`: GIVEN the device has no network connectivity, WHEN the user performs a Scrabble word-finder search, THEN the tool works normally because it depends only on local parsing, local search logic, and bundled test data.

## Exit criteria
- Add a Scrabble-specific query model or equivalent pure parsing core that combines the existing rack input with the three new board-letter fields.
- Update the Scrabble tab UI to keep the main rack field and add dedicated `start letter`, `end letter`, and `other letters` fields with live results below.
- Define how empty board fields, unsupported characters, and overlong edge-letter fields behave, and surface invalid cases explicitly in the UI.
- Update the offline Scrabble matching logic so it applies the board-letter constraints without incorrectly consuming those letters from the rack.
- Persist or otherwise preserve the Scrabble tab state coherently without breaking the existing crossword, anagram, definitions, or thesaurus workflows.
- Add automated tests for the new Scrabble query parsing, constrained matching behavior, invalid input handling, and user-visible Scrabble flows.
- Keep `DESIGN.md`, `TESTING.md`, `tests/SCENARIOS.md`, and `tests/TESTS.md` aligned with the implementation choices for this slice.

## Promotion rule
- Promote this plan when the Scrabble word finder supports the existing rack input plus separate start-letter, end-letter, and other-letter board inputs, is implemented, tested, and documented, then move that roadmap item to `Completed`, advance the current `Next` item into `Now`, and replace `PLAN.md` with a new plan for the new `Now` item.
