import XCTest
@testable import solver

final class DefinitionsLookupServiceTests: XCTestCase {
    func testFindsDefinitionForExactWord() async throws {
        let service = DefinitionsLookupService(entries: [
            "solver|SOL-vuhr|A person or thing that finds an answer.",
            "scrabble|SKRAB-uhl|To search frantically."
        ])

        let entry = try await service.lookup(DefinitionLookupQuery(lookupKey: "solver"))

        XCTAssertEqual(entry?.word, "solver")
        XCTAssertEqual(entry?.pronunciation, "SOL-vuhr")
        XCTAssertEqual(entry?.definition, "A person or thing that finds an answer.")
    }

    func testFindsDefinitionForPhrase() async throws {
        let service = DefinitionsLookupService(entries: [
            "word game|WURD gaym|A game built around spelling."
        ])

        let entry = try await service.lookup(DefinitionLookupQuery(lookupKey: "word game"))

        XCTAssertEqual(entry?.word, "word game")
    }

    func testReturnsNilWhenDefinitionIsMissing() async throws {
        let service = DefinitionsLookupService(entries: [
            "solver|SOL-vuhr|A person or thing that finds an answer."
        ])

        let entry = try await service.lookup(DefinitionLookupQuery(lookupKey: "crossword"))

        XCTAssertNil(entry)
    }

    func testBuildsValidLookupQueryFromLiteralPhrase() {
        let queryState = DefinitionLookupQueryState(rawInput: "  word   game  ")

        XCTAssertEqual(queryState, .valid(DefinitionLookupQuery(lookupKey: "word game")))
    }

    func testRejectsWildcardHeavyLookupInput() {
        let queryState = DefinitionLookupQueryState(rawInput: "solv?r")

        XCTAssertEqual(
            queryState,
            .invalid(message: "Definitions lookup supports literal words or phrases only, without wildcards or rack symbols.")
        )
    }
}
