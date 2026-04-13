import Foundation
import Combine

@MainActor
final class SolverSession: ObservableObject {
    @Published var rawPattern: String {
        didSet { persist() }
    }

    @Published var selectedTool: SolverTool {
        didSet { persist() }
    }

    private let parser: PatternParser
    private let defaults: UserDefaults

    init(
        parser: PatternParser = PatternParser(),
        defaults: UserDefaults = .standard
    ) {
        self.parser = parser
        self.defaults = defaults
        if ProcessInfo.processInfo.arguments.contains("UITEST_RESET_STATE") {
            defaults.removeObject(forKey: StorageKey.rawPattern)
            defaults.removeObject(forKey: StorageKey.selectedTool)
        }
        self.rawPattern = defaults.string(forKey: StorageKey.rawPattern) ?? ""
        self.selectedTool = SolverTool(rawValue: defaults.string(forKey: StorageKey.selectedTool) ?? "") ?? .crossword
    }

    var queryState: PatternQueryState {
        parser.parse(rawPattern)
    }

    func clearPattern() {
        rawPattern = ""
    }

    private func persist() {
        // Persist the shared query state locally so the app restores the current workflow offline.
        defaults.set(rawPattern, forKey: StorageKey.rawPattern)
        defaults.set(selectedTool.rawValue, forKey: StorageKey.selectedTool)
    }
}

private enum StorageKey {
    static let rawPattern = "solver.rawPattern"
    static let selectedTool = "solver.selectedTool"
}
