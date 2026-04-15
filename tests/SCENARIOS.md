# Scenarios

## Current roadmap item

These scenarios describe the current Scrabble-search slice from `PLAN.md` and the `Now` item in `ROADMAP.md`.

## Scrabble tab layout

### Scenario: Show a focused Scrabble rack search surface
GIVEN Solver is open on the Scrabble tab
WHEN the screen appears
THEN the pattern entry field is shown at the top of the tab
AND the results region is directly below it
AND there is no separate Scrabble search button

## Live Scrabble results

### Scenario: Find words from any subset of the rack
GIVEN the bundled test Scrabble word list contains words that can be formed from `stare`
WHEN the user enters `stare` in the Scrabble rack field
THEN the app shows matching local Scrabble results that can be formed from any subset of those tiles without requiring a manual search action
AND the results are produced without requiring network access

### Scenario: Use blank tiles in the rack
GIVEN the bundled test Scrabble word list contains words that need one extra letter beyond `crat`
WHEN the user enters `crat?` in the Scrabble rack field
THEN the app treats `?` as a blank tile
AND the app shows words that can be completed using that blank

### Scenario: Show no-results feedback inline
GIVEN the bundled test Scrabble word list contains no words that can be formed from the current rack
WHEN the user enters that rack in the Scrabble field
THEN the app shows an explicit empty-results state in the results region
AND the app does not imply that more results could appear from an online source

## Unsupported and empty input

### Scenario: Handle empty input inline
GIVEN Solver is open on the Scrabble tab
WHEN the user leaves the rack empty
THEN the results region shows guidance for entering a pattern
AND the app does not crash or present misleading results

### Scenario: Reject unsupported rack input
GIVEN Solver is open on the Scrabble tab
WHEN the user enters unsupported characters such as `sta-re`
THEN the app explains that Scrabble search currently supports rack letters plus `?` blank tiles only
AND the app leaves previous results out of the way rather than presenting them as current

## Shared tab state

### Scenario: Keep the current pattern while switching tools
GIVEN the user has entered a valid pattern
WHEN the user switches between available solver tabs
THEN each tab reads the same current query
AND returning to the Scrabble tab shows the same rack in its local entry field

### Scenario: Update all tools after editing the pattern
GIVEN the user has already viewed live Scrabble results
WHEN the user edits the shared pattern through the Scrabble tab
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
WHEN the user enters a valid rack on the Scrabble tab
THEN the feature works normally using bundled or on-device data
AND the app does not block on connectivity checks or online fallbacks

### Scenario: Repeat the same search action
GIVEN the user has a valid pattern selected
WHEN the user repeats the same pattern edits or revisits the same pattern multiple times
THEN the app remains stable
AND repeated updates do not duplicate results or corrupt the shared query state
