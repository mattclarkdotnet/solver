# Roadmap

## Now
- Sideload the app onto the developer's mobile phone over a USB cable. Investigate whether this should use Xcode UI or command-line tools, and ship the better first workflow.

## Later
- The app should use a custom keyboard for entry that has the alphabet, space, question mark, underscore, hyphen and asterisk.  It should also have the keyboard hiding button and a delete button.  No shift key or number toggle are required.  
- Add automated behavioral scenario coverage.
- Add parser property tests.
- Add matcher property tests.
- Add regression coverage for the edge cases listed in `TESTING.md`.
- Improve result ranking.
- Improve accessibility across solver screens.
- Improve multi-word phrase search quality.

## Completed
- A long press/hover over a solution should bring up an overlay with the word definition and thesaurus entries
- In the anagram search, hyphens in the input should be taken as word separators, and the results should include multi-word entries from the wordlist, but the position of letters in the input is not significant.  For example "villap-ancho" should return "pancho villa"
- In the crossword search, hyphens and spaces in the input should be taken as word separators, and the results should include multi-word entries from the wordlist.  For example "p????? v????" should return "pancho villa".
- Improve the visual design to reduce clutter such as nested padding of the solutions. The word list control should just be text - no description or icon.  The left hand side of the pattern and the LHS of the solution words should align.  The hamburger menu and wordlist selector shoud float over the list of solutions (so there should be no white background stripe behind them). Look for other improvements to make as well.
- Move the wordlist selector to a "status bar" at the bottom of the screen, where the choice is displayed and clickable.  Also put a hamburger menu in that bottom bar, with the menu items being "preferences", "help" and "about"
- Make live search cancellable so new input interrupts in-flight searches instead of waiting for them to finish
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
