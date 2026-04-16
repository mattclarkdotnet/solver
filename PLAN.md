# Plan

## Roadmap alignment
- This plan delivers the current `ROADMAP.md` `Now` item by replacing the current overflowing tab behavior with a horizontally scrollable tool list that keeps all tools directly reachable without the `...` overflow path.

## Objective
- Ship a multi-tool selector that scrolls horizontally to reveal all tools in one continuous list while preserving the existing tool-selection behavior and implemented tool workflows.

## Assumptions
- This slice changes the tool-selection UI only; it does not add, remove, rename, or reorder solver tools beyond what is necessary to present them in a horizontally scrollable list.
- The intended outcome is that users can reach tools like `Define` and `Thesaurus` directly from the main tool list, without first opening a `More` or `...` overflow destination.
- The scrollable tool list should continue to reflect and control the shared selected-tool state already stored in `SolverSession`.
- The horizontal tool selector should remain usable on compact iPhone layouts and should not hide the currently selected tool when switching between implemented and placeholder tools.
- Offline-only behavior, shared query persistence, and the existing live tool content should remain unchanged by this UI refactor.

## Scenario mapping
- `Show all tools without overflow`: GIVEN Solver has more tools than can fit on screen at once, WHEN the tool selector appears, THEN the user can horizontally scroll to reveal additional tools instead of using a `...` overflow path.
- `Select an off-screen tool directly`: GIVEN a tool starts outside the initially visible portion of the selector, WHEN the user scrolls horizontally and taps that tool, THEN Solver switches directly to that tool.
- `Keep selected tool visible`: GIVEN the user switches to a tool that is not initially visible, WHEN the tool becomes selected, THEN the selector keeps that selection visually coherent rather than losing track of it.
- `No behavioral regression`: GIVEN the user selects crossword, Scrabble, anagram, definitions, thesaurus, or a placeholder tool, WHEN the selector becomes horizontally scrollable, THEN the chosen tool still shows the same content and behavior as before.
- `Offline operation`: GIVEN the device has no network connectivity, WHEN the user scrolls the tool list and changes tools, THEN the app behaves normally because the selector refactor depends only on local UI state.

## Exit criteria
- Replace the current overflowing tab presentation with a horizontally scrollable tool list that exposes all tools directly.
- Preserve the shared selected-tool state so switching tools still updates the active content correctly.
- Ensure implemented tools remain reachable without a `More` or `...` overflow interaction.
- Add or update automated UI coverage so tool selection works through the new horizontally scrollable list.
- Keep `DESIGN.md`, `TESTING.md`, `tests/SCENARIOS.md`, and `tests/TESTS.md` aligned with the new app-shell navigation behavior.

## Promotion rule
- Promote this plan when all tools are reachable from a horizontally scrollable selector without overflow navigation, the existing tool behavior remains intact, the change is tested and documented, then move that roadmap item to `Completed`, advance the current `Next` item into `Now`, and replace `PLAN.md` with a new plan for the new `Now` item.
