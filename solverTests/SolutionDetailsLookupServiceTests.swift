import XCTest
@testable import solver

final class SolutionDetailsLookupServiceTests: XCTestCase {
    func testLoadsBundledDefinitionAndThesaurusForSingleWord() async throws {
        let service = SolutionDetailsLookupService(
            definitionsService: DefinitionsLookupService(entries: [
                "cat|KAT|A small domesticated feline animal."
            ]),
            thesaurusService: ThesaurusLookupService(entries: [
                "cat|feline, kitty, tom"
            ])
        )

        let details = try await service.lookupDetails(for: "Cat")

        XCTAssertEqual(details.displayWord, "Cat")
        XCTAssertEqual(details.definition?.pronunciation, "KAT")
        XCTAssertEqual(details.thesaurus?.synonyms, ["feline", "kitty", "tom"])
    }

    func testLoadsBundledDefinitionAndThesaurusForPhrase() async throws {
        let service = SolutionDetailsLookupService(
            definitionsService: DefinitionsLookupService(entries: [
                "pancho villa|pˈæntʃoʊ vˈɪlə|Mexican revolutionary leader (1878-1923)"
            ]),
            thesaurusService: ThesaurusLookupService(entries: [
                "pancho villa|doroteo arango, francisco villa, villa"
            ])
        )

        let details = try await service.lookupDetails(for: "Pancho Villa")

        XCTAssertEqual(details.definition?.word, "pancho villa")
        XCTAssertEqual(details.thesaurus?.word, "pancho villa")
    }

    func testReturnsEmptyDetailsWhenBundledEntriesAreMissing() async throws {
        let service = SolutionDetailsLookupService(
            definitionsService: DefinitionsLookupService(entries: [
                "cat|KAT|A small domesticated feline animal."
            ]),
            thesaurusService: ThesaurusLookupService(entries: [
                "cat|feline, kitty, tom"
            ])
        )

        let details = try await service.lookupDetails(for: "Unknown")

        XCTAssertFalse(details.hasAnyContent)
        XCTAssertNil(details.definition)
        XCTAssertNil(details.thesaurus)
    }
}
