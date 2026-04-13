# Scenarios

## Current roadmap item

These scenarios describe the first usable offline Solver slice from `PLAN.md` and the `Now` item in `ROADMAP.md`.

## Shared pattern entry

### Scenario: Enter a simple crossword pattern
GIVEN Solver is open
WHEN the user enters `c?t`
THEN the app accepts the pattern as valid
AND the shared query state preserves the known letters and wildcard positions

### Scenario: Enter a phrase pattern
GIVEN Solver is open
WHEN the user enters `ice-cream`
THEN the app preserves the word break between terms
AND solver tools receive the same normalized phrase query

### Scenario: Use all supported pattern symbols
GIVEN Solver is open
WHEN the user enters a pattern containing letters, `.`, `?`, spaces, `+`, `*`, and hyphens
THEN the parser interprets each symbol according to `README.md`
AND the app shows the resulting query state consistently across tools

## Crossword search

### Scenario: Find crossword matches from bundled data
GIVEN the bundled crossword word list contains entries that match `c?t`
WHEN the user opens the crossword tab for that pattern
THEN the app shows matching local results
AND the results are produced without requiring network access

### Scenario: Show no-results feedback
GIVEN the bundled crossword word list contains no entries that match the current pattern
WHEN the user performs a crossword search
THEN the app shows an explicit empty-results state
AND the app does not imply that more results could appear from an online source

## Invalid and empty input

### Scenario: Handle empty input
GIVEN Solver is open
WHEN the user leaves the pattern empty
AND opens a solver tool
THEN the app shows guidance for entering a pattern
AND the app does not crash or present misleading results

### Scenario: Handle unparseable input
GIVEN Solver is open
WHEN the user enters a pattern the parser cannot convert into a valid query
THEN the app explains that the pattern cannot be used
AND the app leaves the previous valid results out of the way or clearly marks them as stale

## Shared tab state

### Scenario: Keep the current pattern while switching tools
GIVEN the user has entered a valid pattern
WHEN the user switches between available solver tabs
THEN each tab reads the same current query
AND the entered pattern remains visible at the top of the screen

### Scenario: Update all tools after editing the pattern
GIVEN the user has already viewed crossword results
WHEN the user edits the shared pattern
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
WHEN the user enters a valid pattern and opens an implemented solver tool
THEN the feature works normally using bundled or on-device data
AND the app does not block on connectivity checks or online fallbacks

### Scenario: Repeat the same search action
GIVEN the user has a valid pattern selected
WHEN the user repeats the same search-triggering action multiple times
THEN the app remains stable
AND repeated actions do not duplicate results or corrupt the shared query state
