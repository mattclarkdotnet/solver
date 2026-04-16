# Scenarios

## Current roadmap item

These scenarios describe the current thesaurus-lookup slice from `PLAN.md` and the `Now` item in `ROADMAP.md`.

## Thesaurus tab layout

### Scenario: Show a focused thesaurus lookup surface
GIVEN Solver is open on the thesaurus tab
WHEN the screen appears
THEN the pattern entry field is shown at the top of the tab
AND the results region is directly below it
AND there is no separate thesaurus search button

## Live thesaurus results

### Scenario: Find synonyms from the bundled thesaurus list
GIVEN the bundled test thesaurus list contains an entry for `solver`
WHEN the user enters `solver` in the thesaurus field
THEN the app shows the local synonym result without requiring a manual search action
AND the results are produced without requiring network access

### Scenario: Show the looked-up term with its synonyms
GIVEN the bundled test thesaurus list contains a record with a word and a synonym list
WHEN the user opens that thesaurus entry
THEN the app shows the looked-up term together with its bundled synonyms in the result view

### Scenario: Show no-results feedback inline
GIVEN the bundled test thesaurus list contains no entry for the current lookup term
WHEN the user enters that term in the thesaurus field
THEN the app shows an explicit empty-results state in the results region
AND the app does not imply that more results could appear from an online source

## Unsupported and empty input

### Scenario: Handle empty input inline
GIVEN Solver is open on the thesaurus tab
WHEN the user leaves the lookup field empty
THEN the results region shows guidance for entering a pattern
AND the app does not crash or present misleading results

### Scenario: Reject unsupported lookup input
GIVEN Solver is open on the thesaurus tab
WHEN the user enters unsupported characters such as `solv?r`
THEN the app explains that thesaurus lookup currently supports literal words or phrases only
AND the app leaves previous results out of the way rather than presenting them as current

## Shared tab state

### Scenario: Keep the current pattern while switching tools
GIVEN the user has entered a valid pattern
WHEN the user switches between available solver tabs
THEN each tab reads the same current query
AND returning to the thesaurus tab shows the same lookup term in its local entry field

### Scenario: Update all tools after editing the pattern
GIVEN the user has already viewed live synonym results
WHEN the user edits the shared pattern through the thesaurus tab
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
WHEN the user enters a valid lookup term on the thesaurus tab
THEN the feature works normally using bundled or on-device data
AND the app does not block on connectivity checks or online fallbacks

### Scenario: Repeat the same search action
GIVEN the user has a valid pattern selected
WHEN the user repeats the same pattern edits or revisits the same pattern multiple times
THEN the app remains stable
AND repeated updates do not duplicate results or corrupt the shared query state
