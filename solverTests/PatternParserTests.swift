import XCTest
@testable import solver

final class PatternParserTests: XCTestCase {
    func testParsesSimpleWildcardPattern() {
        let parser = PatternParser()

        let result = parser.parse("c?t")

        guard case .valid(let query) = result else {
            return XCTFail("Expected a valid query for c?t")
        }

        XCTAssertEqual(query.normalizedPattern, "c?t")
        XCTAssertEqual(query.segmentCount, 1)
        XCTAssertFalse(query.allowsPhraseResults)
    }

    func testNormalizesEquivalentWildcardSymbolsWithinPhraseSegments() {
        let parser = PatternParser()

        let result = parser.parse("a.+ b")

        guard case .valid(let query) = result else {
            return XCTFail("Expected a valid query for a.+ b")
        }

        XCTAssertEqual(query.normalizedPattern, "a?*-b")
    }

    func testParsesPhraseSegments() {
        let parser = PatternParser()

        let result = parser.parse("ice-cream")

        guard case .valid(let query) = result else {
            return XCTFail("Expected a valid phrase query")
        }

        XCTAssertEqual(query.segmentCount, 2)
        XCTAssertEqual(query.normalizedPattern, "ice-cream")
        XCTAssertTrue(query.allowsPhraseResults)
    }

    func testTreatsSpacesAsPhraseSeparators() {
        let parser = PatternParser()

        let result = parser.parse("ice cream")

        guard case .valid(let query) = result else {
            return XCTFail("Expected a valid phrase query from spaces")
        }

        XCTAssertEqual(query.segmentCount, 2)
        XCTAssertEqual(query.normalizedPattern, "ice-cream")
        XCTAssertTrue(query.allowsPhraseResults)
    }

    func testRejectsTrailingWordBreak() {
        let parser = PatternParser()

        let result = parser.parse("cat-")

        XCTAssertEqual(result, .invalid(message: "Patterns cannot end with a word break."))
    }
}
