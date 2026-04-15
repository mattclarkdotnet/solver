import SwiftUI

struct ContentView: View {
    @StateObject private var session = SolverSession()
    private let crosswordService = CrosswordSearchService()
    private let scrabbleService = ScrabbleSearchService()
    private let anagramService = AnagramSearchService()
    private let definitionsService = DefinitionsLookupService()

    var body: some View {
        NavigationStack {
            SolverHomeView(
                session: session,
                crosswordService: crosswordService,
                scrabbleService: scrabbleService,
                anagramService: anagramService,
                definitionsService: definitionsService
            )
                .navigationTitle("Solver")
        }
    }
}

private struct SolverHomeView: View {
    @ObservedObject var session: SolverSession
    let crosswordService: CrosswordSearchService
    let scrabbleService: ScrabbleSearchService
    let anagramService: AnagramSearchService
    let definitionsService: DefinitionsLookupService

    var body: some View {
        ToolTabs(
            session: session,
            crosswordService: crosswordService,
            scrabbleService: scrabbleService,
            anagramService: anagramService,
            definitionsService: definitionsService
        )
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 12)
            .background(Color(.systemGroupedBackground))
    }
}

private struct PatternEntryField: View {
    @ObservedObject var session: SolverSession
    let placeholder: String
    let instructions: String

    @FocusState private var isPatternFieldFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            TextField(placeholder, text: $session.rawPattern)
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

            Text(instructions)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Current pattern")
    }
}

private struct ToolTabs: View {
    @ObservedObject var session: SolverSession
    let crosswordService: CrosswordSearchService
    let scrabbleService: ScrabbleSearchService
    let anagramService: AnagramSearchService
    let definitionsService: DefinitionsLookupService

    var body: some View {
        TabView(selection: $session.selectedTool) {
            Tab("Crossword", systemImage: SolverTool.crossword.systemImage, value: .crossword) {
                CrosswordToolView(session: session, searchService: crosswordService)
            }

            Tab("Scrabble", systemImage: SolverTool.scrabble.systemImage, value: .scrabble) {
                ScrabbleToolView(session: session, searchService: scrabbleService)
            }

            Tab("Anagram", systemImage: SolverTool.anagramSolver.systemImage, value: .anagramSolver) {
                AnagramToolView(session: session, searchService: anagramService)
            }

            Tab("Generator", systemImage: SolverTool.anagramGenerator.systemImage, value: .anagramGenerator) {
                PlaceholderToolView(tool: .anagramGenerator)
            }

            Tab("Define", systemImage: SolverTool.definitions.systemImage, value: .definitions) {
                DefinitionsToolView(session: session, lookupService: definitionsService)
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
                PatternEntryField(
                    session: session,
                    placeholder: "Example: c?t or ice-cream",
                    instructions: "Letters stay fixed, `?` or `.` or spaces match one letter, `*` or `+` match a run, and `-` splits words."
                )
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
            WordResultsCard(entries: matches.map(\.displayText))
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

private struct AnagramToolView: View {
    @ObservedObject var session: SolverSession
    let searchService: AnagramSearchService

    @State private var presentationState: AnagramPresentationState = .idle

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                PatternEntryField(
                    session: session,
                    placeholder: "Example: stare",
                    instructions: "Anagram solving currently supports one word made of letters only and searches the bundled test crossword list offline."
                )
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

    private var queryState: AnagramQueryState {
        AnagramQueryState(patternState: session.queryState)
    }

    private var queryFingerprint: String {
        switch queryState {
        case .empty:
            "empty"
        case .invalid(let message):
            "invalid:\(message)"
        case .valid(let query):
            "valid:\(query.letters)"
        }
    }

    @ViewBuilder
    private var content: some View {
        switch presentationState {
        case .idle:
            SearchMessageCard(
                title: "Start with letters",
                message: "Enter a single word above and the anagram tab will look for rearrangements in the bundled test crossword list.",
                symbol: "arrow.trianglehead.2.clockwise",
                tint: .secondary
            )
            .accessibilityIdentifier("anagram-status-card")
        case .loading:
            SearchMessageCard(
                title: "Searching for anagrams",
                message: "The anagram tool is checking the bundled test crossword list on this device.",
                symbol: "hourglass",
                tint: .blue
            )
            .accessibilityIdentifier("anagram-status-card")
        case .empty(let letters):
            SearchMessageCard(
                title: "No anagrams for \(letters)",
                message: "Try another set of letters from the test crossword list.",
                symbol: "text.magnifyingglass",
                tint: .secondary
            )
            .accessibilityIdentifier("anagram-status-card")
        case .invalid(let message):
            SearchMessageCard(
                title: "Fix the input first",
                message: message,
                symbol: "exclamationmark.triangle",
                tint: .orange
            )
            .accessibilityIdentifier("anagram-status-card")
        case .failed(let message):
            SearchMessageCard(
                title: "Anagram search unavailable",
                message: message,
                symbol: "xmark.octagon",
                tint: .red
            )
            .accessibilityIdentifier("anagram-status-card")
        case .results(let matches):
            WordResultsCard(entries: matches.map(\.displayText))
                .accessibilityIdentifier("anagram-results-card")
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
        case .valid:
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
                ? .empty(query.letters)
                : .results(resolvedMatches)
        } catch is CancellationError {
            return
        } catch {
            presentationState = .failed(error.localizedDescription)
        }
    }
}

private struct ScrabbleToolView: View {
    @ObservedObject var session: SolverSession
    let searchService: ScrabbleSearchService

    @State private var presentationState: ScrabblePresentationState = .idle

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                PatternEntryField(
                    session: session,
                    placeholder: "Example: stare? or trades",
                    instructions: "Enter the letters in your rack. Use `?` for blank tiles. Results can use any subset of the available tiles from the bundled test Scrabble list."
                )
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

    private var queryState: ScrabbleRackQueryState {
        ScrabbleRackQueryState(rawInput: session.rawPattern)
    }

    private var queryFingerprint: String {
        switch queryState {
        case .empty:
            "empty"
        case .invalid(let message):
            "invalid:\(message)"
        case .valid(let query):
            "valid:\(query.normalizedRack)"
        }
    }

    @ViewBuilder
    private var content: some View {
        switch presentationState {
        case .idle:
            SearchMessageCard(
                title: "Start with rack tiles",
                message: "Enter the tiles in your rack above and the Scrabble tab will show any words from the bundled test list that can be made from any subset of them.",
                symbol: "textformat.abc",
                tint: .secondary
            )
            .accessibilityIdentifier("scrabble-status-card")
        case .loading:
            SearchMessageCard(
                title: "Searching the Scrabble list",
                message: "The Scrabble tool is checking the bundled test list on this device.",
                symbol: "hourglass",
                tint: .blue
            )
            .accessibilityIdentifier("scrabble-status-card")
        case .empty(let rack):
            SearchMessageCard(
                title: "No words for \(rack)",
                message: "Try another rack or add `?` for blank tiles.",
                symbol: "text.magnifyingglass",
                tint: .secondary
            )
            .accessibilityIdentifier("scrabble-status-card")
        case .invalid(let message):
            SearchMessageCard(
                title: "Fix the rack first",
                message: message,
                symbol: "exclamationmark.triangle",
                tint: .orange
            )
            .accessibilityIdentifier("scrabble-status-card")
        case .failed(let message):
            SearchMessageCard(
                title: "Scrabble search unavailable",
                message: message,
                symbol: "xmark.octagon",
                tint: .red
            )
            .accessibilityIdentifier("scrabble-status-card")
        case .results(let matches):
            WordResultsCard(entries: matches.map(\.displayText))
                .accessibilityIdentifier("scrabble-results-card")
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
        case .valid:
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
                ? .empty(query.normalizedRack)
                : .results(resolvedMatches)
        } catch is CancellationError {
            return
        } catch {
            presentationState = .failed(error.localizedDescription)
        }
    }
}

private struct DefinitionsToolView: View {
    @ObservedObject var session: SolverSession
    let lookupService: DefinitionsLookupService

    @State private var presentationState: DefinitionsPresentationState = .idle

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                PatternEntryField(
                    session: session,
                    placeholder: "Example: solver or word game",
                    instructions: "Enter a literal word or phrase to look it up in the bundled offline test definitions list."
                )
                content
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 32)
        }
        .scrollIndicators(.hidden)
        .task(id: queryFingerprint) {
            await refreshDefinition()
        }
    }

    private var queryState: DefinitionLookupQueryState {
        DefinitionLookupQueryState(rawInput: session.rawPattern)
    }

    private var queryFingerprint: String {
        switch queryState {
        case .empty:
            "empty"
        case .invalid(let message):
            "invalid:\(message)"
        case .valid(let query):
            "valid:\(query.lookupKey)"
        }
    }

    @ViewBuilder
    private var content: some View {
        switch presentationState {
        case .idle:
            SearchMessageCard(
                title: "Start with a word",
                message: "Enter a literal word or phrase above and the definitions tab will search the bundled offline test definitions list.",
                symbol: "book.closed",
                tint: .secondary
            )
            .accessibilityIdentifier("definitions-status-card")
        case .loading:
            SearchMessageCard(
                title: "Looking up definitions",
                message: "The definitions tool is checking the bundled test definitions list on this device.",
                symbol: "hourglass",
                tint: .blue
            )
            .accessibilityIdentifier("definitions-status-card")
        case .empty(let term):
            SearchMessageCard(
                title: "No definition for \(term)",
                message: "Try another literal word or phrase from the test definitions list.",
                symbol: "text.magnifyingglass",
                tint: .secondary
            )
            .accessibilityIdentifier("definitions-status-card")
        case .invalid(let message):
            SearchMessageCard(
                title: "Fix the lookup first",
                message: message,
                symbol: "exclamationmark.triangle",
                tint: .orange
            )
            .accessibilityIdentifier("definitions-status-card")
        case .failed(let message):
            SearchMessageCard(
                title: "Definitions lookup unavailable",
                message: message,
                symbol: "xmark.octagon",
                tint: .red
            )
            .accessibilityIdentifier("definitions-status-card")
        case .result(let entry):
            DefinitionResultCard(entry: entry)
                .accessibilityIdentifier("definitions-result-card")
        }
    }

    @MainActor
    private func refreshDefinition() async {
        switch queryState {
        case .empty:
            presentationState = .idle
            return
        case .invalid(let message):
            presentationState = .invalid(message)
            return
        case .valid:
            break
        }

        presentationState = .loading

        guard case .valid(let query) = queryState else {
            return
        }

        do {
            let resolvedEntry = try await lookupService.lookup(query)

            guard Task.isCancelled == false else {
                return
            }

            presentationState = resolvedEntry.map(DefinitionsPresentationState.result)
                ?? .empty(query.lookupKey)
        } catch is CancellationError {
            return
        } catch {
            presentationState = .failed(error.localizedDescription)
        }
    }
}

private struct WordResultsCard: View {
    let entries: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            LazyVStack(alignment: .leading, spacing: 10) {
                ForEach(entries, id: \.self) { entry in
                    Text(entry)
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

private struct DefinitionResultCard: View {
    let entry: DefinitionEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(entry.word)
                .font(.title3.weight(.semibold))

            Text(entry.pronunciation)
                .font(.body.monospaced())
                .foregroundStyle(.secondary)

            Text(entry.definition)
                .font(.body)
                .foregroundStyle(.primary)
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

private enum AnagramPresentationState {
    case idle
    case loading
    case empty(String)
    case invalid(String)
    case failed(String)
    case results([AnagramMatch])
}

private enum ScrabblePresentationState {
    case idle
    case loading
    case empty(String)
    case invalid(String)
    case failed(String)
    case results([ScrabbleMatch])
}

private enum DefinitionsPresentationState {
    case idle
    case loading
    case empty(String)
    case invalid(String)
    case failed(String)
    case result(DefinitionEntry)
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
