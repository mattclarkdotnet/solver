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

    func search(_ query: ScrabbleRackQuery) async throws -> [ScrabbleMatch] {
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

    private func canFormWord(_ entry: ScrabbleEntry, from query: ScrabbleRackQuery) -> Bool {
        guard entry.word.count <= query.tileCount else {
            return false
        }

        var availableCounts = letterCounts(for: query.letters)
        var blanksRemaining = query.blankCount

        for character in entry.word {
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
