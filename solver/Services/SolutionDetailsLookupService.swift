import Foundation

struct SolutionDetails: Hashable, Sendable {
    let displayWord: String
    let definition: DefinitionEntry?
    let thesaurus: ThesaurusEntry?

    var hasAnyContent: Bool {
        definition != nil || thesaurus != nil
    }
}

struct SolutionDetailsLookupService: Sendable {
    let definitionsService: DefinitionsLookupService
    let thesaurusService: ThesaurusLookupService

    func lookupDetails(for displayWord: String) async throws -> SolutionDetails {
        async let definition = lookupDefinition(for: displayWord)
        async let thesaurus = lookupThesaurus(for: displayWord)

        return try await SolutionDetails(
            displayWord: displayWord,
            definition: definition,
            thesaurus: thesaurus
        )
    }

    private func lookupDefinition(for displayWord: String) async throws -> DefinitionEntry? {
        guard case .valid(let query) = DefinitionLookupQueryState(rawInput: displayWord) else {
            return nil
        }

        return try await definitionsService.lookup(query)
    }

    private func lookupThesaurus(for displayWord: String) async throws -> ThesaurusEntry? {
        guard case .valid(let query) = ThesaurusLookupQueryState(rawInput: displayWord) else {
            return nil
        }

        return try await thesaurusService.lookup(query)
    }
}
