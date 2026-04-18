import Foundation

struct PatternParser: Sendable {
    nonisolated init() {}

    func parse(_ input: String) -> PatternQueryState {
        let trimmedInput = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedInput.isEmpty == false else {
            return .empty
        }

        var segments: [PatternSegment] = []
        var tokens: [PatternToken] = []

        for character in trimmedInput.lowercased() {
            switch character {
            case "a"..."z":
                tokens.append(.literal(character))
            case "?", ".":
                // Both symbols represent one unknown letter in the current crossword syntax.
                tokens.append(.singleWildcard)
            case "+", "*":
                // Both symbols represent an unknown run, so the parser normalizes them to one token kind.
                tokens.append(.multiWildcard)
            case "-", " ":
                guard tokens.isEmpty == false else {
                    if character == "-", segments.isEmpty {
                        return .invalid(message: "Use letters or wildcards between word breaks.")
                    }

                    // Treat repeated separators inside a phrase as one visible word break.
                    continue
                }

                // Spaces and hyphens both mark a word break for crossword phrase patterns.
                segments.append(PatternSegment(tokens: tokens))
                tokens.removeAll(keepingCapacity: true)
            default:
                return .invalid(
                    message: "Only letters, ?, ., spaces, +, *, and - are supported."
                )
            }
        }

        guard tokens.isEmpty == false else {
            return .invalid(message: "Patterns cannot end with a word break.")
        }

        segments.append(PatternSegment(tokens: tokens))
        return .valid(PatternQuery(segments: segments))
    }
}
