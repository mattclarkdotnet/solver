import Foundation
import Combine

@MainActor
final class SolverSession: ObservableObject {
    @Published var rawPattern: String {
        didSet { persist() }
    }

    @Published var scrabbleStartLetter: String {
        didSet { persist() }
    }

    @Published var scrabbleEndLetter: String {
        didSet { persist() }
    }

    @Published var scrabbleOtherLetters: String {
        didSet { persist() }
    }

    @Published var selectedTool: SolverTool {
        didSet { persist() }
    }

    @Published var selectedWordListGroup: WordListGroup {
        didSet { persist() }
    }

    private let parser: PatternParser
    private let defaults: UserDefaults

    init(
        parser: PatternParser = PatternParser(),
        defaults: UserDefaults = .standard,
        launchArguments: [String] = ProcessInfo.processInfo.arguments
    ) {
        self.parser = parser
        self.defaults = defaults
        if launchArguments.contains("UITEST_RESET_STATE") {
            defaults.removeObject(forKey: StorageKey.rawPattern)
            defaults.removeObject(forKey: StorageKey.scrabbleStartLetter)
            defaults.removeObject(forKey: StorageKey.scrabbleEndLetter)
            defaults.removeObject(forKey: StorageKey.scrabbleOtherLetters)
            defaults.removeObject(forKey: StorageKey.selectedTool)
            defaults.removeObject(forKey: StorageKey.selectedWordListGroup)
        }
        self.rawPattern = defaults.string(forKey: StorageKey.rawPattern) ?? ""
        self.scrabbleStartLetter = defaults.string(forKey: StorageKey.scrabbleStartLetter) ?? ""
        self.scrabbleEndLetter = defaults.string(forKey: StorageKey.scrabbleEndLetter) ?? ""
        self.scrabbleOtherLetters = defaults.string(forKey: StorageKey.scrabbleOtherLetters) ?? ""
        self.selectedTool = SolverTool(rawValue: defaults.string(forKey: StorageKey.selectedTool) ?? "") ?? .crossword
        self.selectedWordListGroup =
            WordListGroup(rawValue: defaults.string(forKey: StorageKey.selectedWordListGroup) ?? "")
            ?? .defaultGroup
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
        defaults.set(scrabbleStartLetter, forKey: StorageKey.scrabbleStartLetter)
        defaults.set(scrabbleEndLetter, forKey: StorageKey.scrabbleEndLetter)
        defaults.set(scrabbleOtherLetters, forKey: StorageKey.scrabbleOtherLetters)
        defaults.set(selectedTool.rawValue, forKey: StorageKey.selectedTool)
        defaults.set(selectedWordListGroup.rawValue, forKey: StorageKey.selectedWordListGroup)
    }
}

private enum StorageKey {
    static let rawPattern = "solver.rawPattern"
    static let scrabbleStartLetter = "solver.scrabbleStartLetter"
    static let scrabbleEndLetter = "solver.scrabbleEndLetter"
    static let scrabbleOtherLetters = "solver.scrabbleOtherLetters"
    static let selectedTool = "solver.selectedTool"
    static let selectedWordListGroup = "solver.selectedWordListGroup"
}
