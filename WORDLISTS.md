# Word Lists

This document describes where bundled word lists live in the repository and how each file is formatted.

## Location

Bundled word lists live under:

```text
solver/Resources/wordlists/
```

Each bundled group gets its own subdirectory. Current groups are:

- `solver/Resources/wordlists/test/`
- `solver/Resources/wordlists/English/`

## Group naming

The app currently knows about two bundled groups:

- `test`
  Uses the base filenames directly.
- `English`
  Uses the same logical file types, but each filename is prefixed with `english_`.

Current files are:

```text
solver/Resources/wordlists/test/crossword_words.txt
solver/Resources/wordlists/test/scrabble_words.txt
solver/Resources/wordlists/test/definitions.txt
solver/Resources/wordlists/test/thesaurus.txt

solver/Resources/wordlists/English/english_crossword_words.txt
solver/Resources/wordlists/English/english_scrabble_words.txt
solver/Resources/wordlists/English/english_definitions.txt
solver/Resources/wordlists/English/english_thesaurus.txt
```

The current code maps group plus logical resource name like this:

- `test` + `crossword_words` -> `wordlists/test/crossword_words.txt`
- `English` + `crossword_words` -> `wordlists/English/english_crossword_words.txt`

## File formats

### `crossword_words.txt`

One entry per line.

- letters only
- multi-word entries may use spaces or hyphens
- blank lines are ignored
- entries that do not parse into alphabetic segments are ignored

Examples:

```text
cat
crossword
ice cream
ice-cream
```

Used by:

- crossword search
- anagram solving

### `scrabble_words.txt`

One entry per line.

- letters only
- blank lines are ignored
- non-alphabetic entries are ignored
- entries are treated as single words for rack-based matching

Examples:

```text
crate
stare
table
```

Used by:

- Scrabble search

### `definitions.txt`

One record per line in this exact format:

```text
word|pronunciation|short definition
```

Rules:

- exactly 3 pipe-separated fields
- no field may be empty
- the first field is the lookup key source
- the lookup key is normalized to lowercase and collapsed internal whitespace

Examples:

```text
solver|SOL-vuhr|A person or thing that finds an answer to a problem or puzzle.
word game|WURD gaym|A game built around spelling.
```

Used by:

- definitions lookup

### `thesaurus.txt`

One record per line in this exact format:

```text
word|synonym 1, synonym 2, synonym 3
```

Rules:

- exactly 2 pipe-separated fields
- the word field may not be empty
- the synonym field must produce at least one non-empty comma-separated synonym
- synonyms are trimmed individually
- the lookup key is normalized from the word field only

Examples:

```text
solver|answerer, cracker, decipherer
word game|letter game, spelling game
```

Used by:

- thesaurus lookup

## Behavioral notes

- The selected bundled group is app-wide.
- Crossword, anagram, Scrabble, definitions, and thesaurus all resolve data from the same active group.
- Solver is offline-only, so all shipped word-list data must be bundled with the app.

## Packaging note

The loaders first look in the expected bundle subdirectory, then fall back to the app bundle root. This is intentional: the current Xcode synchronized-folder packaging may flatten these files in the built app bundle even though they are stored under `Resources/wordlists/...` in the repository.

## Adding a new bundled group

To add another bundled group:

1. Create a new subdirectory under `solver/Resources/wordlists/`.
2. Add the four resource files for that group.
3. Follow the naming convention expected by `WordListGroup`.
4. Keep each file in the format described above.
5. Update the group enum and any UI that exposes selectable groups.

## Validation guidance

When changing word lists:

- keep file formatting strict, especially for `definitions.txt` and `thesaurus.txt`
- prefer lowercase word entries unless preserving case is intentional for display content
- keep test data deterministic
- update tests if a changed list affects expected visible results
