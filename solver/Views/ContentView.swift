import SwiftUI

struct ContentView: View {
    @StateObject private var session = SolverSession()
    private let searchService = CrosswordSearchService()

    var body: some View {
        NavigationStack {
            SolverHomeView(session: session, searchService: searchService)
                .navigationTitle("Solver")
        }
    }
}

private struct SolverHomeView: View {
    @ObservedObject var session: SolverSession
    let searchService: CrosswordSearchService

    var body: some View {
        ToolTabs(session: session, searchService: searchService)
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 12)
        .background(Color(.systemGroupedBackground))
    }
}

private struct PatternEntryField: View {
    @ObservedObject var session: SolverSession
    @FocusState private var isPatternFieldFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            TextField("Example: c?t or ice-cream", text: $session.rawPattern)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .font(.title3.monospaced())
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color(.secondarySystemBackground))
                )
                .focused($isPatternFieldFocused)
                .accessibilityIdentifier("pattern-field")
                .onSubmit {
                    isPatternFieldFocused = false
                }

            Text("Letters stay fixed, `?` or `.` or spaces match one letter, `*` or `+` match a run, and `-` splits words.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Current pattern")
    }
}

private struct ToolTabs: View {
    @ObservedObject var session: SolverSession
    let searchService: CrosswordSearchService

    var body: some View {
        TabView(selection: $session.selectedTool) {
            Tab("Crossword", systemImage: SolverTool.crossword.systemImage, value: .crossword) {
                CrosswordToolView(session: session, searchService: searchService)
            }

            Tab("Scrabble", systemImage: SolverTool.scrabble.systemImage, value: .scrabble) {
                PlaceholderToolView(tool: .scrabble)
            }

            Tab("Anagram", systemImage: SolverTool.anagramSolver.systemImage, value: .anagramSolver) {
                PlaceholderToolView(tool: .anagramSolver)
            }

            Tab("Generator", systemImage: SolverTool.anagramGenerator.systemImage, value: .anagramGenerator) {
                PlaceholderToolView(tool: .anagramGenerator)
            }

            Tab("Define", systemImage: SolverTool.definitions.systemImage, value: .definitions) {
                PlaceholderToolView(tool: .definitions)
            }

            Tab("Check", systemImage: SolverTool.scrabbleChecker.systemImage, value: .scrabbleChecker) {
                PlaceholderToolView(tool: .scrabbleChecker)
            }

            Tab("Thesaurus", systemImage: SolverTool.thesaurus.systemImage, value: .thesaurus) {
                PlaceholderToolView(tool: .thesaurus)
            }
        }
        .background(Color(.systemGroupedBackground))
    }
}

private struct CrosswordToolView: View {
    @ObservedObject var session: SolverSession
    let searchService: CrosswordSearchService

    @State private var presentationState: CrosswordPresentationState = .idle

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                PatternEntryField(session: session)
                content
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 32)
        }
        .scrollIndicators(.hidden)
        .task(id: queryFingerprint) {
            await refreshResults()
        }
    }

    private var queryState: PatternQueryState {
        session.queryState
    }

    private var queryFingerprint: String? {
        switch queryState {
        case .empty:
            "empty"
        case .invalid(let message):
            "invalid:\(message)"
        case .valid(let query):
            "valid:\(query.normalizedPattern)"
        }
    }

    @ViewBuilder
    private var content: some View {
        switch presentationState {
        case .idle:
            SearchMessageCard(
                title: "Start with a pattern",
                message: "Enter a word or phrase pattern above and live results will appear here from the bundled offline list.",
                symbol: "character.cursor.ibeam",
                tint: .secondary
            )
            .accessibilityIdentifier("crossword-status-card")
        case .loading:
            SearchMessageCard(
                title: "Searching the offline list",
                message: "The crossword tool is checking bundled entries on this device.",
                symbol: "hourglass",
                tint: .blue
            )
            .accessibilityIdentifier("crossword-status-card")
        case .empty(let pattern):
            SearchMessageCard(
                title: "No matches for \(pattern)",
                message: "Try widening the pattern with `?` for a single unknown letter or `*` for a longer run.",
                symbol: "text.magnifyingglass",
                tint: .secondary
            )
            .accessibilityIdentifier("crossword-status-card")
        case .invalid(let message):
            SearchMessageCard(
                title: "Fix the pattern first",
                message: message,
                symbol: "exclamationmark.triangle",
                tint: .orange
            )
            .accessibilityIdentifier("crossword-status-card")
        case .failed(let message):
            SearchMessageCard(
                title: "Search unavailable",
                message: message,
                symbol: "xmark.octagon",
                tint: .red
            )
            .accessibilityIdentifier("crossword-status-card")
        case .results(let matches):
            ResultsCard(matches: matches)
                .accessibilityIdentifier("crossword-results-card")
        }
    }

    @MainActor
    private func refreshResults() async {
        switch queryState {
        case .empty:
            presentationState = .idle
            return
        case .invalid(let message):
            presentationState = .invalid(message)
            return
        case .valid(let query):
            break
        }

        presentationState = .loading

        guard case .valid(let query) = queryState else {
            return
        }

        do {
            let resolvedMatches = try await searchService.search(query)

            guard Task.isCancelled == false else {
                return
            }

            presentationState = resolvedMatches.isEmpty
                ? .empty(query.normalizedPattern)
                : .results(resolvedMatches)
        } catch is CancellationError {
            return
        } catch {
            presentationState = .failed(error.localizedDescription)
        }
    }
}

private struct ResultsCard: View {
    let matches: [CrosswordMatch]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            LazyVStack(alignment: .leading, spacing: 10) {
                ForEach(matches) { match in
                    Text(match.displayText)
                        .font(.body.monospaced())
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color(.secondarySystemBackground))
                        )
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(Color(.separator).opacity(0.3))
        )
    }
}

private struct PlaceholderToolView: View {
    let tool: SolverTool

    var body: some View {
        ScrollView {
            SearchMessageCard(
                title: tool.statusTitle,
                message: tool.statusMessage,
                symbol: tool.systemImage,
                tint: .secondary
            )
            .padding(.bottom, 32)
        }
        .scrollIndicators(.hidden)
    }
}

private struct SearchMessageCard: View {
    let title: String
    let message: String
    let symbol: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Image(systemName: symbol)
                .font(.title2.weight(.semibold))
                .foregroundStyle(tint)
                .accessibilityHidden(true)

            Text(title)
                .font(.headline)

            Text(message)
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(Color(.separator).opacity(0.3))
        )
        .accessibilityElement(children: .combine)
    }
}

private enum CrosswordPresentationState {
    case idle
    case loading
    case empty(String)
    case invalid(String)
    case failed(String)
    case results([CrosswordMatch])
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
