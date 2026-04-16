# Scenarios

## Current roadmap item

These scenarios describe the current Scrabble word-finder refinement from `PLAN.md` and the `Now` item in `ROADMAP.md`.

## Scrabble tab layout

### Scenario: Show rack and board inputs together
GIVEN Solver is open on the Scrabble tab
WHEN the screen appears
THEN the main rack field is shown at the top of the tab
AND dedicated `start letter`, `end letter`, and `other letters` board fields are shown below it
AND the results region is directly below it
AND there is no separate Scrabble search button

## Live Scrabble results

### Scenario: Find words from the rack alone
GIVEN the bundled test Scrabble list contains entries that can be made from the current rack
WHEN the user enters rack letters in the main Scrabble field
THEN the app shows matching offline words without requiring a manual search action
AND the results are produced without requiring network access

### Scenario: Use board letters with the rack
GIVEN the bundled test Scrabble list contains a word that needs both rack tiles and board letters
WHEN the user enters rack letters plus one or more board-letter constraints
THEN the app shows only words that satisfy both the rack and the fixed board letters

### Scenario: Show no-results feedback inline
GIVEN the bundled test Scrabble list contains no entry for the current rack and board-letter combination
WHEN the user enters that combination on the Scrabble tab
THEN the app shows an explicit empty-results state in the results region
AND the app does not imply that more results could appear from an online source

## Unsupported and empty input

### Scenario: Handle empty input inline
GIVEN Solver is open on the Scrabble tab
WHEN the user leaves the main rack field empty
THEN the results region shows guidance for entering a pattern
AND the app does not crash or present misleading results

### Scenario: Reject invalid board letters
GIVEN Solver is open on the Scrabble tab
WHEN the user enters an overlong start letter or unsupported `other letters` content
THEN the app explains the limitation inline
AND the app leaves previous results out of the way rather than presenting them as current

## Shared tab state

### Scenario: Keep the current pattern while switching tools
GIVEN the user has entered a valid pattern
WHEN the user switches between available solver tabs
THEN each tab reads the same current query
AND returning to the Scrabble tab shows the same rack value and board-letter fields in their local controls

### Scenario: Update all tools after editing the pattern
GIVEN the user has already viewed live Scrabble results
WHEN the user edits the rack or board letters through the Scrabble tab
THEN the app updates or invalidates dependent tool state consistently
AND no tab continues showing results for the old pattern as if they were current

## Persistence

### Scenario: Restore in-progress work after relaunch
GIVEN the user has entered a pattern and selected a solver tab
WHEN the app is terminated and relaunched during normal use
THEN the app restores the most recent persisted pattern and selected tool
AND restored state comes entirely from on-device storage

## Offline-only behavior

### Scenario: Use Solver with no network connectivity
GIVEN the device has no network connectivity
WHEN the user enters a valid rack and board-letter combination on the Scrabble tab
THEN the feature works normally using bundled or on-device data
AND the app does not block on connectivity checks or online fallbacks

### Scenario: Repeat the same search action
GIVEN the user has a valid pattern selected
WHEN the user repeats the same pattern edits or revisits the same pattern multiple times
THEN the app remains stable
AND repeated updates do not duplicate results or corrupt the shared query state
