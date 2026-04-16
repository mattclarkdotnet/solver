import XCTest
@testable import solver

@MainActor
final class SolverSessionTests: XCTestCase {
    func testPersistsPatternAndSelectedTool() {
        let defaults = UserDefaults(suiteName: #function)!
        defaults.removePersistentDomain(forName: #function)
        defer { defaults.removePersistentDomain(forName: #function) }

        let session = SolverSession(defaults: defaults)
        session.rawPattern = "stare?"
        session.scrabbleStartLetter = "s"
        session.scrabbleEndLetter = "e"
        session.scrabbleOtherLetters = "ta"
        session.selectedTool = .scrabble

        let restored = SolverSession(defaults: defaults)

        XCTAssertEqual(restored.rawPattern, "stare?")
        XCTAssertEqual(restored.scrabbleStartLetter, "s")
        XCTAssertEqual(restored.scrabbleEndLetter, "e")
        XCTAssertEqual(restored.scrabbleOtherLetters, "ta")
        XCTAssertEqual(restored.selectedTool, .scrabble)
    }

    func testResetLaunchArgumentClearsPersistedState() {
        let defaults = UserDefaults(suiteName: #function)!
        defaults.removePersistentDomain(forName: #function)
        defer { defaults.removePersistentDomain(forName: #function) }

        defaults.set("c?t", forKey: "solver.rawPattern")
        defaults.set("s", forKey: "solver.scrabbleStartLetter")
        defaults.set("e", forKey: "solver.scrabbleEndLetter")
        defaults.set("ta", forKey: "solver.scrabbleOtherLetters")
        defaults.set(SolverTool.crossword.rawValue, forKey: "solver.selectedTool")

        let session = SolverSession(
            defaults: defaults,
            launchArguments: ["UITEST_RESET_STATE"]
        )

        XCTAssertEqual(session.rawPattern, "")
        XCTAssertEqual(session.scrabbleStartLetter, "")
        XCTAssertEqual(session.scrabbleEndLetter, "")
        XCTAssertEqual(session.scrabbleOtherLetters, "")
        XCTAssertEqual(session.selectedTool, .crossword)
        XCTAssertNil(defaults.string(forKey: "solver.rawPattern"))
        XCTAssertNil(defaults.string(forKey: "solver.scrabbleStartLetter"))
        XCTAssertNil(defaults.string(forKey: "solver.scrabbleEndLetter"))
        XCTAssertNil(defaults.string(forKey: "solver.scrabbleOtherLetters"))
        XCTAssertNil(defaults.string(forKey: "solver.selectedTool"))
    }
}
