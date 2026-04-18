# Scenarios

## Current roadmap item

These scenarios describe the current live-search cancellation slice from `PLAN.md` and the `Now` item in `ROADMAP.md`.

## Live-search cancellation

### Scenario: Interrupt a running crossword search
GIVEN the user is typing into the crossword pattern field
WHEN a new keystroke arrives before the previous search finishes
THEN the previous search is cancelled
AND only the latest query may update the results region

### Scenario: Keep invalid and empty states immediate
GIVEN the shared input is empty or invalid
WHEN the user edits it
THEN Solver updates the visible state immediately
AND does not wait for background search work to finish first

### Scenario: Ignore stale results after a word-list change
GIVEN a search is in flight for one bundled word-list group
WHEN the user switches to a different bundled word-list group
THEN the current tool stays selected
AND the visible results refresh against the newly selected bundled group
AND stale results from the old group never replace the newer state

## Existing behavior

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
WHEN the user interrupts searches and changes the bundled word-list group while using an implemented tool
THEN the feature works normally using bundled or on-device data
AND the app does not block on connectivity checks or online fallbacks
