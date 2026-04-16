import Foundation

struct AnagramQuery: Hashable, Sendable {
    let letters: String

    var signature: String {
        String(letters.sorted())
    }
}

enum AnagramQueryState: Equatable, Sendable {
    case empty
    case invalid(message: String)
    case valid(AnagramQuery)

    init(patternState: PatternQueryState) {
        switch patternState {
        case .empty:
            self = .empty
        case .invalid(let message):
            self = .invalid(message: message)
        case .valid(let query):
            guard query.segments.count == 1 else {
                self = .invalid(message: "Anagram solving currently supports one word at a time.")
                return
            }

            let letters = query.segments[0].tokens.compactMap { token -> Character? in
                if case .literal(let character) = token {
                    character
                } else {
                    nil
                }
            }

            guard letters.count == query.segments[0].tokens.count else {
                self = .invalid(message: "Anagram solving currently supports letters only, without wildcards.")
                return
            }

            self = .valid(AnagramQuery(letters: String(letters)))
        }
    }
}

struct AnagramMatch: Identifiable, Hashable, Sendable {
    let text: String

    var id: String { text }
    var displayText: String { text.capitalized }
}

struct AnagramSearchService: Sendable {
    private let entryLoader: @Sendable () throws -> [AnagramEntry]

    init(
        bundle: Bundle = .main,
        resourceName: String = "crossword_words",
        wordListGroup: WordListGroup = .defaultGroup
    ) {
        self.entryLoader = {
            try Self.loadEntries(
                bundle: bundle,
                resourceName: resourceName,
                wordListGroup: wordListGroup
            )
        }
    }

    init(entries: [String]) {
        let parsedEntries = entries.compactMap(AnagramEntry.init)
        self.entryLoader = {
            guard parsedEntries.isEmpty == false else {
                throw AnagramSearchError.emptyWordList
            }

            return parsedEntries
        }
    }

    func search(_ query: AnagramQuery) async throws -> [AnagramMatch] {
        await Task.yield()

        return try loadEntries()
            .filter { entry in
                entry.signature == query.signature && entry.text != query.letters
            }
            .sorted { $0.text < $1.text }
            .map { AnagramMatch(text: $0.text) }
    }

    private func loadEntries() throws -> [AnagramEntry] {
        try entryLoader()
    }

    private static func loadEntries(
        bundle: Bundle,
        resourceName: String,
        wordListGroup: WordListGroup
    ) throws -> [AnagramEntry] {
        guard let url = BundledWordListResource.url(
            bundle: bundle,
            baseResourceName: resourceName,
            group: wordListGroup
        ) else {
            throw AnagramSearchError.missingWordList
        }

        let fileContents = try String(contentsOf: url, encoding: .utf8)
        let entries = fileContents
            .split(whereSeparator: \.isNewline)
            .map(String.init)
            .compactMap(AnagramEntry.init)

        guard entries.isEmpty == false else {
            throw AnagramSearchError.emptyWordList
        }

        return entries
    }
}

enum AnagramSearchError: LocalizedError {
    case missingWordList
    case emptyWordList

    var errorDescription: String? {
        switch self {
        case .missingWordList:
            "The bundled anagram list could not be found."
        case .emptyWordList:
            "The bundled anagram list does not contain any searchable entries."
        }
    }
}

private struct AnagramEntry: Hashable, Sendable {
    let text: String
    let signature: String

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

        self.text = normalized
        self.signature = String(normalized.sorted())
    }
}
