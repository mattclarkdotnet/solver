# Plan

## Roadmap alignment
- This plan delivers the current `ROADMAP.md` `Now` item by consolidating the app’s bundled test word lists around the same set of words and relocating them into `Resources/wordlists/test/` so later multi-wordlist work has a cleaner base.

## Objective
- Ship a consistent test-wordlist layout and loading scheme that keeps the current offline tools working while preparing the resource structure for additional bundled word lists.

## Assumptions
- This slice applies only to the bundled test word lists used by the currently implemented word-based tools; it should not add real production dictionaries or change roadmap scope beyond test-data consistency and file placement.
- “Contain the same words” means the test crossword, Scrabble, definitions, and thesaurus datasets should all be based on the same shared vocabulary, while still preserving each tool’s format-specific metadata such as pronunciations, definitions, and synonym lists.
- The resource reorganization should keep everything offline-only and should not introduce runtime discovery of external files or user-managed lists yet.
- Tool behavior may change only as needed to stay consistent with the new shared test vocabulary; any removed or added words should be reflected in tests and docs rather than worked around in code.

## Scenario mapping
- `Use a shared test vocabulary`: GIVEN the implemented offline tools rely on bundled test data, WHEN the app loads crossword, Scrabble, definitions, and thesaurus resources, THEN those resources are based on the same set of test words.
- `Load moved resources successfully`: GIVEN the test word lists move under `Resources/wordlists/test/`, WHEN each tool starts a search or lookup, THEN it still loads its bundled test data successfully from the new location.
- `Keep format-specific metadata intact`: GIVEN definitions and thesaurus use richer per-word records, WHEN the shared vocabulary is aligned, THEN those files still preserve pronunciations, short definitions, and synonym lists in their existing formats.
- `Keep implemented tool behavior coherent`: GIVEN the shared test vocabulary changes some bundled words, WHEN the user runs implemented solver flows, THEN the visible results, empty states, and invalid-input handling remain coherent and testable.
- `Offline operation`: GIVEN the device has no network connectivity, WHEN the app loads any bundled test word list from the new folder structure, THEN it behaves normally using only local resources.

## Exit criteria
- Move the bundled test word lists into `solver/Resources/wordlists/test/` or the equivalent Xcode-backed location under `Resources`.
- Update resource-loading code so each implemented tool resolves its moved test data correctly.
- Align the test word lists around the same shared vocabulary, preserving tool-specific record formats where needed.
- Update automated tests to reflect any changed resource paths or expected results caused by the new shared test vocabulary.
- Keep `DESIGN.md`, `TESTING.md`, `tests/SCENARIOS.md`, and `tests/TESTS.md` aligned with the new resource structure and shared test-data assumptions.

## Promotion rule
- Promote this plan when the bundled test word lists live under the new `wordlists/test` resource structure, the implemented tools still load and use them correctly, the shared test vocabulary is consistent across those files, the change is verified and documented, then move that roadmap item to `Completed`, advance the current `Next` item into `Now`, and replace `PLAN.md` with a new plan for the new `Now` item.
