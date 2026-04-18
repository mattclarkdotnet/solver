# Plan

## Roadmap alignment
- This plan delivers the current `ROADMAP.md` `Now` item by adding a reusable solution-details overlay that can surface bundled definition and thesaurus data from the currently selected word-list group.

## Objective
- Ship a results-overlay slice where long-pressing a visible solution, and hovering it when pointer hover is available, presents an in-app overlay showing that solution's bundled definition and thesaurus entries without leaving the active tool.

## Assumptions
- This slice applies to visible solution rows from the search tools that already render through the shared word-results list, not to the existing definitions or thesaurus lookup screens.
- The overlay should read from the currently selected bundled word-list group only, and missing bundled details should be presented clearly rather than falling back to network access.
- Long press is the primary touch interaction; hover behavior should use the same overlay content when pointer hover is available, without introducing a separate desktop-only interaction model.
- The active tool, current query, and live search results should remain in place behind the overlay.

## Scenario mapping
- `Open solution details from a result row`: GIVEN the user sees a solution in crossword, anagram, or Scrabble results, WHEN they long press that solution or hover it where hover is available, THEN an overlay appears with the bundled definition and thesaurus details for that solution.
- `Handle missing bundled details clearly`: GIVEN the user opens the overlay for a solution that has no bundled definition or no bundled thesaurus entry, WHEN the overlay loads, THEN the overlay explains the missing local detail without failing the whole interaction.
- `Keep the current solving context intact`: GIVEN the user opens and dismisses a solution-details overlay, WHEN they return to the active tool, THEN the current tool, query, and visible results remain unchanged.
- `Keep solution details group-aware and offline`: GIVEN the user switches bundled word-list groups, WHEN they open a solution-details overlay, THEN the shown definition and thesaurus data come only from the selected bundled group and no online fallback is attempted.

## Exit criteria
- Add a reusable solution-details overlay for shared search-result rows, driven by the currently selected bundled definition and thesaurus data.
- Support long-press presentation on touch devices and hover-triggered presentation where pointer hover is available, without changing the underlying search workflows.
- Keep missing local definition or thesaurus data explicit inside the overlay rather than surfacing a generic failure.
- Preserve the existing live-search flows, selected tool, selected word-list group, and offline-only behavior.
- Add or update tests and synced documentation for opening solution details from results and resolving bundled overlay content.

## Promotion rule
- Promote this plan when visible solutions can open a bundled details overlay through long press and pointer hover, the active solving context stays intact after dismissal, missing local details are handled clearly, the behavior is verified offline with tests, and the docs are updated, then move that roadmap item to `Completed` and replace `PLAN.md` for the next `Later` item.
