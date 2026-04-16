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
    private let entryLoader: @Sendable () throws -> [ThesaurusEntry]

    init(
        bundle: Bundle = .main,
        resourceName: String = "thesaurus"
    ) {
        self.entryLoader = {
            try Self.loadEntries(bundle: bundle, resourceName: resourceName)
        }
    }

    init(entries: [String]) {
        let parsedEntries = try? entries.map(Self.parseEntry)
        self.entryLoader = {
            guard let parsedEntries, parsedEntries.isEmpty == false else {
                throw ThesaurusLookupError.emptyThesaurusList
            }

            return parsedEntries
        }
    }

    func lookup(_ query: ThesaurusLookupQuery) async throws -> ThesaurusEntry? {
        await Task.yield()

        return try loadEntries().first { entry in
            entry.lookupKey == query.lookupKey
        }
    }

    private func loadEntries() throws -> [ThesaurusEntry] {
        try entryLoader()
    }

    private static func loadEntries(
        bundle: Bundle,
        resourceName: String
    ) throws -> [ThesaurusEntry] {
        guard let url = bundle.url(forResource: resourceName, withExtension: "txt") else {
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
