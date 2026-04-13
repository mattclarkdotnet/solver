# Roadmap

## Now
- Refine the crossword tab into a focused live-search workflow with the pattern field at the top and results updating below inside the existing multi-tool shell.

## Next
- Expand the shared offline query engine to Scrabble search and anagram tools, including selectable default word lists for crossword and Scrabble workflows.

## Later
- Add definitions, thesaurus lookup, and Scrabble word checking behind the same shared offline query experience using bundled data sources.
- Introduce preferences, recent-query persistence, and word-list management so users can control defaults and resume work quickly.
- Strengthen automated quality with behavioral scenarios, parser/search property tests, and regression coverage for edge cases from `TESTING.md`.
- Refine ranking, performance, and accessibility across large word lists and multi-word phrase searches.

## Completed
- Build the first usable offline Solver slice: shared pattern entry and parsing, tab-based app shell, and crossword search against a bundled word list.
- Scaffold the iOS app in Xcode with baseline project documentation (`README.md`, `DESIGN.md`, `TESTING.md`, and `ROADMAP.md`).
