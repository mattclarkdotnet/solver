# Scenarios

## Current roadmap item

These scenarios describe the current title-header removal slice from `PLAN.md` and the `Now` item in `ROADMAP.md`.

## App shell layout

### Scenario: Launch without the title header
GIVEN Solver is launched
WHEN the screen appears
THEN the visible layout does not show a `Solver` title header above the content
AND the active tool content begins immediately with its own workflow controls

## Shared tab state

### Scenario: Keep the title header absent while switching tools
GIVEN the user switches between available solver tabs
WHEN each implemented tool appears
THEN the visible layout does not show a `Solver` title header
AND the tool content remains reachable and coherent

## Existing behavior

### Scenario: Keep live tools working after the header is removed
GIVEN the user interacts with an implemented solver tool
WHEN the app no longer shows the title header
THEN the existing live search or lookup flow still works as before
AND removing the header does not break the shared session state

## Offline-only behavior

### Scenario: Use Solver with no network connectivity
GIVEN the device has no network connectivity
WHEN the user launches the app and uses an implemented tool
THEN the feature works normally using bundled or on-device data
AND the app does not block on connectivity checks or online fallbacks
