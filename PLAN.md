# Plan

## Roadmap alignment
- This plan delivers the current `ROADMAP.md` `Now` item by reshaping the crossword tab into a focused live-search experience while preserving the existing multi-tool shell and offline crossword engine.

## Objective
- Ship a testable iOS 26+ crossword tab that keeps the pattern field at the top, shows live offline results underneath as the pattern changes, and still fits cleanly inside Solver's multi-tool tab shell.

## Assumptions
- Solver is an offline-only app, so every shipped feature in this plan must work entirely from bundled or on-device data.
- The multi-tool shell remains in place for this slice; only the crossword tab layout and behavior are being reworked.
- Other tabs can remain placeholder-driven as long as the shared query model and current persistence behavior continue to work.
- This slice should remove the explicit crossword search action in favor of live updates that stay keyboard-friendly on iPhone while still behaving sensibly on iPad.

## Scenario mapping
- `Crossword tab layout`: GIVEN a user opens the crossword tab, WHEN the screen appears, THEN the pattern field is the first control at the top of the tab and the results area sits directly below it without extra action chrome.
- `Live results`: GIVEN a valid pattern, WHEN the user edits the pattern, THEN the crossword results update automatically from the bundled offline word list without requiring a search button tap.
- `Empty and invalid input handling`: GIVEN the pattern is empty or unparseable, WHEN the crossword tab is visible, THEN the results area shows clear guidance instead of stale or misleading matches.
- `Tab coherence`: GIVEN a user changes the crossword pattern, WHEN they switch between tabs and return, THEN the current pattern and crossword state remain coherent with the shared app session.
- `Basic persistence`: GIVEN the app is backgrounded or relaunched during normal use, WHEN the user returns to the crossword tab, THEN the last pattern and selected tool are restored.
- `Offline operation`: GIVEN the device has no network connectivity, WHEN live crossword results update, THEN the feature continues to work normally because it relies only on local parsing and bundled data.

## Exit criteria
- Keep the multi-tool shell intact while moving the crossword pattern field into the crossword tab's primary content flow.
- Remove the explicit crossword search button and replace it with live result updates driven by the current parsed query.
- Present only the pattern field and the crossword results region as the main crossword-tab content, with empty and invalid states handled inline.
- Preserve the existing offline parser, bundled data source, persistence, and shared session behavior unless a change is required to support the new layout.
- Add or update automated tests for live result updates, empty and invalid live states, and the focused crossword-tab layout.
- Keep `DESIGN.md`, `TESTING.md`, `ROADMAP.md`, and test documentation aligned with the implementation choices for this slice.

## Promotion rule
- Promote this plan when the crossword tab has the focused live-search layout, the behavior is tested and documented, and the roadmap can advance to the next solver capability slice.
