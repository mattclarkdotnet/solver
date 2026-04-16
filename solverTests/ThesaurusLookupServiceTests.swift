import XCTest
@testable import solver

final class ThesaurusLookupServiceTests: XCTestCase {
    func testFindsSynonymsForExactWord() async throws {
        let service = ThesaurusLookupService(entries: [
            "solver|answerer, cracker, decipherer",
            "scrabble|rummage, scramble, scrawl"
        ])

        let entry = try await service.lookup(ThesaurusLookupQuery(lookupKey: "solver"))

        XCTAssertEqual(entry?.word, "solver")
        XCTAssertEqual(entry?.synonyms, ["answerer", "cracker", "decipherer"])
    }

    func testFindsSynonymsForPhrase() async throws {
        let service = ThesaurusLookupService(entries: [
            "word game|letter game, spelling game"
        ])

        let entry = try await service.lookup(ThesaurusLookupQuery(lookupKey: "word game"))

        XCTAssertEqual(entry?.word, "word game")
        XCTAssertEqual(entry?.synonyms, ["letter game", "spelling game"])
    }

    func testReturnsNilWhenEntryIsMissing() async throws {
        let service = ThesaurusLookupService(entries: [
            "solver|answerer, cracker, decipherer"
        ])

        let entry = try await service.lookup(ThesaurusLookupQuery(lookupKey: "crossword"))

        XCTAssertNil(entry)
    }

    func testBuildsValidLookupQueryFromLiteralPhrase() {
        let queryState = ThesaurusLookupQueryState(rawInput: "  word   game  ")

        XCTAssertEqual(queryState, .valid(ThesaurusLookupQuery(lookupKey: "word game")))
    }

    func testRejectsWildcardHeavyLookupInput() {
        let queryState = ThesaurusLookupQueryState(rawInput: "solv?r")

        XCTAssertEqual(
            queryState,
            .invalid(message: "Thesaurus lookup supports literal words or phrases only, without wildcards or rack symbols.")
        )
    }
}
