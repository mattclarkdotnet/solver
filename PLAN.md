# Plan

## Roadmap alignment
- This plan delivers the current `ROADMAP.md` `Now` item by adding a visible border treatment to the shared main input field without changing the current multi-tool shell or live tool workflows.

## Objective
- Ship a clearer, intentionally styled main input field that reads as the primary editing surface across the implemented tools while preserving the current layout and behavior.

## Assumptions
- This slice applies to the shared main input field used for the current pattern, rack, or lookup text; it does not restyle the Scrabble-specific board-letter helper fields.
- The new border should strengthen the field’s visual boundary without making it look disabled, error-only, or visually heavier than the pinned tool selector.
- The field’s accessibility identifier, focus behavior, keyboard behavior, and shared persistence should remain unchanged.
- Offline-only behavior and all existing search or lookup rules should remain unchanged by this visual update.

## Scenario mapping
- `Show the shared field as a primary control`: GIVEN the user opens any implemented tool, WHEN the shared main input field appears, THEN it has a visible border treatment that clearly separates it from the page background.
- `Keep tool-specific behavior unchanged`: GIVEN the user types into the bordered main input field on crossword, Scrabble, anagram, definitions, or thesaurus, WHEN live results update, THEN the border treatment does not change the existing behavior or interaction model.
- `Do not restyle helper inputs unintentionally`: GIVEN the user opens the Scrabble tool, WHEN the board-letter helper fields appear below the main field, THEN those helper fields keep their existing styling unless a small compatibility adjustment is required for visual coherence.
- `Preserve focus and editing`: GIVEN the user taps, types, deletes, or switches tools, WHEN the main field is focused or reused, THEN the border treatment does not interfere with keyboard interaction, scrolling, or state restoration.
- `Offline operation`: GIVEN the device has no network connectivity, WHEN the user types into the bordered main input field, THEN Solver behaves normally because this slice changes presentation only.

## Exit criteria
- Add a visible border treatment to the shared main input field across the implemented tools.
- Keep the field’s current accessibility identifier, focus behavior, persistence, and live-update behavior intact.
- Avoid unintended behavioral or visual regressions in the Scrabble helper fields and the pinned tool selector.
- Add or update automated UI coverage only if the new visual treatment needs explicit regression protection.
- Keep `DESIGN.md`, `TESTING.md`, `tests/SCENARIOS.md`, and `tests/TESTS.md` aligned if this slice changes the documented shell or input styling expectations.

## Promotion rule
- Promote this plan when the shared main input field has the intended border treatment across the implemented tools, the current interaction behavior remains intact, the change is verified and documented, then move that roadmap item to `Completed`, advance the current `Next` item into `Now`, and replace `PLAN.md` with a new plan for the new `Now` item.
