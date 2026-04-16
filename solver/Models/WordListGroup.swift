import Foundation

enum WordListGroup: String, CaseIterable, Identifiable, Codable {
    case test
    case english = "English"

    static let defaultGroup: WordListGroup = .test

    var id: String { rawValue }

    var title: String {
        switch self {
        case .test:
            "Test"
        case .english:
            "English"
        }
    }

    var sourceDescription: String {
        switch self {
        case .test:
            "Small deterministic seed data for development and testing."
        case .english:
            "A bundled starter English list for everyday solving."
        }
    }

    var resourceSubdirectory: String {
        "wordlists/\(rawValue)"
    }

    func resourceName(for baseName: String) -> String {
        switch self {
        case .test:
            baseName
        case .english:
            "english_\(baseName)"
        }
    }
}
