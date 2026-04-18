# Scenarios

## Current roadmap item

These scenarios describe the current bottom-status-bar slice from `PLAN.md` and the `Now` item in `ROADMAP.md`.

## Bottom status bar

### Scenario: See the active word list at a glance
GIVEN the user is using any implemented solver tool
WHEN the screen is visible
THEN the bottom status bar shows the currently selected bundled word list

### Scenario: Change word lists from the bottom bar
GIVEN the user is in an implemented tool
WHEN they tap the displayed word-list choice in the bottom status bar
THEN they can switch groups without leaving the current tool
AND the current results refresh against the newly selected bundled group

### Scenario: Open secondary actions from the bottom bar
GIVEN the user is on any implemented screen
WHEN they tap the bottom-bar `More` action
THEN they can access in-app `Preferences`, `Help`, and `About` surfaces

## Existing behavior

### Scenario: Keep active-tool context while using secondary chrome
GIVEN the user opens the bottom-bar word-list chooser or one of the secondary sheets
WHEN they dismiss it or make a choice
THEN the current solver tool remains selected
AND the shared input stays coherent

### Scenario: Keep implemented flows coherent across bundled groups
GIVEN Solver has both `test` and `English` bundled word-list groups
WHEN the user runs crossword, anagram, Scrabble, definitions, or thesaurus flows after changing groups
THEN the visible results reflect the selected bundled data coherently
AND empty, invalid, and no-match states still behave as expected

### Scenario: Apply the same cancellation model across implemented tools
GIVEN the user types quickly in crossword, anagram, Scrabble, definitions, or thesaurus
WHEN prior searches are superseded
THEN stale work is cancelled
AND only the latest query may publish state

## Offline-only behavior

### Scenario: Use Solver with no network connectivity
GIVEN the device has no network connectivity
WHEN the user changes the bundled word-list group or opens secondary actions from the bottom status bar while using an implemented tool
THEN the feature works normally using bundled or on-device data
AND the app does not block on connectivity checks or online fallbacks
