# Design

## Language and tooling
- use idiomatic Swift
- use xCode compatible project structure
- minimise the use of external dependencies
- target iOS 26 and above

## Product constraints
- Solver is offline-only: shipped features must not require network access at runtime.
- Prefer bundled datasets and on-device processing for search, lookup, ranking, and preferences.
- Design features so they degrade by scope, not connectivity; if data is unavailable locally, the UI should explain that clearly rather than attempting an online fallback.

## Current architecture
- The app is a single iOS target built with SwiftUI and no external runtime dependencies.
- `SolverSession` owns the shared user-facing state for the current pattern and selected tool, and persists both values to on-device storage.
- Pattern handling is split between tool-specific pure query parsers so the same shared input field can be interpreted differently by crossword, anagram, Scrabble, definitions, and thesaurus workflows without duplicating persistence or tab state.
- Solver currently ships five offline tools: live crossword pattern search over a bundled crossword list, anagram solving over that same bundled crossword list for both single-word and phrase entries, rack-based Scrabble search over a bundled test Scrabble list, exact definitions lookup over a separate bundled test definitions list, and exact thesaurus lookup over a separate bundled test thesaurus list.
- Bundled test data now lives under `solver/Resources/wordlists/test/` so later roadmap items can add more word-list families without reshaping the resource layout again.
- Solver now also ships a separate bundled `English` word-list group under `solver/Resources/wordlists/English/`, giving the app one realistic starter group alongside the deterministic `test` group.
- The current test resources share a common single-word vocabulary across the implemented tools, and the crossword test list may also carry extra phrase entries used to exercise crossword and anagram phrase behavior without changing the single-word lookup and Scrabble datasets.
- Resource loading resolves the selected bundled word-list group first and falls back to the bundle root so the app stays robust while the current Xcode synchronized-folder packaging still flattens those files into the app bundle root.
- Each word-based service now stores its parsed bundled entries directly, rather than hiding loading behind closure-based indirection.
- `ContentView` keeps a stable set of service instances for the active word-list group and only rebuilds them when the selected group changes, so typing into the shared input field does not recreate the services or reload bundled data.
- Live search now runs through cancellable background tasks for the implemented tools, so fresh input can interrupt in-flight work and only the latest query is allowed to publish visible state.
- The word-based services perform cooperative cancellation checks while scanning local entries, which keeps the execution model explicit and avoids stale results after rapid typing or word-list changes.
- The UI keeps the multi-tool shell in place with a custom horizontally scrollable tool selector that is pinned to the top safe area, so all tools stay directly reachable on compact devices without falling back to a `More` overflow path or being pushed off-screen by tool scrolling.
- The app now uses floating bottom overlay controls for secondary chrome, keeping the active bundled word-list choice visible and tappable without reserving a full-width stripe behind it.
- The bottom overlay also exposes a compact hamburger-style `More` action that opens lightweight in-app `Preferences`, `Help`, and `About` surfaces without changing the active tool.
- The app shell intentionally avoids a visible top-level `Solver` title header so the first visible content is the active tool workflow rather than repeated app chrome.
- The shared main input field uses a visible rounded border so it reads as the primary editing surface across implemented tools, with a stronger accent outline while focused; Scrabble helper fields keep their lighter secondary styling.
- The visual presentation keeps the shared input and result content aligned on the same left edge, and avoids heavy boxed cards around every result so live states feel lighter and less nested.
- The crossword, anagram, Scrabble, definitions, and thesaurus tabs each drive their results area from a small view-level state machine so empty input, invalid patterns, loading, no-match states, and successful offline matches are all explicit and testable.
- Shared result rows in the crossword, anagram, and Scrabble tools can present a lightweight in-app solution-details overlay from a long press or pointer hover, so local definitions and thesaurus entries are available without navigating away from the active tool.
- The solution-details overlay is coordinated at the shell level rather than inside each row, which keeps the presentation state machine explicit, lets the active results stay visible underneath, and makes the interaction easier to verify in UI tests.
- Solution details are resolved only from the currently selected bundled word-list group by combining the local definitions and thesaurus datasets; when either source has no matching local entry, the overlay explains that clearly instead of attempting any online fallback.
- Crossword search treats spaces and `-` in the shared pattern field as required word separators, and it can match multi-word bundled crossword entries segment-by-segment against those phrase patterns.
- Anagram solving builds on top of the shared parser, accepts literal letters across one or more segments, compares signatures over letters only, and preserves bundled phrase spacing in visible results; wildcard input is still surfaced as explicit guidance instead of being guessed at.
- Scrabble search interprets the shared main input as rack tiles: letters are available tiles, `?` stands in for a blank tile, and the Scrabble tab also persists three tool-specific board-letter fields for fixed start, fixed end, and other letters already on the board.
- Scrabble matching treats board letters as fixed constraints rather than rack tiles to be consumed: explicit start or end letters reserve those word edges, while `other letters` must each match their own remaining position and may only land at the start or end when that edge is otherwise unconstrained.
- Definitions lookup uses a dedicated bundled data file with one record per line in the format `word|pronunciation|short definition`, and the definitions tab treats the shared input as a literal word or phrase lookup key rather than a pattern.
- Thesaurus lookup uses a dedicated bundled data file with one record per line in the format `word|synonym 1, synonym 2, synonym 3`, and the thesaurus tab treats the shared input as a literal word or phrase lookup key rather than a pattern.
