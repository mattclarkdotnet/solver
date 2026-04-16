import Foundation

struct ScrabbleRackQuery: Hashable, Sendable {
    let letters: String
    let blankCount: Int

    var normalizedRack: String {
        letters + String(repeating: "?", count: blankCount)
    }

    var tileCount: Int {
        letters.count + blankCount
    }
}

struct ScrabbleBoardQuery: Hashable, Sendable {
    let startLetter: Character?
    let endLetter: Character?
    let otherLetters: String

    var normalizedDescription: String {
        [
            startLetter.map(String.init) ?? "_",
            otherLetters.isEmpty ? "_" : otherLetters,
            endLetter.map(String.init) ?? "_"
        ].joined(separator: " ")
    }

    var constrainedLettersCount: Int {
        (startLetter == nil ? 0 : 1) + otherLetters.count + (endLetter == nil ? 0 : 1)
    }
}

struct ScrabbleQuery: Hashable, Sendable {
    let rack: ScrabbleRackQuery
    let board: ScrabbleBoardQuery

    var normalizedRack: String {
        rack.normalizedRack
    }

    var normalizedDescription: String {
        board.constrainedLettersCount == 0
            ? rack.normalizedRack
            : "\(rack.normalizedRack) | \(board.normalizedDescription)"
    }
}

enum ScrabbleQueryState: Equatable, Sendable {
    case empty
    case invalid(message: String)
    case valid(ScrabbleQuery)

    init(
        rackInput: String,
        startLetterInput: String,
        endLetterInput: String,
        otherLettersInput: String
    ) {
        switch ScrabbleRackQueryState(rawInput: rackInput) {
        case .empty:
            self = .empty
            return
        case .invalid(let message):
            self = .invalid(message: message)
            return
        case .valid:
            break
        }

        do {
            let board = try ScrabbleQueryState.parseBoardQuery(
                startLetterInput: startLetterInput,
                endLetterInput: endLetterInput,
                otherLettersInput: otherLettersInput
            )

            guard case .valid(let rack) = ScrabbleRackQueryState(rawInput: rackInput) else {
                self = .empty
                return
            }

            self = .valid(ScrabbleQuery(rack: rack, board: board))
        } catch let error as ScrabbleBoardQueryError {
            self = .invalid(message: error.localizedDescription)
        } catch {
            self = .invalid(message: "Scrabble board letters could not be parsed.")
        }
    }

    private static func parseBoardQuery(
        startLetterInput: String,
        endLetterInput: String,
        otherLettersInput: String
    ) throws -> ScrabbleBoardQuery {
        let startLetter = try parseEdgeLetter(
            startLetterInput,
            position: "Start"
        )
        let endLetter = try parseEdgeLetter(
            endLetterInput,
            position: "End"
        )
        let otherLetters = try parseOtherLetters(otherLettersInput)

        return ScrabbleBoardQuery(
            startLetter: startLetter,
            endLetter: endLetter,
            otherLetters: otherLetters
        )
    }

    private static func parseEdgeLetter(
        _ rawValue: String,
        position: String
    ) throws -> Character? {
        let normalized = rawValue
            .lowercased()
            .filter { $0.isWhitespace == false && $0.isNewline == false }

        guard normalized.isEmpty == false else {
            return nil
        }

        guard normalized.count == 1, let character = normalized.first, character.isASCII, character.isLetter else {
            throw ScrabbleBoardQueryError.invalidEdgeLetter(position: position)
        }

        return character
    }

    private static func parseOtherLetters(_ rawValue: String) throws -> String {
        let normalized = rawValue
            .lowercased()
            .filter { $0.isWhitespace == false && $0.isNewline == false }

        guard normalized.allSatisfy({ $0.isASCII && $0.isLetter }) else {
            throw ScrabbleBoardQueryError.invalidOtherLetters
        }

        return normalized
    }
}

enum ScrabbleRackQueryState: Equatable, Sendable {
    case empty
    case invalid(message: String)
    case valid(ScrabbleRackQuery)

    init(rawInput: String) {
        let trimmed = rawInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else {
            self = .empty
            return
        }

        let normalized = rawInput
            .lowercased()
            .filter { $0.isWhitespace == false && $0.isNewline == false }

        var letters: [Character] = []
        var blankCount = 0

        for character in normalized {
            switch character {
            case "a"..."z":
                letters.append(character)
            case "?":
                blankCount += 1
            default:
                self = .invalid(message: "Scrabble search supports rack letters plus ? blank tiles only.")
                return
            }
        }

        guard letters.isEmpty == false || blankCount > 0 else {
            self = .empty
            return
        }

        self = .valid(
            ScrabbleRackQuery(
                letters: String(letters),
                blankCount: blankCount
            )
        )
    }
}

struct ScrabbleMatch: Identifiable, Hashable, Sendable {
    let word: String

    var id: String { word }
    var displayText: String { word.capitalized }
}

struct ScrabbleSearchService: Sendable {
    private let entryLoader: @Sendable () throws -> [ScrabbleEntry]

    init(
        bundle: Bundle = .main,
        resourceName: String = "scrabble_words"
    ) {
        self.entryLoader = {
            try Self.loadEntries(bundle: bundle, resourceName: resourceName)
        }
    }

    init(entries: [String]) {
        let parsedEntries = entries.compactMap(ScrabbleEntry.init)
        self.entryLoader = {
            guard parsedEntries.isEmpty == false else {
                throw ScrabbleSearchError.emptyWordList
            }

            return parsedEntries
        }
    }

    func search(_ query: ScrabbleQuery) async throws -> [ScrabbleMatch] {
        await Task.yield()

        return try loadEntries()
            .filter { entry in
                canFormWord(entry, from: query)
            }
            .sorted { lhs, rhs in
                if lhs.word.count == rhs.word.count {
                    return lhs.word < rhs.word
                }

                return lhs.word.count > rhs.word.count
            }
            .map { ScrabbleMatch(word: $0.word) }
    }

    private func loadEntries() throws -> [ScrabbleEntry] {
        try entryLoader()
    }

    private func canFormWord(_ entry: ScrabbleEntry, from query: ScrabbleQuery) -> Bool {
        guard entry.word.count <= query.rack.tileCount + query.board.constrainedLettersCount else {
            return false
        }

        let characters = Array(entry.word)
        let boardIndexes = matchedBoardIndexes(for: characters, board: query.board)

        guard let boardIndexes else {
            return false
        }

        let rackLetters = characters.enumerated()
            .filter { boardIndexes.contains($0.offset) == false }
            .map(\.element)

        guard rackLetters.count <= query.rack.tileCount else {
            return false
        }

        return rackCanSupply(rackLetters, from: query.rack)
    }

    private func matchedBoardIndexes(
        for characters: [Character],
        board: ScrabbleBoardQuery
    ) -> Set<Int>? {
        guard characters.isEmpty == false else {
            return nil
        }

        var matchedIndexes: Set<Int> = []

        if let startLetter = board.startLetter {
            guard characters.first == startLetter else {
                return nil
            }
            matchedIndexes.insert(0)
        }

        if let endLetter = board.endLetter {
            guard let lastIndex = characters.indices.last, characters[lastIndex] == endLetter else {
                return nil
            }
            matchedIndexes.insert(lastIndex)
        }

        for otherLetter in board.otherLetters {
            guard let matchingIndex = characters.indices.first(where: { index in
                matchedIndexes.contains(index) == false && characters[index] == otherLetter
            }) else {
                return nil
            }

            matchedIndexes.insert(matchingIndex)
        }

        return matchedIndexes
    }

    private func rackCanSupply(
        _ letters: [Character],
        from rack: ScrabbleRackQuery
    ) -> Bool {
        var availableCounts = letterCounts(for: rack.letters)
        var blanksRemaining = rack.blankCount

        for character in letters {
            let available = availableCounts[character, default: 0]
            if available > 0 {
                availableCounts[character] = available - 1
            } else if blanksRemaining > 0 {
                blanksRemaining -= 1
            } else {
                return false
            }
        }

        return true
    }

    private func letterCounts(for letters: String) -> [Character: Int] {
        var counts: [Character: Int] = [:]

        for character in letters {
            counts[character, default: 0] += 1
        }

        return counts
    }

    private static func loadEntries(
        bundle: Bundle,
        resourceName: String
    ) throws -> [ScrabbleEntry] {
        guard let url = bundle.url(forResource: resourceName, withExtension: "txt") else {
            throw ScrabbleSearchError.missingWordList
        }

        let fileContents = try String(contentsOf: url, encoding: .utf8)
        let entries = fileContents
            .split(whereSeparator: \.isNewline)
            .map(String.init)
            .compactMap(ScrabbleEntry.init)

        guard entries.isEmpty == false else {
            throw ScrabbleSearchError.emptyWordList
        }

        return entries
    }
}

enum ScrabbleSearchError: LocalizedError {
    case missingWordList
    case emptyWordList

    var errorDescription: String? {
        switch self {
        case .missingWordList:
            "The bundled Scrabble list could not be found."
        case .emptyWordList:
            "The bundled Scrabble list does not contain any searchable entries."
        }
    }
}

private struct ScrabbleEntry: Hashable, Sendable {
    let word: String

    init?(_ rawValue: String) {
        let normalized = rawValue
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        guard normalized.isEmpty == false else {
            return nil
        }

        let scalars = normalized.unicodeScalars
        guard scalars.allSatisfy(CharacterSet.letters.contains) else {
            return nil
        }

        self.word = normalized
    }
}

private enum ScrabbleBoardQueryError: LocalizedError {
    case invalidEdgeLetter(position: String)
    case invalidOtherLetters

    var errorDescription: String? {
        switch self {
        case .invalidEdgeLetter(let position):
            "\(position) letter must be empty or a single letter."
        case .invalidOtherLetters:
            "Other board letters support literal letters only."
        }
    }
}
