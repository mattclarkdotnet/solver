# Plan

## Roadmap alignment
- This plan delivers the current `ROADMAP.md` `Now` item by making live search cancellable so fresh input can interrupt work that is already running.

## Objective
- Ship a live-search execution model where typing remains responsive, each new query starts a fresh search task, and any superseded search is cancelled before it can block the user or publish stale results.

## Assumptions
- This slice is about execution behavior, not search quality: the matching rules and visible result ordering should stay the same unless cancellation requires removing a stale-state edge case.
- The implemented live-search tools should all follow the same model once the pattern is proven, even if crossword is used as the first concrete refactor target.
- A cancelled search should quietly disappear; the UI should only show results or failures from the latest active query for the current tool and selected word-list group.
- If search work is chunked or moved off the main actor, the implementation should stay simple, testable, and explicit rather than introducing generalized concurrency abstractions.

## Scenario mapping
- `Interrupt a running crossword search`: GIVEN the user is typing into the crossword pattern field, WHEN a new keystroke arrives before the previous search finishes, THEN the previous search is cancelled and only the latest query may update the UI.
- `Ignore stale results after word-list changes`: GIVEN the user changes the active word-list group while a search is in flight, WHEN the newer search completes, THEN the results shown come only from the currently selected group.
- `Keep invalid and empty states immediate`: GIVEN the shared input is empty or invalid, WHEN the user edits it, THEN Solver updates the visible state immediately without waiting on background search work.
- `Apply the same live-search contract across implemented tools`: GIVEN the user types quickly in crossword, anagram, Scrabble, definitions, or thesaurus, WHEN prior searches are superseded, THEN stale work is cancelled and only the latest query may publish state.
- `Offline operation`: GIVEN the device has no network access, WHEN the user types rapidly and interrupts searches, THEN all cancellation and search behavior still runs entirely on-device.

## Exit criteria
- Refactor live-search execution so each new query starts a distinct async search task and superseded work is cancelled cooperatively.
- Ensure search work can stop mid-flight rather than always running synchronously to completion once started.
- Prevent stale results from older queries or older word-list groups from overwriting the latest visible state.
- Preserve current matching behavior, result ordering, and invalid or empty guidance unless an intentional stale-state fix requires a documented adjustment.
- Add or update automated tests to cover cancellation, latest-query-wins behavior, and word-list-group changes during live search.
- Update the documentation set to describe the live-search execution model and the intended cancellation semantics.

## Promotion rule
- Promote this plan when the implemented live-search tools cancel superseded work, keep typing responsive, only publish the latest query's state, and the behavior is verified and documented, then move that roadmap item to `Completed` and replace `PLAN.md` with a new plan for the next `Later` item.
