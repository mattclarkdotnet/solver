import XCTest
@testable import solver

final class AnagramSearchServiceTests: XCTestCase {
    func testFindsAnagramsFromInjectedEntries() async throws {
        let service = AnagramSearchService(entries: ["stare", "tears", "rates", "aster", "solver"])

        let matches = try await service.search(
            AnagramQuery(letters: "stare", normalizedInput: "stare")
        )

        XCTAssertEqual(matches.map(\.displayText), ["Aster", "Rates", "Tears"])
    }

    func testExcludesTheExactInputWordFromResults() async throws {
        let service = AnagramSearchService(entries: ["trace", "crate", "react"])

        let matches = try await service.search(
            AnagramQuery(letters: "trace", normalizedInput: "trace")
        )

        XCTAssertEqual(matches.map(\.displayText), ["Crate", "React"])
    }

    func testFindsPhraseAnagramsFromInjectedEntries() async throws {
        let service = AnagramSearchService(entries: ["pancho villa", "villap ancho", "solver"])

        let matches = try await service.search(
            AnagramQuery(letters: "villapancho", normalizedInput: "villap ancho")
        )

        XCTAssertEqual(matches.map(\.displayText), ["Pancho Villa"])
    }

    func testBuildsValidQueryStateFromSingleWordLetters() {
        let patternState = PatternParser().parse("stare")
        let anagramState = AnagramQueryState(patternState: patternState)

        XCTAssertEqual(
            anagramState,
            .valid(AnagramQuery(letters: "stare", normalizedInput: "stare"))
        )
    }

    func testBuildsValidQueryStateFromPhraseLetters() {
        let patternState = PatternParser().parse("villap-ancho")
        let anagramState = AnagramQueryState(patternState: patternState)

        XCTAssertEqual(
            anagramState,
            .valid(AnagramQuery(letters: "villapancho", normalizedInput: "villap ancho"))
        )
    }

    func testRejectsWildcardPatternsForAnagramSolving() {
        let patternState = PatternParser().parse("st?re")
        let anagramState = AnagramQueryState(patternState: patternState)

        XCTAssertEqual(
            anagramState,
            .invalid(message: "Anagram solving currently supports letters only, without wildcards.")
        )
    }

    func testExcludesTheExactPhraseInputFromResults() async throws {
        let service = AnagramSearchService(entries: ["pancho villa", "villap ancho"])

        let matches = try await service.search(
            AnagramQuery(letters: "villapancho", normalizedInput: "pancho villa")
        )

        XCTAssertEqual(matches.map(\.displayText), ["Villap Ancho"])
    }
}
