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
    private let entryLoader: @Sendable () throws -> [DefinitionEntry]

    init(
        bundle: Bundle = .main,
        resourceName: String = "definitions",
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
        let parsedEntries = try? entries.compactMap(Self.parseEntry)
        self.entryLoader = {
            guard let parsedEntries, parsedEntries.isEmpty == false else {
                throw DefinitionsLookupError.emptyDefinitionsList
            }

            return parsedEntries
        }
    }

    func lookup(_ query: DefinitionLookupQuery) async throws -> DefinitionEntry? {
        await Task.yield()

        return try loadEntries().first { entry in
            entry.lookupKey == query.lookupKey
        }
    }

    private func loadEntries() throws -> [DefinitionEntry] {
        try entryLoader()
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
