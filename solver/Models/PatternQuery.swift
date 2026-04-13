import Foundation

enum PatternToken: Hashable, Sendable {
    case literal(Character)
    case singleWildcard
    case multiWildcard
}

struct PatternSegment: Hashable, Sendable {
    let tokens: [PatternToken]
}

struct PatternQuery: Hashable, Sendable {
    let segments: [PatternSegment]

    var normalizedPattern: String {
        segments
            .map(\.normalizedPattern)
            .joined(separator: "-")
    }

    var segmentCount: Int {
        segments.count
    }

    var allowsPhraseResults: Bool {
        segments.count > 1
    }

    var summary: String {
        let wordLabel = segmentCount == 1 ? "word" : "words"
        return "\(segmentCount) \(wordLabel), normalized as \(normalizedPattern)"
    }
}

extension PatternSegment {
    var normalizedPattern: String {
        tokens.map { token in
            switch token {
            case .literal(let character):
                String(character)
            case .singleWildcard:
                "?"
            case .multiWildcard:
                "*"
            }
        }
        .joined()
    }
}

enum PatternQueryState: Equatable, Sendable {
    case empty
    case invalid(message: String)
    case valid(PatternQuery)

    var query: PatternQuery? {
        if case .valid(let query) = self {
            query
        } else {
            nil
        }
    }
}
