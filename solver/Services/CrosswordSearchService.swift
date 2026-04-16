import Foundation

struct CrosswordWordList: Sendable {
    let name: String
    let entries: [CrosswordEntry]
}

struct CrosswordEntry: Identifiable, Hashable, Sendable {
    let text: String
    let segments: [String]

    var id: String { text }
}

struct CrosswordMatch: Identifiable, Hashable, Sendable {
    let entry: CrosswordEntry

    var id: String { entry.id }
    var displayText: String { entry.text.capitalized }
}

struct CrosswordSearchService: Sendable {
    private let wordListLoader: @Sendable () throws -> CrosswordWordList

    init(
        bundle: Bundle = .main,
        resourceName: String = "crossword_words",
        resourceSubdirectory: String? = "wordlists/test"
    ) {
        self.wordListLoader = {
            try Self.loadWordList(
                bundle: bundle,
                resourceName: resourceName,
                resourceSubdirectory: resourceSubdirectory
            )
        }
    }

    init(
        entries: [String],
        name: String = "Inline test list"
    ) {
        let parsedEntries = entries.compactMap(CrosswordEntry.init)
        self.wordListLoader = {
            guard parsedEntries.isEmpty == false else {
                throw CrosswordSearchError.emptyWordList
            }

            return CrosswordWordList(name: name, entries: parsedEntries)
        }
    }

    func search(_ query: PatternQuery) async throws -> [CrosswordMatch] {
        await Task.yield()

        let wordList = try loadWordList()

        return wordList.entries
            .filter { entry in
                PatternMatcher.matches(query: query, candidateSegments: entry.segments)
            }
            .sorted { lhs, rhs in
                if lhs.segments.count == rhs.segments.count {
                    return lhs.text < rhs.text
                }

                return lhs.segments.count < rhs.segments.count
            }
            .map(CrosswordMatch.init(entry:))
    }

    func wordListName() throws -> String {
        try loadWordList().name
    }

    private func loadWordList() throws -> CrosswordWordList {
        try wordListLoader()
    }

    private static func loadWordList(
        bundle: Bundle,
        resourceName: String,
        resourceSubdirectory: String?
    ) throws -> CrosswordWordList {
        guard let url = bundle.url(
            forResource: resourceName,
            withExtension: "txt",
            subdirectory: resourceSubdirectory
        ) ?? bundle.url(forResource: resourceName, withExtension: "txt") else {
            throw CrosswordSearchError.missingWordList
        }

        let fileContents = try String(contentsOf: url, encoding: .utf8)
        let entries = fileContents
            .split(whereSeparator: \.isNewline)
            .map(String.init)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.isEmpty == false }
            .compactMap(CrosswordEntry.init)

        guard entries.isEmpty == false else {
            throw CrosswordSearchError.emptyWordList
        }

        return CrosswordWordList(name: "Bundled test list", entries: entries)
    }
}

enum CrosswordSearchError: LocalizedError {
    case missingWordList
    case emptyWordList

    var errorDescription: String? {
        switch self {
        case .missingWordList:
            "The bundled crossword list could not be found."
        case .emptyWordList:
            "The bundled crossword list does not contain any searchable entries."
        }
    }
}

private enum PatternMatcher {
    static func matches(query: PatternQuery, candidateSegments: [String]) -> Bool {
        // Phrase matching is segment-aware so a hyphen in the pattern maps to a word break in local entries.
        guard query.segments.count == candidateSegments.count else {
            return false
        }

        return zip(query.segments, candidateSegments).allSatisfy { segment, candidate in
            matches(segment.tokens, candidate: Array(candidate))
        }
    }

    // Multi-character wildcards represent a sequence of letters, so they match one or more characters.
    private static func matches(_ tokens: [PatternToken], candidate: [Character]) -> Bool {
        var memo: [MemoKey: Bool] = [:]
        return matches(tokens, candidate: candidate, tokenIndex: 0, characterIndex: 0, memo: &memo)
    }

    private static func matches(
        _ tokens: [PatternToken],
        candidate: [Character],
        tokenIndex: Int,
        characterIndex: Int,
        memo: inout [MemoKey: Bool]
    ) -> Bool {
        let key = MemoKey(tokenIndex: tokenIndex, characterIndex: characterIndex)
        if let result = memo[key] {
            return result
        }

        let result: Bool

        switch (tokenIndex == tokens.count, characterIndex == candidate.count) {
        case (true, true):
            result = true
        case (true, false), (false, true):
            if tokenIndex < tokens.count, tokens[tokenIndex] == .multiWildcard {
                result = false
            } else {
                result = false
            }
        case (false, false):
            switch tokens[tokenIndex] {
            case .literal(let literal):
                result = candidate[characterIndex] == literal
                    && matches(
                        tokens,
                        candidate: candidate,
                        tokenIndex: tokenIndex + 1,
                        characterIndex: characterIndex + 1,
                        memo: &memo
                    )
            case .singleWildcard:
                result = matches(
                    tokens,
                    candidate: candidate,
                    tokenIndex: tokenIndex + 1,
                    characterIndex: characterIndex + 1,
                    memo: &memo
                )
            case .multiWildcard:
                result = (characterIndex + 1...candidate.count).contains { nextIndex in
                    matches(
                        tokens,
                        candidate: candidate,
                        tokenIndex: tokenIndex + 1,
                        characterIndex: nextIndex,
                        memo: &memo
                    )
                }
            }
        }

        memo[key] = result
        return result
    }

    private struct MemoKey: Hashable {
        let tokenIndex: Int
        let characterIndex: Int
    }
}

private extension CrosswordEntry {
    nonisolated init?(_ rawValue: String) {
        let lowercased = rawValue.lowercased()
        let segments = lowercased
            .split(whereSeparator: { $0 == " " || $0 == "-" })
            .map(String.init)

        guard segments.isEmpty == false else {
            return nil
        }

        let allLetters = segments.allSatisfy { segment in
            segment.unicodeScalars.allSatisfy(CharacterSet.letters.contains)
        }

        guard allLetters else {
            return nil
        }

        self.init(text: lowercased, segments: segments)
    }
}
