# Roadmap

## Now
- Add thesaurus lookup using test thesaurus data.

## Next
- Add "start letter", "end letter" and "other letters" inputs to the scrabble word finder tab

## Later
- Remove the title header
- Make the tool list horizontally scrollable instead of having the "..." for more tools
- Put a border around the main input field
- Add user preferences.
- Add selectable default crossword word lists.
- Add selectable default Scrabble word lists.
- Add word-list management.
- Add real word lists for crosswords
- Add real word lists for scrabble
- Add a real thesaurus
- Add automated behavioral scenario coverage.
- Add parser property tests.
- Add matcher property tests.
- Add regression coverage for the edge cases listed in `TESTING.md`.
- Improve result ranking.
- Improve search performance on large word lists.
- Improve accessibility across solver screens.
- Improve multi-word phrase search quality.

## Completed
- Add definitions lookup using test dictionary data.
- Add Scrabble search using test scrabble word list data.
- Add anagram solving using test crossword word list data.
- Refine the crossword tab into a focused live-search workflow with the pattern field at the top and results updating below inside the existing multi-tool shell.
- Build the first usable offline Solver slice: shared pattern entry and parsing, tab-based app shell, and crossword search against a bundled word list.
- Scaffold the iOS app in Xcode with baseline project documentation (`README.md`, `DESIGN.md`, `TESTING.md`, and `ROADMAP.md`).
