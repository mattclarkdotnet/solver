import XCTest
@testable import solver

final class ScrabbleSearchServiceTests: XCTestCase {
    func testFindsWordsFromAnySubsetOfRackTiles() async throws {
        let service = ScrabbleSearchService(entries: ["art", "arts", "star", "stared", "solver"])

        let matches = try await service.search(
            ScrabbleRackQuery(letters: "stare", blankCount: 0)
        )

        XCTAssertEqual(matches.map(\.displayText), ["Arts", "Star", "Art"])
    }

    func testBlankTilesCanCoverMissingLetters() async throws {
        let service = ScrabbleSearchService(entries: ["crate", "trace", "react", "star", "art"])

        let matches = try await service.search(
            ScrabbleRackQuery(letters: "crat", blankCount: 1)
        )

        XCTAssertEqual(matches.map(\.displayText), ["Crate", "React", "Trace", "Star", "Art"])
    }

    func testRejectsWordsThatNeedTooManyCopiesOfALetter() async throws {
        let service = ScrabbleSearchService(entries: ["stared", "tears"])

        let matches = try await service.search(
            ScrabbleRackQuery(letters: "stare", blankCount: 0)
        )

        XCTAssertEqual(matches.map(\.displayText), ["Tears"])
    }

    func testBuildsRackQueryFromLettersAndBlanks() {
        let rackState = ScrabbleRackQueryState(rawInput: " sta?re ")

        XCTAssertEqual(
            rackState,
            .valid(ScrabbleRackQuery(letters: "stare", blankCount: 1))
        )
    }

    func testRejectsUnsupportedRackCharacters() {
        let rackState = ScrabbleRackQueryState(rawInput: "sta-re")

        XCTAssertEqual(
            rackState,
            .invalid(message: "Scrabble search supports rack letters plus ? blank tiles only.")
        )
    }
}
