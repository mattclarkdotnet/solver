import XCTest
@testable import solver

@MainActor
final class SolverSessionTests: XCTestCase {
    func testPersistsPatternAndSelectedTool() {
        let defaults = UserDefaults(suiteName: #function)!
        defaults.removePersistentDomain(forName: #function)
        defer { defaults.removePersistentDomain(forName: #function) }

        let session = SolverSession(defaults: defaults)
        session.rawPattern = "c?t"
        session.selectedTool = .thesaurus

        let restored = SolverSession(defaults: defaults)

        XCTAssertEqual(restored.rawPattern, "c?t")
        XCTAssertEqual(restored.selectedTool, .thesaurus)
    }

    func testResetLaunchArgumentClearsPersistedState() {
        let defaults = UserDefaults(suiteName: #function)!
        defaults.removePersistentDomain(forName: #function)
        defer { defaults.removePersistentDomain(forName: #function) }

        defaults.set("c?t", forKey: "solver.rawPattern")
        defaults.set(SolverTool.crossword.rawValue, forKey: "solver.selectedTool")

        let session = SolverSession(
            defaults: defaults,
            launchArguments: ["UITEST_RESET_STATE"]
        )

        XCTAssertEqual(session.rawPattern, "")
        XCTAssertEqual(session.selectedTool, .crossword)
        XCTAssertNil(defaults.string(forKey: "solver.rawPattern"))
        XCTAssertNil(defaults.string(forKey: "solver.selectedTool"))
    }
}
