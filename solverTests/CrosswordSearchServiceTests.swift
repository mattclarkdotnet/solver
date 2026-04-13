import XCTest
@testable import solver

final class CrosswordSearchServiceTests: XCTestCase {
    func testMatchesSingleWordPatternAgainstInjectedEntries() async throws {
        let service = CrosswordSearchService(entries: ["cat", "cot", "dog"])
        let query = try XCTUnwrap(PatternParser().parse("c?t").query)

        let matches = try await service.search(query)

        XCTAssertEqual(matches.map(\.displayText), ["Cat", "Cot"])
    }

    func testMatchesPhrasePatternAgainstInjectedEntries() async throws {
        let service = CrosswordSearchService(entries: ["ice cream", "cross word", "cream"])
        let query = try XCTUnwrap(PatternParser().parse("ice-cream").query)

        let matches = try await service.search(query)

        XCTAssertEqual(matches.map(\.displayText), ["Ice Cream"])
    }

    func testReturnsNoMatchesWhenPatternIsTooSpecific() async throws {
        let service = CrosswordSearchService(entries: ["cat", "cot"])
        let query = try XCTUnwrap(PatternParser().parse("czz").query)

        let matches = try await service.search(query)

        XCTAssertTrue(matches.isEmpty)
    }
}
