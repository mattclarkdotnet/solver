import Foundation

private func normalizedThesaurusLookupKey(from rawValue: String) -> String {
    rawValue
        .lowercased()
        .split(whereSeparator: \.isWhitespace)
        .joined(separator: " ")
}

struct ThesaurusLookupQuery: Hashable, Sendable {
    let lookupKey: String
}

enum ThesaurusLookupQueryState: Equatable, Sendable {
    case empty
    case invalid(message: String)
    case valid(ThesaurusLookupQuery)

    init(rawInput: String) {
        let trimmed = rawInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else {
            self = .empty
            return
        }

        let collapsed = normalizedThesaurusLookupKey(from: trimmed)
        let allowedScalars = CharacterSet.letters
            .union(.whitespaces)
            .union(CharacterSet(charactersIn: "-"))

        guard collapsed.unicodeScalars.allSatisfy(allowedScalars.contains) else {
            self = .invalid(message: "Thesaurus lookup supports literal words or phrases only, without wildcards or rack symbols.")
            return
        }

        self = .valid(ThesaurusLookupQuery(lookupKey: collapsed))
    }
}

struct ThesaurusEntry: Hashable, Sendable {
    let word: String
    let synonyms: [String]
    let lookupKey: String
}

struct ThesaurusLookupService: Sendable {
    private let entries: [ThesaurusEntry]?
    private let loadingError: Error?

    init(
        bundle: Bundle = .main,
        resourceName: String = "thesaurus",
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
        let parsedEntries = try? entries.map(Self.parseEntry)
        guard let parsedEntries, parsedEntries.isEmpty == false else {
            self.entries = nil
            self.loadingError = ThesaurusLookupError.emptyThesaurusList
            return
        }

        self.entries = parsedEntries
        self.loadingError = nil
    }

    func lookup(_ query: ThesaurusLookupQuery) async throws -> ThesaurusEntry? {
        let entries = try loadEntries()

        return try await CancellableSearchExecution.run {
            try resolveEntry(for: query, in: entries)
        }
    }

    private func loadEntries() throws -> [ThesaurusEntry] {
        if let loadingError {
            throw loadingError
        }

        guard let entries else {
            throw ThesaurusLookupError.missingThesaurusList
        }

        return entries
    }

    private static func loadEntries(
        bundle: Bundle,
        resourceName: String,
        wordListGroup: WordListGroup
    ) throws -> [ThesaurusEntry] {
        guard let url = BundledWordListResource.url(
            bundle: bundle,
            baseResourceName: resourceName,
            group: wordListGroup
        ) else {
            throw ThesaurusLookupError.missingThesaurusList
        }

        let fileContents = try String(contentsOf: url, encoding: .utf8)
        let entries = try fileContents
            .split(whereSeparator: \.isNewline)
            .map(String.init)
            .map(parseEntry)

        guard entries.isEmpty == false else {
            throw ThesaurusLookupError.emptyThesaurusList
        }

        return entries
    }

    private static func parseEntry(_ rawValue: String) throws -> ThesaurusEntry {
        let trimmed = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let fields = trimmed.split(separator: "|", omittingEmptySubsequences: false).map(String.init)

        guard fields.count == 2 else {
            throw ThesaurusLookupError.invalidThesaurusRecord
        }

        let word = fields[0].trimmingCharacters(in: .whitespacesAndNewlines)
        let synonymField = fields[1].trimmingCharacters(in: .whitespacesAndNewlines)
        let synonyms = synonymField
            .split(separator: ",", omittingEmptySubsequences: false)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.isEmpty == false }

        guard word.isEmpty == false, synonyms.isEmpty == false else {
            throw ThesaurusLookupError.invalidThesaurusRecord
        }

        return ThesaurusEntry(
            word: word,
            synonyms: synonyms,
            lookupKey: normalizedThesaurusLookupKey(from: word)
        )
    }

    private func resolveEntry(
        for query: ThesaurusLookupQuery,
        in entries: [ThesaurusEntry]
    ) throws -> ThesaurusEntry? {
        for (index, entry) in entries.enumerated() {
            try CancellableSearchExecution.checkCancellation(afterProcessedCount: index)

            if entry.lookupKey == query.lookupKey {
                return entry
            }
        }

        return nil
    }
}

enum ThesaurusLookupError: LocalizedError {
    case missingThesaurusList
    case emptyThesaurusList
    case invalidThesaurusRecord

    var errorDescription: String? {
        switch self {
        case .missingThesaurusList:
            "The bundled thesaurus list could not be found."
        case .emptyThesaurusList:
            "The bundled thesaurus list does not contain any lookup entries."
        case .invalidThesaurusRecord:
            "The bundled thesaurus list contains an invalid record."
        }
    }
}
