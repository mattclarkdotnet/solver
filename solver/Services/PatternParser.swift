import Foundation

struct PatternParser: Sendable {
    nonisolated init() {}

    func parse(_ input: String) -> PatternQueryState {
        guard input.isEmpty == false else {
            return .empty
        }

        var segments: [PatternSegment] = []
        var tokens: [PatternToken] = []

        for character in input.lowercased() {
            switch character {
            case "a"..."z":
                tokens.append(.literal(character))
            case "?", ".", " ":
                // The README treats these three symbols as equivalent single-letter wildcards.
                tokens.append(.singleWildcard)
            case "+", "*":
                // Both symbols represent an unknown run, so the parser normalizes them to one token kind.
                tokens.append(.multiWildcard)
            case "-":
                guard tokens.isEmpty == false else {
                    return .invalid(message: "Use letters or wildcards between word breaks.")
                }

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
