# Scenarios

## Current roadmap item

These scenarios describe the current bundled-test-wordlist consolidation slice from `PLAN.md` and the `Now` item in `ROADMAP.md`.

## Shared bundled data

### Scenario: Use the same test vocabulary across implemented tools
GIVEN Solver ships bundled test data for crossword, Scrabble, definitions, and thesaurus
WHEN the implemented tools load their local resources
THEN those resources are all based on the same set of test words
AND any format-specific metadata still maps onto that same shared vocabulary

### Scenario: Load test resources from the reorganized folder structure
GIVEN the bundled test data lives under `Resources/wordlists/test/`
WHEN the user opens an implemented tool and triggers search or lookup
THEN the tool loads its bundled local data successfully
AND the resource reorganization is invisible to the user-facing workflow

## Existing behavior

### Scenario: Keep implemented flows coherent after vocabulary alignment
GIVEN the shared bundled vocabulary adds or removes words compared with older seed files
WHEN the user runs crossword, anagram, Scrabble, definitions, or thesaurus flows
THEN the visible results reflect the new shared test data coherently
AND empty, invalid, and no-match states still behave as expected

## Offline-only behavior

### Scenario: Use Solver with no network connectivity
GIVEN the device has no network connectivity
WHEN the user types into the app and uses an implemented tool
THEN the feature works normally using bundled or on-device data
AND the app does not block on connectivity checks or online fallbacks
