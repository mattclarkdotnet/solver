# Scenarios

## Current roadmap item

These scenarios describe the current crossword-tab refinement from `PLAN.md` and the `Now` item in `ROADMAP.md`.

## Crossword tab layout

### Scenario: Show a focused crossword search surface
GIVEN Solver is open on the crossword tab
WHEN the screen appears
THEN the pattern entry field is shown at the top of the tab
AND the results region is directly below it
AND there is no separate crossword search button

## Live crossword results

### Scenario: Update matches while typing
GIVEN the bundled crossword word list contains entries that match `c?t`
WHEN the user enters `c?t` in the crossword pattern field
THEN the app shows matching local results without requiring a manual search action
AND the results are produced without requiring network access

### Scenario: Show no-results feedback inline
GIVEN the bundled crossword word list contains no entries that match the current pattern
WHEN the user enters that pattern in the crossword field
THEN the app shows an explicit empty-results state in the results region
AND the app does not imply that more results could appear from an online source

## Invalid and empty input

### Scenario: Handle empty input inline
GIVEN Solver is open on the crossword tab
WHEN the user leaves the pattern empty
THEN the results region shows guidance for entering a pattern
AND the app does not crash or present misleading results

### Scenario: Handle unparseable input inline
GIVEN Solver is open on the crossword tab
WHEN the user enters a pattern the parser cannot convert into a valid query
THEN the app explains that the pattern cannot be used in the results region
AND the app leaves previous results out of the way rather than presenting them as current

## Shared tab state

### Scenario: Keep the current pattern while switching tools
GIVEN the user has entered a valid pattern
WHEN the user switches between available solver tabs
THEN each tab reads the same current query
AND returning to the crossword tab shows the same pattern in its local entry field

### Scenario: Update all tools after editing the pattern
GIVEN the user has already viewed live crossword results
WHEN the user edits the shared pattern through the crossword tab
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
WHEN the user enters a valid pattern on the crossword tab
THEN the feature works normally using bundled or on-device data
AND the app does not block on connectivity checks or online fallbacks

### Scenario: Repeat the same search action
GIVEN the user has a valid pattern selected
WHEN the user repeats the same pattern edits or revisits the same pattern multiple times
THEN the app remains stable
AND repeated updates do not duplicate results or corrupt the shared query state
