import Foundation

struct DefinitionLookupQuery: Hashable, Sendable {
    let lookupKey: String
}

enum DefinitionLookupQueryState: Equatable, Sendable {
    case empty
    case invalid(message: String)
    case valid(DefinitionLookupQuery)

    init(rawInput: String) {
        let trimmed = rawInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else {
            self = .empty
            return
        }

        let collapsed = trimmed
            .split(whereSeparator: \.isWhitespace)
            .joined(separator: " ")
            .lowercased()

        let allowedScalars = CharacterSet.letters
            .union(.whitespaces)
            .union(CharacterSet(charactersIn: "-"))

        guard collapsed.unicodeScalars.allSatisfy(allowedScalars.contains) else {
            self = .invalid(message: "Definitions lookup supports literal words or phrases only, without wildcards or rack symbols.")
            return
        }

        self = .valid(DefinitionLookupQuery(lookupKey: collapsed))
    }
}

struct DefinitionEntry: Hashable, Sendable {
    let word: String
    let pronunciation: String
    let definition: String
    let lookupKey: String
}

struct DefinitionsLookupService: Sendable {
    private let entries: [DefinitionEntry]?
    private let loadingError: Error?

    init(
        bundle: Bundle = .main,
        resourceName: String = "definitions",
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
        let parsedEntries = try? entries.compactMap(Self.parseEntry)
        guard let parsedEntries, parsedEntries.isEmpty == false else {
            self.entries = nil
            self.loadingError = DefinitionsLookupError.emptyDefinitionsList
            return
        }

        self.entries = parsedEntries
        self.loadingError = nil
    }

    func lookup(_ query: DefinitionLookupQuery) async throws -> DefinitionEntry? {
        let entries = try loadEntries()

        return try await CancellableSearchExecution.run {
            try resolveEntry(for: query, in: entries)
        }
    }

    private func loadEntries() throws -> [DefinitionEntry] {
        if let loadingError {
            throw loadingError
        }

        guard let entries else {
            throw DefinitionsLookupError.missingDefinitionsList
        }

        return entries
    }

    private static func loadEntries(
        bundle: Bundle,
        resourceName: String,
        wordListGroup: WordListGroup
    ) throws -> [DefinitionEntry] {
        guard let url = BundledWordListResource.url(
            bundle: bundle,
            baseResourceName: resourceName,
            group: wordListGroup
        ) else {
            throw DefinitionsLookupError.missingDefinitionsList
        }

        let fileContents = try String(contentsOf: url, encoding: .utf8)
        let entries = try fileContents
            .split(whereSeparator: \.isNewline)
            .map(String.init)
            .map(parseEntry)

        guard entries.isEmpty == false else {
            throw DefinitionsLookupError.emptyDefinitionsList
        }

        return entries
    }

    private static func parseEntry(_ rawValue: String) throws -> DefinitionEntry {
        let trimmed = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let fields = trimmed.split(separator: "|", omittingEmptySubsequences: false).map(String.init)

        guard fields.count == 3 else {
            throw DefinitionsLookupError.invalidDefinitionsRecord
        }

        let word = fields[0].trimmingCharacters(in: .whitespacesAndNewlines)
        let pronunciation = fields[1].trimmingCharacters(in: .whitespacesAndNewlines)
        let definition = fields[2].trimmingCharacters(in: .whitespacesAndNewlines)

        guard word.isEmpty == false, pronunciation.isEmpty == false, definition.isEmpty == false else {
            throw DefinitionsLookupError.invalidDefinitionsRecord
        }

        let lookupKey = word
            .lowercased()
            .split(whereSeparator: \.isWhitespace)
            .joined(separator: " ")

        return DefinitionEntry(
            word: word,
            pronunciation: pronunciation,
            definition: definition,
            lookupKey: lookupKey
        )
    }

    private func resolveEntry(
        for query: DefinitionLookupQuery,
        in entries: [DefinitionEntry]
    ) throws -> DefinitionEntry? {
        for (index, entry) in entries.enumerated() {
            try CancellableSearchExecution.checkCancellation(afterProcessedCount: index)

            if entry.lookupKey == query.lookupKey {
                return entry
            }
        }

        return nil
    }
}

enum DefinitionsLookupError: LocalizedError {
    case missingDefinitionsList
    case emptyDefinitionsList
    case invalidDefinitionsRecord

    var errorDescription: String? {
        switch self {
        case .missingDefinitionsList:
            "The bundled definitions list could not be found."
        case .emptyDefinitionsList:
            "The bundled definitions list does not contain any lookup entries."
        case .invalidDefinitionsRecord:
            "The bundled definitions list contains an invalid record."
        }
    }
}
