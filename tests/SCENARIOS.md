# Scenarios

## Current roadmap item

These scenarios describe the current bordered-main-input slice from `PLAN.md` and the `Now` item in `ROADMAP.md`.

## Shared input styling

### Scenario: Show the main field as a primary control
GIVEN the user opens any implemented tool
WHEN the shared main input field appears
THEN it has a visible border treatment that separates it from the page background
AND the field still reads as the primary place to type

## Existing behavior

### Scenario: Keep live tools working after the field border change
GIVEN the user interacts with an implemented solver tool
WHEN the shared main input field has the new border treatment
THEN the existing live search or lookup flow still works as before
AND changing the field styling does not break the shared session state

### Scenario: Keep helper fields visually distinct
GIVEN the user opens the Scrabble tool
WHEN the board-letter helper fields appear below the main field
THEN those helper fields keep their existing lighter styling
AND only the shared main input field gets the stronger primary border treatment

## Offline-only behavior

### Scenario: Use Solver with no network connectivity
GIVEN the device has no network connectivity
WHEN the user types into the shared main input field and uses an implemented tool
THEN the feature works normally using bundled or on-device data
AND the app does not block on connectivity checks or online fallbacks
