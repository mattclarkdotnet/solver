# Scenarios

## Current roadmap item

These scenarios describe the current solution-details overlay slice from `PLAN.md` and the `Now` item in `ROADMAP.md`.

## Solution details overlay

### Scenario: Open local details from a shared result row
GIVEN the user can see a crossword, anagram, or Scrabble result row
WHEN they long press or hover over that result
THEN Solver opens an in-app overlay for that solution
AND the overlay shows the bundled definition and bundled thesaurus entries available for the selected word-list group

### Scenario: Keep the active tool and results visible while details are open
GIVEN the user opens a solution-details overlay from a visible result
WHEN the overlay is presented
THEN the active tool, query, and result list remain in place underneath
AND dismissing the overlay returns the user to that same tool state

## Existing behavior

### Scenario: Explain missing local detail records clearly
GIVEN the selected bundled word-list group has no local definition or thesaurus entry for a visible result
WHEN the user opens solution details for that result
THEN the overlay stays available
AND it clearly explains which local details are unavailable

### Scenario: Keep solution details coherent across bundled groups
GIVEN Solver has both `test` and `English` bundled word-list groups
WHEN the user changes groups and opens solution details for a visible result
THEN the overlay resolves details from the selected bundled data only
AND it does not mix records from another group

## Offline-only behavior

### Scenario: Use Solver with no network connectivity
GIVEN the device has no network connectivity
WHEN the user opens solution details for a visible result in either bundled word-list group
THEN the feature works normally using bundled or on-device data
AND the app does not block on connectivity checks or online fallbacks
