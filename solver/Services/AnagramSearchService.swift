import Foundation

struct AnagramQuery: Hashable, Sendable {
    let letters: String
    let normalizedInput: String

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
            let segmentLetters = query.segments.map { segment in
                let letters = segment.tokens.compactMap { token -> Character? in
                    if case .literal(let character) = token {
                        character
                    } else {
                        nil
                    }
                }

                return letters.count == segment.tokens.count ? letters : []
            }

            guard segmentLetters.allSatisfy({ $0.isEmpty == false }) else {
                self = .invalid(message: "Anagram solving currently supports letters only, without wildcards.")
                return
            }

            let letters = segmentLetters.flatMap { $0 }
            guard letters.isEmpty == false else {
                self = .invalid(message: "Anagram solving currently supports letters only, without wildcards.")
                return
            }

            self = .valid(
                AnagramQuery(
                    letters: String(letters),
                    normalizedInput: segmentLetters
                        .map { String($0) }
                        .joined(separator: " ")
                )
            )
        }
    }
}

struct AnagramMatch: Identifiable, Hashable, Sendable {
    let text: String

    var id: String { text }
    var displayText: String { text.capitalized }
}

struct AnagramSearchService: Sendable {
    private let entries: [AnagramEntry]?
    private let loadingError: Error?

    init(
        bundle: Bundle = .main,
        resourceName: String = "crossword_words",
        wordListGroup: WordListGroup = .defaultGroup
    ) {
        do {
            self.entries = try Self.loadEntries(
                bundle: bundle,
                resourceName: resourceName,
                wordListGroup: wordListGroup
            )
            self.loadingError = nil
        } catch {
            self.entries = nil
            self.loadingError = error
        }
    }

    init(entries: [String]) {
        let parsedEntries = entries.compactMap(AnagramEntry.init)
        guard parsedEntries.isEmpty == false else {
            self.entries = nil
            self.loadingError = AnagramSearchError.emptyWordList
            return
        }

        self.entries = parsedEntries
        self.loadingError = nil
    }

    func search(_ query: AnagramQuery) async throws -> [AnagramMatch] {
        let entries = try loadEntries()

        return try await CancellableSearchExecution.run {
            try Self.resolveMatches(for: query, in: entries)
        }
    }

    private func loadEntries() throws -> [AnagramEntry] {
        if let loadingError {
            throw loadingError
        }

        guard let entries else {
            throw AnagramSearchError.missingWordList
        }

        return entries
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

    private static func resolveMatches(
        for query: AnagramQuery,
        in entries: [AnagramEntry]
    ) throws -> [AnagramMatch] {
        var matches: [AnagramEntry] = []
        matches.reserveCapacity(min(entries.count, 128))

        for (index, entry) in entries.enumerated() {
            try CancellableSearchExecution.checkCancellation(afterProcessedCount: index)

            if entry.signature == query.signature && entry.normalizedComparisonText != query.normalizedInput {
                matches.append(entry)
            }
        }

        return matches
            .sorted { $0.text < $1.text }
            .map { AnagramMatch(text: $0.text) }
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
    let normalizedComparisonText: String

    nonisolated init?(_ rawValue: String) {
        let normalized = rawValue
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        guard normalized.isEmpty == false else {
            return nil
        }

        let hyphen = UnicodeScalar("-")
        let space = UnicodeScalar(" ")

        var normalizedComparisonScalars: [UnicodeScalar] = []
        var previousScalarWasSeparator = false

        for scalar in normalized.unicodeScalars {
            if CharacterSet.letters.contains(scalar) {
                normalizedComparisonScalars.append(scalar)
                previousScalarWasSeparator = false
                continue
            }

            guard CharacterSet.whitespaces.contains(scalar) || scalar == hyphen else {
                return nil
            }

            guard previousScalarWasSeparator == false, normalizedComparisonScalars.isEmpty == false else {
                continue
            }

            normalizedComparisonScalars.append(space)
            previousScalarWasSeparator = true
        }

        if normalizedComparisonScalars.last == space {
            normalizedComparisonScalars.removeLast()
        }

        let normalizedComparisonText = String(normalizedComparisonScalars.map(Character.init))
        let lettersOnly = normalizedComparisonText.filter(\.isLetter)

        guard lettersOnly.isEmpty == false else {
            return nil
        }

        self.text = normalized
        self.signature = String(lettersOnly.sorted())
        self.normalizedComparisonText = normalizedComparisonText
    }
}
