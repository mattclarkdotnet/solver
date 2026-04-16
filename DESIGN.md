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
- Solver currently ships five offline tools: live crossword pattern search over a bundled crossword list, single-word anagram solving over that same test crossword list, rack-based Scrabble search over a bundled test Scrabble list, exact definitions lookup over a separate bundled test definitions list, and exact thesaurus lookup over a separate bundled test thesaurus list.
- Bundled test data now lives under `solver/Resources/wordlists/test/` so later roadmap items can add more word-list families without reshaping the resource layout again.
- The current test crossword, Scrabble, definitions, and thesaurus resources all share the same underlying vocabulary, while definitions and thesaurus preserve their own per-word metadata formats on top of that shared word set.
- Resource loading prefers the `wordlists/test` bundle subdirectory and falls back to the bundle root so the app stays robust while the current Xcode synchronized-folder packaging still flattens those files into the app bundle root.
- The UI keeps the multi-tool shell in place with a custom horizontally scrollable tool selector that is pinned to the top safe area, so all tools stay directly reachable on compact devices without falling back to a `More` overflow path or being pushed off-screen by tool scrolling.
- The app shell intentionally avoids a visible top-level `Solver` title header so the first visible content is the active tool workflow rather than repeated app chrome.
- The shared main input field uses a visible rounded border so it reads as the primary editing surface across implemented tools, with a stronger accent outline while focused; Scrabble helper fields keep their lighter secondary styling.
- The crossword, anagram, Scrabble, definitions, and thesaurus tabs each drive their results area from a small view-level state machine so empty input, invalid patterns, loading, no-match states, and successful offline matches are all explicit and testable.
- Anagram solving builds on top of the shared parser but narrows the supported input shape to one word made of literal letters only; wildcard and multi-word inputs are surfaced as explicit guidance instead of being guessed at.
- Scrabble search interprets the shared main input as rack tiles: letters are available tiles, `?` stands in for a blank tile, and the Scrabble tab also persists three tool-specific board-letter fields for fixed start, fixed end, and other letters already on the board.
- Scrabble matching treats board letters as fixed constraints rather than rack tiles to be consumed: explicit start or end letters reserve those word edges, while `other letters` must each match their own remaining position and may only land at the start or end when that edge is otherwise unconstrained.
- Definitions lookup uses a dedicated bundled data file with one record per line in the format `word|pronunciation|short definition`, and the definitions tab treats the shared input as a literal word or phrase lookup key rather than a pattern.
- Thesaurus lookup uses a dedicated bundled data file with one record per line in the format `word|synonym 1, synonym 2, synonym 3`, and the thesaurus tab treats the shared input as a literal word or phrase lookup key rather than a pattern.
