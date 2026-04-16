# Scenarios

## Current roadmap item

These scenarios describe the current horizontally scrollable tool-selector slice from `PLAN.md` and the `Now` item in `ROADMAP.md`.

## App shell layout

### Scenario: Show tools without overflow
GIVEN Solver has more tools than fit in the initial visible width
WHEN the tool selector appears
THEN the user can horizontally scroll to reveal more tools
AND the app does not require a `More` or `...` overflow path to reach them

### Scenario: Keep the tool selector pinned while content scrolls
GIVEN the active tool shows vertically scrollable content
WHEN the user scrolls that tool's content
THEN the tool selector remains pinned at the top of the screen
AND the user can still switch tools without scrolling back to the top

## Shared tab state

### Scenario: Select off-screen tools directly
GIVEN a tool starts outside the initially visible portion of the tool selector
WHEN the user scrolls horizontally and selects that tool
THEN the app switches directly to that tool
AND the selected tool remains visually coherent in the selector

### Scenario: Keep tool switching coherent
GIVEN the user switches between available solver tools
WHEN each implemented tool appears
THEN the tool content remains reachable and coherent
AND the shared selected-tool state matches the visible content

## Existing behavior

### Scenario: Keep live tools working after the selector changes
GIVEN the user interacts with an implemented solver tool
WHEN the app uses the horizontally scrollable tool selector
THEN the existing live search or lookup flow still works as before
AND changing the selector does not break the shared session state

## Offline-only behavior

### Scenario: Use Solver with no network connectivity
GIVEN the device has no network connectivity
WHEN the user scrolls the tool selector and uses an implemented tool
THEN the feature works normally using bundled or on-device data
AND the app does not block on connectivity checks or online fallbacks
