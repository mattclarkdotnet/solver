import Foundation

enum SolverTool: String, CaseIterable, Identifiable, Codable {
    case crossword
    case scrabble
    case anagramSolver
    case anagramGenerator
    case definitions
    case scrabbleChecker
    case thesaurus

    var id: String { rawValue }

    var title: String {
        switch self {
        case .crossword:
            "Crossword"
        case .scrabble:
            "Scrabble"
        case .anagramSolver:
            "Anagram Solver"
        case .anagramGenerator:
            "Anagram Generator"
        case .definitions:
            "Definitions"
        case .scrabbleChecker:
            "Word Check"
        case .thesaurus:
            "Thesaurus"
        }
    }

    var systemImage: String {
        switch self {
        case .crossword:
            "square.grid.3x3"
        case .scrabble:
            "textformat.abc"
        case .anagramSolver:
            "arrow.trianglehead.2.clockwise"
        case .anagramGenerator:
            "shuffle"
        case .definitions:
            "book.closed"
        case .scrabbleChecker:
            "checkmark.seal"
        case .thesaurus:
            "text.book.closed"
        }
    }

    var statusTitle: String {
        switch self {
        case .crossword, .scrabble, .anagramSolver, .definitions:
            "Ready now"
        default:
            "Planned next"
        }
    }

    var statusMessage: String {
        switch self {
        case .crossword:
            "Search the bundled offline crossword list with the shared word pattern."
        case .scrabble:
            "Search the bundled offline test Scrabble list using rack letters and ? blank tiles."
        case .anagramSolver:
            "Find rearrangements in the bundled offline crossword test list using the shared letters input."
        case .anagramGenerator:
            "Generation tools will follow after the first search-focused tools are stable."
        case .definitions:
            "Look up definitions from a separate bundled offline test definitions list."
        case .scrabbleChecker:
            "Offline word validation is planned after search and anagram workflows land."
        case .thesaurus:
            "Offline synonym lookup is planned for a later roadmap item."
        }
    }
}
