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

    func testUiTestLaunchArgumentClearsPersistedState() {
        let defaults = UserDefaults(suiteName: #function)!
        defaults.removePersistentDomain(forName: #function)
        defer { defaults.removePersistentDomain(forName: #function) }

        defaults.set("c?t", forKey: "solver.rawPattern")
        defaults.set(SolverTool.crossword.rawValue, forKey: "solver.selectedTool")

        let session = SolverSession(defaults: defaults)

        XCTAssertEqual(session.rawPattern, "c?t")
        XCTAssertEqual(session.selectedTool, .crossword)
    }
}
