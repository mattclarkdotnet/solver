# Scenarios

## Current roadmap item

These scenarios describe the current anagram-solver slice from `PLAN.md` and the `Now` item in `ROADMAP.md`.

## Anagram tab layout

### Scenario: Show a focused anagram search surface
GIVEN Solver is open on the anagram tab
WHEN the screen appears
THEN the pattern entry field is shown at the top of the tab
AND the results region is directly below it
AND there is no separate anagram search button

## Live anagram results

### Scenario: Find anagrams from the bundled test crossword list
GIVEN the bundled test crossword word list contains anagrams for `stare`
WHEN the user enters `stare` in the anagram pattern field
THEN the app shows matching local anagram results without requiring a manual search action
AND the results are produced without requiring network access

### Scenario: Show no-results feedback inline
GIVEN the bundled test crossword word list contains no anagrams for the current letters
WHEN the user enters that input in the anagram field
THEN the app shows an explicit empty-results state in the results region
AND the app does not imply that more results could appear from an online source

## Unsupported and empty input

### Scenario: Handle empty input inline
GIVEN Solver is open on the anagram tab
WHEN the user leaves the pattern empty
THEN the results region shows guidance for entering a pattern
AND the app does not crash or present misleading results

### Scenario: Reject wildcard input for anagram solving
GIVEN Solver is open on the anagram tab
WHEN the user enters a wildcard pattern such as `st?re`
THEN the app explains that anagram solving currently supports letters only
AND the app leaves previous results out of the way rather than presenting them as current

### Scenario: Reject multi-word input for anagram solving
GIVEN Solver is open on the anagram tab
WHEN the user enters a multi-word pattern such as `ice-cream`
THEN the app explains that anagram solving currently supports one word at a time
AND the app does not attempt to guess a phrase anagram search

## Shared tab state

### Scenario: Keep the current pattern while switching tools
GIVEN the user has entered a valid pattern
WHEN the user switches between available solver tabs
THEN each tab reads the same current query
AND returning to the anagram tab shows the same pattern in its local entry field

### Scenario: Update all tools after editing the pattern
GIVEN the user has already viewed live anagram results
WHEN the user edits the shared pattern through the anagram tab
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
WHEN the user enters valid letters on the anagram tab
THEN the feature works normally using bundled or on-device data
AND the app does not block on connectivity checks or online fallbacks

### Scenario: Repeat the same search action
GIVEN the user has a valid pattern selected
WHEN the user repeats the same pattern edits or revisits the same pattern multiple times
THEN the app remains stable
AND repeated updates do not duplicate results or corrupt the shared query state
