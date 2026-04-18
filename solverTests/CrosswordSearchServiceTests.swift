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

    func testMatchesSpaceSeparatedPhrasePatternAgainstInjectedEntries() async throws {
        let service = CrosswordSearchService(entries: ["ice cream", "cross word", "cream"])
        let query = try XCTUnwrap(PatternParser().parse("ice cream").query)

        let matches = try await service.search(query)

        XCTAssertEqual(matches.map(\.displayText), ["Ice Cream"])
    }

    func testMatchesHyphenSeparatedWildcardPhraseAgainstInjectedEntries() async throws {
        let service = CrosswordSearchService(entries: ["pancho villa", "poncho villa", "pancho valley"])
        let query = try XCTUnwrap(PatternParser().parse("p?????-v????").query)

        let matches = try await service.search(query)

        XCTAssertTrue(matches.map(\.displayText).contains("Pancho Villa"))
    }

    func testReturnsNoMatchesWhenPatternIsTooSpecific() async throws {
        let service = CrosswordSearchService(entries: ["cat", "cot"])
        let query = try XCTUnwrap(PatternParser().parse("czz").query)

        let matches = try await service.search(query)

        XCTAssertTrue(matches.isEmpty)
    }

    func testCancelsLongRunningSearch() async throws {
        let service = CrosswordSearchService(
            entries: Array(repeating: "abcdefghijklmnopqrst", count: 200_000)
        )
        let query = try XCTUnwrap(PatternParser().parse("a*a*a*a*a*a*a*a*a*a").query)

        let task = Task {
            try await service.search(query)
        }

        try await Task.sleep(nanoseconds: 10_000_000)
        task.cancel()

        do {
            _ = try await task.value
            XCTFail("Expected the search task to be cancelled.")
        } catch is CancellationError {
        } catch {
            XCTFail("Expected CancellationError but received \(error).")
        }
    }
}
