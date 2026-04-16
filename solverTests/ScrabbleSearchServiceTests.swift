import XCTest
@testable import solver

final class ScrabbleSearchServiceTests: XCTestCase {
    func testFindsWordsFromAnySubsetOfRackTiles() async throws {
        let service = ScrabbleSearchService(entries: ["art", "arts", "star", "stared", "solver"])

        let matches = try await service.search(
            ScrabbleQuery(
                rack: ScrabbleRackQuery(letters: "stare", blankCount: 0),
                board: ScrabbleBoardQuery(startLetter: nil, endLetter: nil, otherLetters: "")
            )
        )

        XCTAssertEqual(matches.map(\.displayText), ["Arts", "Star", "Art"])
    }

    func testBlankTilesCanCoverMissingLetters() async throws {
        let service = ScrabbleSearchService(entries: ["crate", "trace", "react", "star", "art"])

        let matches = try await service.search(
            ScrabbleQuery(
                rack: ScrabbleRackQuery(letters: "crat", blankCount: 1),
                board: ScrabbleBoardQuery(startLetter: nil, endLetter: nil, otherLetters: "")
            )
        )

        XCTAssertEqual(matches.map(\.displayText), ["Crate", "React", "Trace", "Star", "Art"])
    }

    func testRejectsWordsThatNeedTooManyCopiesOfALetter() async throws {
        let service = ScrabbleSearchService(entries: ["stared", "tears"])

        let matches = try await service.search(
            ScrabbleQuery(
                rack: ScrabbleRackQuery(letters: "stare", blankCount: 0),
                board: ScrabbleBoardQuery(startLetter: nil, endLetter: nil, otherLetters: "")
            )
        )

        XCTAssertEqual(matches.map(\.displayText), ["Tears"])
    }

    func testAllowsOtherBoardLettersToLandAtTheEndWhenNoEndLetterIsProvided() async throws {
        let service = ScrabbleSearchService(entries: ["stare", "rates", "arts"])

        let matches = try await service.search(
            ScrabbleQuery(
                rack: ScrabbleRackQuery(letters: "star", blankCount: 0),
                board: ScrabbleBoardQuery(startLetter: nil, endLetter: nil, otherLetters: "e")
            )
        )

        XCTAssertEqual(matches.map(\.displayText), ["Stare"])
    }

    func testDoesNotLetEndLetterDoubleCountAsOtherBoardLetter() async throws {
        let service = ScrabbleSearchService(entries: ["stare", "star"])

        let matches = try await service.search(
            ScrabbleQuery(
                rack: ScrabbleRackQuery(letters: "star", blankCount: 0),
                board: ScrabbleBoardQuery(startLetter: nil, endLetter: "e", otherLetters: "e")
            )
        )

        XCTAssertEqual(matches.map(\.displayText), [])
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

    func testBuildsScrabbleQueryFromRackAndBoardLetters() {
        let queryState = ScrabbleQueryState(
            rackInput: " star ",
            startLetterInput: "s",
            endLetterInput: "",
            otherLettersInput: "e"
        )

        XCTAssertEqual(
            queryState,
            .valid(
                ScrabbleQuery(
                    rack: ScrabbleRackQuery(letters: "star", blankCount: 0),
                    board: ScrabbleBoardQuery(startLetter: "s", endLetter: nil, otherLetters: "e")
                )
            )
        )
    }

    func testRejectsOverlongStartLetter() {
        let queryState = ScrabbleQueryState(
            rackInput: "star",
            startLetterInput: "st",
            endLetterInput: "",
            otherLettersInput: ""
        )

        XCTAssertEqual(
            queryState,
            .invalid(message: "Start letter must be empty or a single letter.")
        )
    }

    func testRejectsUnsupportedOtherBoardLetters() {
        let queryState = ScrabbleQueryState(
            rackInput: "star",
            startLetterInput: "",
            endLetterInput: "",
            otherLettersInput: "e?"
        )

        XCTAssertEqual(
            queryState,
            .invalid(message: "Other board letters support literal letters only.")
        )
    }
}
