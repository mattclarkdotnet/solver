# Plan

## Roadmap alignment
- This plan delivers the current `ROADMAP.md` `Now` item by removing the visible title header from the app shell while preserving the existing multi-tool navigation and layout.

## Objective
- Ship a simpler top-level layout that no longer shows the `Solver` title header above the tool content, without changing the behavior of the implemented tools.

## Assumptions
- This slice removes the currently visible navigation title rather than replacing it with a different heading, toolbar label, or custom in-content header.
- The multi-tool shell, tab structure, shared input behavior, and offline tool workflows should remain otherwise unchanged.
- The first visible controls in each implemented tool should remain the tool-specific content, such as the pattern field or Scrabble board-letter fields, not a replacement title row.
- Navigation infrastructure may stay in place internally if that keeps the implementation simple and does not reintroduce a visible header.
- Existing accessibility for the tool content should be preserved even though the visible title is removed.

## Scenario mapping
- `Launch without title chrome`: GIVEN the app launches into the existing multi-tool shell, WHEN the first implemented tool appears, THEN the screen does not show the visible `Solver` title header above the tool content.
- `Cross-tool layout consistency`: GIVEN the user switches between implemented tools, WHEN each tool screen appears, THEN the visible layout starts with tool content rather than a repeated app title header.
- `No behavioral regression`: GIVEN the user uses crossword, Scrabble, anagram, definitions, or thesaurus workflows, WHEN the title header has been removed, THEN the existing live search and lookup behavior still works as before.
- `Offline operation`: GIVEN the device has no network connectivity, WHEN the app launches or the user switches tools, THEN removing the header has no effect on the offline-only behavior of the implemented features.

## Exit criteria
- Remove the visible top-level `Solver` title header from the current app shell.
- Keep the implemented tools reachable and visually coherent after the header is removed.
- Preserve the existing shared-session behavior, including persisted input and selected tool state.
- Update or add automated UI coverage so launch and implemented tool flows confirm the header is no longer visible.
- Keep `DESIGN.md`, `TESTING.md`, `tests/SCENARIOS.md`, and `tests/TESTS.md` aligned with the new top-level layout if the implementation changes the documented shell structure.

## Promotion rule
- Promote this plan when the app launches and navigates between implemented tools without showing the title header, the existing behaviors remain intact, the change is tested and documented, then move that roadmap item to `Completed`, advance the current `Next` item into `Now`, and replace `PLAN.md` with a new plan for the new `Now` item.
