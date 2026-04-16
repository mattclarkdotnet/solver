# Scenarios

## Current roadmap item

These scenarios describe the current bundled-word-list-group and in-app preference slice from `PLAN.md` and the `Now` item in `ROADMAP.md`.

## Word-list selection

### Scenario: Use the default bundled group
GIVEN the user launches Solver without changing preferences
WHEN the implemented tools load bundled local resources
THEN they all use the default bundled word-list group consistently

### Scenario: Change groups without leaving the current tool
GIVEN the user is using an implemented tool
WHEN they open the compact in-app word-list preferences control and switch groups
THEN the current tool stays selected
AND its visible results refresh against the newly selected bundled group

### Scenario: Persist the bundled group preference
GIVEN the user changes the active bundled word-list group
WHEN the app is terminated and relaunched
THEN Solver restores the same group from on-device storage

## Existing behavior

### Scenario: Keep implemented flows coherent across bundled groups
GIVEN Solver has both `test` and `English` bundled word-list groups
WHEN the user runs crossword, anagram, Scrabble, definitions, or thesaurus flows after changing groups
THEN the visible results reflect the selected bundled data coherently
AND empty, invalid, and no-match states still behave as expected

## Offline-only behavior

### Scenario: Use Solver with no network connectivity
GIVEN the device has no network connectivity
WHEN the user changes the bundled word-list group and uses an implemented tool
THEN the feature works normally using bundled or on-device data
AND the app does not block on connectivity checks or online fallbacks
