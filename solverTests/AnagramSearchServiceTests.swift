import XCTest
@testable import solver

final class AnagramSearchServiceTests: XCTestCase {
    func testFindsAnagramsFromInjectedEntries() async throws {
        let service = AnagramSearchService(entries: ["stare", "tears", "rates", "aster", "solver"])

        let matches = try await service.search(AnagramQuery(letters: "stare"))

        XCTAssertEqual(matches.map(\.displayText), ["Aster", "Rates", "Tears"])
    }

    func testExcludesTheExactInputWordFromResults() async throws {
        let service = AnagramSearchService(entries: ["trace", "crate", "react"])

        let matches = try await service.search(AnagramQuery(letters: "trace"))

        XCTAssertEqual(matches.map(\.displayText), ["Crate", "React"])
    }

    func testIgnoresPhraseEntriesInTheInjectedWordList() async throws {
        let service = AnagramSearchService(entries: ["cross word", "word game", "solver"])

        let matches = try await service.search(AnagramQuery(letters: "drows"))

        XCTAssertTrue(matches.isEmpty)
    }

    func testBuildsValidQueryStateFromSingleWordLetters() {
        let patternState = PatternParser().parse("stare")
        let anagramState = AnagramQueryState(patternState: patternState)

        XCTAssertEqual(anagramState, .valid(AnagramQuery(letters: "stare")))
    }

    func testRejectsWildcardPatternsForAnagramSolving() {
        let patternState = PatternParser().parse("st?re")
        let anagramState = AnagramQueryState(patternState: patternState)

        XCTAssertEqual(
            anagramState,
            .invalid(message: "Anagram solving currently supports letters only, without wildcards.")
        )
    }

    func testRejectsMultiWordPatternsForAnagramSolving() {
        let patternState = PatternParser().parse("ice-cream")
        let anagramState = AnagramQueryState(patternState: patternState)

        XCTAssertEqual(
            anagramState,
            .invalid(message: "Anagram solving currently supports one word at a time.")
        )
    }
}
