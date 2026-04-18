# Roadmap

## Now
- Make live search cancellable so new input interrupts in-flight searches instead of waiting for them to finish

## Later
- Improve search performance on large word lists.
- Add selectable word lists.
- Add word-list management.
- Add automated behavioral scenario coverage.
- Add parser property tests.
- Add matcher property tests.
- Add regression coverage for the edge cases listed in `TESTING.md`.
- Improve result ranking.
- Improve accessibility across solver screens.
- Improve multi-word phrase search quality.

## Completed
- Add a real English word list group, and a user preference to choose which group ("test" or "English") to use
- ensure the test word lists all contain the same words, and move them to a folder inside Resources named "wordlists/test/", in preparation for adding more wordlists
- Put a border around the main input field
- Make the tool list horizontally scrollable instead of having the "..." for more tools
- Remove the title header
- Add "start letter", "end letter" and "other letters" inputs to the scrabble word finder tab
- Add thesaurus lookup using test thesaurus data.
- Add definitions lookup using test dictionary data.
- Add Scrabble search using test scrabble word list data.
- Add anagram solving using test crossword word list data.
- Refine the crossword tab into a focused live-search workflow with the pattern field at the top and results updating below inside the existing multi-tool shell.
- Build the first usable offline Solver slice: shared pattern entry and parsing, tab-based app shell, and crossword search against a bundled word list.
- Scaffold the iOS app in Xcode with baseline project documentation (`README.md`, `DESIGN.md`, `TESTING.md`, and `ROADMAP.md`).
