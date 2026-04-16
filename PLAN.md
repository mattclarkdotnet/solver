# Plan

## Roadmap alignment
- This plan delivers the current `ROADMAP.md` `Now` item by adding a real bundled English word-list group and the first user preference for choosing between the existing `test` group and the new `English` group.

## Objective
- Ship offline word-list-group selection so the implemented tools can load either the existing bundled `test` group or a new bundled `English` group based on one shared user preference.

## Assumptions
- This slice should add one new bundled word-list group named `English`; it should not introduce downloadable data, user-imported files, or broader word-list management yet.
- The existing `test` group remains available for deterministic development and test coverage, while the new `English` group is the first more realistic bundled option for end-user solving.
- The group preference should be app-wide for the implemented word-based tools, so crossword, anagram, Scrabble, definitions, and thesaurus all resolve their bundled data from the same selected group.
- The word-list-group preference should live in an in-app preferences surface that is separate from the tool selector, so the user can change groups without leaving the current tool.
- That preferences surface should stay visually secondary to the solver workflow: it must not consume enough space to compete with the main inputs or read like another search or entry field.
- If a richer `English` dataset is not available for one tool, the UI should continue to behave coherently offline and the gap should be handled explicitly in code and tests rather than silently falling back to a different group.

## Scenario mapping
- `Use the default bundled group`: GIVEN the user has not changed preferences, WHEN Solver loads bundled resources, THEN the implemented tools use the default bundled word-list group consistently.
- `Change word lists without leaving the current tool`: GIVEN the user is in an implemented tool, WHEN they open the in-app preferences surface and switch bundled groups, THEN the active tool stays selected and updates against the newly selected group.
- `Switch to the English group`: GIVEN the app has both `test` and `English` bundled word-list groups, WHEN the user selects `English` in preferences, THEN the implemented tools load their local data from the `English` group.
- `Keep tool behavior coherent across groups`: GIVEN the active bundled group changes, WHEN the user runs crossword, anagram, Scrabble, definitions, or thesaurus flows, THEN visible results and empty or invalid states stay coherent with the selected group.
- `Persist the group choice`: GIVEN the user changes the word-list-group preference, WHEN the app is terminated and relaunched, THEN the selected bundled group is restored from on-device storage.
- `Offline operation`: GIVEN the device has no network connectivity, WHEN the user switches bundled groups and uses an implemented tool, THEN the app behaves normally using only local resources.

## Exit criteria
- Add bundled `English` word-list-group resources alongside the existing `test` group under the app’s `Resources/wordlists/` structure.
- Introduce one persisted user preference that selects the active bundled group for the implemented word-based tools.
- Present that preference outside the tool selector, in a compact in-app preferences control that does not look like a primary text-entry affordance.
- Update resource-loading code so implemented tools resolve their bundled data from the currently selected group rather than a hard-coded group.
- Keep offline-only behavior intact, with explicit and testable handling for any tool whose selected-group data is missing or empty.
- Update automated tests and the documentation set to cover group selection, persistence, offline operation, and the new bundled resource layout.

## Promotion rule
- Promote this plan when Solver can switch between bundled `test` and `English` word-list groups through a persisted user preference, the implemented tools load the selected group coherently offline, the change is verified and documented, then move that roadmap item to `Completed`, promote the top `Later` item into `Now`, and replace `PLAN.md` with a new plan for the new `Now` item.
