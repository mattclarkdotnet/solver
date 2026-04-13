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
        VStack(spacing: 20) {
            PatternEntryCard(session: session)
            ToolTabs(session: session, searchService: searchService)
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 12)
        .background(Color(.systemGroupedBackground))
    }
}

private struct PatternEntryCard: View {
    @ObservedObject var session: SolverSession
    @FocusState private var isPatternFieldFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Current pattern")
                        .font(.headline)
                    Text("Letters stay fixed, `?` or `.` or spaces match one letter, `*` or `+` match a run, and `-` splits words.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if session.rawPattern.isEmpty == false {
                    Button("Clear") {
                        session.clearPattern()
                    }
                    .buttonStyle(.bordered)
                }
            }

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

            PatternStatusRow(queryState: session.queryState)
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
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Current pattern")
    }
}

private struct PatternStatusRow: View {
    let queryState: PatternQueryState

    var body: some View {
        Group {
            switch queryState {
            case .empty:
                StatusPill(
                    title: "Enter a pattern to search the offline list.",
                    symbol: "pencil.line",
                    tint: .secondary
                )
            case .invalid(let message):
                StatusPill(
                    title: message,
                    symbol: "exclamationmark.triangle",
                    tint: .orange
                )
            case .valid(let query):
                StatusPill(
                    title: query.summary,
                    symbol: query.allowsPhraseResults ? "textformat.abc.dottedunderline" : "checkmark.circle",
                    tint: .green
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct ToolTabs: View {
    @ObservedObject var session: SolverSession
    let searchService: CrosswordSearchService

    var body: some View {
        TabView(selection: $session.selectedTool) {
            Tab("Crossword", systemImage: SolverTool.crossword.systemImage, value: .crossword) {
                CrosswordToolView(queryState: session.queryState, searchService: searchService)
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
    let queryState: PatternQueryState
    let searchService: CrosswordSearchService

    @State private var presentationState: CrosswordPresentationState = .idle
    @State private var lastSearchPattern: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                toolHeader
                searchAction
                content
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 32)
        }
        .scrollIndicators(.hidden)
        .onChange(of: queryFingerprint, initial: true) { _, newValue in
            guard lastSearchPattern != nil else { return }
            if lastSearchPattern != newValue {
                presentationState = .idle
            }
        }
    }

    private var queryFingerprint: String? {
        queryState.query?.normalizedPattern
    }

    private var toolHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Offline crossword search")
                .font(.title3.weight(.semibold))
            Text("Searches the bundled starter word list on-device and keeps your current pattern in sync with the rest of the app.")
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }

    private var searchAction: some View {
        Button {
            Task {
                await performSearch()
            }
        } label: {
            Label("Find Matches", systemImage: "magnifyingglass")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .disabled(isSearchDisabled)
        .accessibilityIdentifier("crossword-search-button")
        .accessibilityHint("Search the bundled crossword list using the current pattern.")
    }

    @ViewBuilder
    private var content: some View {
        switch presentationState {
        case .idle:
            SearchMessageCard(
                title: idleTitle,
                message: idleMessage,
                symbol: idleSymbol,
                tint: idleTint
            )
        case .loading:
            SearchMessageCard(
                title: "Searching the offline list",
                message: "The crossword tool is checking bundled entries on this device.",
                symbol: "hourglass",
                tint: .blue
            )
        case .empty(let pattern):
            SearchMessageCard(
                title: "No matches for \(pattern)",
                message: "Try widening the pattern with `?` for a single unknown letter or `*` for a longer run.",
                symbol: "text.magnifyingglass",
                tint: .secondary
            )
        case .failed(let message):
            SearchMessageCard(
                title: "Search unavailable",
                message: message,
                symbol: "xmark.octagon",
                tint: .red
            )
        case .results(let listName, let matches):
            ResultsCard(listName: listName, matches: matches)
        }
    }

    private var isSearchDisabled: Bool {
        if case .valid = queryState {
            false
        } else {
            true
        }
    }

    private var idleTitle: String {
        switch queryState {
        case .empty:
            "Start with a pattern"
        case .invalid:
            "Fix the pattern first"
        case .valid:
            "Ready to search"
        }
    }

    private var idleMessage: String {
        switch queryState {
        case .empty:
            "Enter a word or phrase pattern above and the crossword tool will search the bundled starter list."
        case .invalid(let message):
            message
        case .valid(let query):
            "Press Find Matches to search for \(query.normalizedPattern) in the offline crossword list."
        }
    }

    private var idleSymbol: String {
        switch queryState {
        case .empty:
            "character.cursor.ibeam"
        case .invalid:
            "exclamationmark.triangle"
        case .valid:
            "magnifyingglass.circle"
        }
    }

    private var idleTint: Color {
        switch queryState {
        case .empty:
            .secondary
        case .invalid:
            .orange
        case .valid:
            .blue
        }
    }

    @MainActor
    private func performSearch() async {
        guard case .valid(let query) = queryState else {
            presentationState = .idle
            return
        }

        presentationState = .loading

        do {
            async let matches = searchService.search(query)
            async let wordListName = searchService.wordListName()
            let resolvedMatches = try await matches
            let resolvedListName = try await wordListName

            lastSearchPattern = query.normalizedPattern
            presentationState = resolvedMatches.isEmpty
                ? .empty(query.normalizedPattern)
                : .results(listName: resolvedListName, matches: resolvedMatches)
        } catch {
            presentationState = .failed(error.localizedDescription)
        }
    }
}

private struct ResultsCard: View {
    let listName: String
    let matches: [CrosswordMatch]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(matches.count) matches")
                        .font(.headline)
                    Text(listName)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text("Offline")
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(Color.green.opacity(0.15)))
                    .foregroundStyle(.green)
            }

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

private struct StatusPill: View {
    let title: String
    let symbol: String
    let tint: Color

    var body: some View {
        Label {
            Text(title)
                .font(.footnote)
        } icon: {
            Image(systemName: symbol)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(tint.opacity(0.12))
        )
        .foregroundStyle(tint)
        .accessibilityElement(children: .combine)
    }
}

private enum CrosswordPresentationState {
    case idle
    case loading
    case empty(String)
    case failed(String)
    case results(listName: String, matches: [CrosswordMatch])
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
