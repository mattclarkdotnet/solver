import SwiftUI

struct ContentView: View {
    @StateObject private var session: SolverSession
    @State private var services: SolverServices

    init() {
        let session = SolverSession()
        _session = StateObject(wrappedValue: session)
        _services = State(initialValue: SolverServices(wordListGroup: session.selectedWordListGroup))
    }

    var body: some View {
        SolverHomeView(
            session: session,
            wordListGroup: services.wordListGroup,
            crosswordService: services.crosswordService,
            scrabbleService: services.scrabbleService,
            anagramService: services.anagramService,
            definitionsService: services.definitionsService,
            thesaurusService: services.thesaurusService
        )
        .onChange(of: session.selectedWordListGroup) { _, newValue in
            services = SolverServices(wordListGroup: newValue)
        }
    }
}

private struct SolverHomeView: View {
    @ObservedObject var session: SolverSession
    let wordListGroup: WordListGroup
    let crosswordService: CrosswordSearchService
    let scrabbleService: ScrabbleSearchService
    let anagramService: AnagramSearchService
    let definitionsService: DefinitionsLookupService
    let thesaurusService: ThesaurusLookupService

    var body: some View {
        ToolTabs(
            session: session,
            wordListGroup: wordListGroup,
            crosswordService: crosswordService,
            scrabbleService: scrabbleService,
            anagramService: anagramService,
            definitionsService: definitionsService,
            thesaurusService: thesaurusService
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 12)
        .background(Color(.systemGroupedBackground))
    }
}

private struct SolverServices {
    let wordListGroup: WordListGroup
    let crosswordService: CrosswordSearchService
    let scrabbleService: ScrabbleSearchService
    let anagramService: AnagramSearchService
    let definitionsService: DefinitionsLookupService
    let thesaurusService: ThesaurusLookupService

    init(wordListGroup: WordListGroup) {
        self.wordListGroup = wordListGroup
        self.crosswordService = CrosswordSearchService(wordListGroup: wordListGroup)
        self.scrabbleService = ScrabbleSearchService(wordListGroup: wordListGroup)
        self.anagramService = AnagramSearchService(wordListGroup: wordListGroup)
        self.definitionsService = DefinitionsLookupService(wordListGroup: wordListGroup)
        self.thesaurusService = ThesaurusLookupService(wordListGroup: wordListGroup)
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
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(
                            isPatternFieldFocused
                                ? Color.accentColor : Color(.separator).opacity(0.6),
                            lineWidth: isPatternFieldFocused ? 2 : 1
                        )
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
    let wordListGroup: WordListGroup
    let crosswordService: CrosswordSearchService
    let scrabbleService: ScrabbleSearchService
    let anagramService: AnagramSearchService
    let definitionsService: DefinitionsLookupService
    let thesaurusService: ThesaurusLookupService

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Keep the selector and preferences control outside the tool scroll views so they stay reachable while tool content scrolls.
            HStack(alignment: .top, spacing: 12) {
                ToolSelector(selectedTool: $session.selectedTool)
                    .frame(maxWidth: .infinity)
                WordListPreferencesMenu(session: session)
            }
            selectedToolContent
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color(.systemGroupedBackground))
    }

    @ViewBuilder
    private var selectedToolContent: some View {
        switch session.selectedTool {
        case .crossword:
            CrosswordToolView(
                session: session,
                wordListGroup: wordListGroup,
                searchService: crosswordService
            )
        case .scrabble:
            ScrabbleToolView(
                session: session,
                wordListGroup: wordListGroup,
                searchService: scrabbleService
            )
        case .anagramSolver:
            AnagramToolView(
                session: session,
                wordListGroup: wordListGroup,
                searchService: anagramService
            )
        case .anagramGenerator:
            PlaceholderToolView(tool: .anagramGenerator)
        case .definitions:
            DefinitionsToolView(
                session: session,
                wordListGroup: wordListGroup,
                lookupService: definitionsService
            )
        case .scrabbleChecker:
            PlaceholderToolView(tool: .scrabbleChecker)
        case .thesaurus:
            ThesaurusToolView(
                session: session,
                wordListGroup: wordListGroup,
                lookupService: thesaurusService
            )
        }
    }
}

private struct ToolSelector: View {
    @Binding var selectedTool: SolverTool

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 10) {
                    ForEach(SolverTool.allCases) { tool in
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedTool = tool
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: tool.systemImage)
                                    .font(.footnote.weight(.semibold))
                                    .accessibilityHidden(true)

                                Text(tool.selectorTitle)
                                    .font(.subheadline.weight(.semibold))
                                    .lineLimit(1)
                            }
                            .foregroundStyle(selectedTool == tool ? Color.white : Color.primary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(
                                Capsule(style: .continuous)
                                    .fill(
                                        selectedTool == tool
                                            ? Color.accentColor : Color(.secondarySystemBackground))
                            )
                            .overlay(
                                Capsule(style: .continuous)
                                    .strokeBorder(
                                        selectedTool == tool
                                            ? Color.clear : Color(.separator).opacity(0.3)
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                        .id(tool.id)
                        .accessibilityIdentifier("tool-button-\(tool.rawValue)")
                        .accessibilityLabel(tool.selectorTitle)
                        .accessibilityAddTraits(selectedTool == tool ? .isSelected : [])
                    }
                }
                .padding(.vertical, 2)
            }
            .frame(height: 48, alignment: .top)
            .accessibilityIdentifier("tool-selector")
            .onAppear {
                scrollToSelectedTool(with: proxy, animated: false)
            }
            .onChange(of: selectedTool) { _, _ in
                scrollToSelectedTool(with: proxy, animated: true)
            }
        }
    }

    private func scrollToSelectedTool(with proxy: ScrollViewProxy, animated: Bool) {
        let action = {
            proxy.scrollTo(selectedTool.id, anchor: .center)
        }

        if animated {
            withAnimation(.easeInOut(duration: 0.2), action)
        } else {
            action()
        }
    }
}

private struct WordListPreferencesMenu: View {
    @ObservedObject var session: SolverSession

    var body: some View {
        Menu {
            Section("Word list") {
                ForEach(WordListGroup.allCases) { group in
                    Button {
                        session.selectedWordListGroup = group
                    } label: {
                        if session.selectedWordListGroup == group {
                            Label(group.title, systemImage: "checkmark")
                        } else {
                            Text(group.title)
                        }
                    }
                }
            }

            Section {
                Text(session.selectedWordListGroup.sourceDescription)
            }
        } label: {
            Image(systemName: "slider.horizontal.3")
                .font(.body.weight(.semibold))
                .foregroundStyle(.primary)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(Color(.secondarySystemBackground))
                )
                .overlay(
                    Circle()
                        .strokeBorder(Color(.separator).opacity(0.3))
                )
        }
        .accessibilityIdentifier("word-list-preferences-button")
        .accessibilityLabel("Word list preferences")
        .accessibilityValue(session.selectedWordListGroup.title)
        .accessibilityHint("Choose the active bundled word list group.")
    }
}

private struct CrosswordToolView: View {
    @ObservedObject var session: SolverSession
    let wordListGroup: WordListGroup
    let searchService: CrosswordSearchService

    @State private var presentationState: CrosswordPresentationState = .idle

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                PatternEntryField(
                    session: session,
                    placeholder: "Example: c?t or ice-cream",
                    instructions:
                        "Letters stay fixed, `?` or `.` or spaces match one letter, `*` or `+` match a run, and `-` splits words."
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
            "empty:\(wordListGroup.rawValue)"
        case .invalid(let message):
            "invalid:\(wordListGroup.rawValue):\(message)"
        case .valid(let query):
            "valid:\(wordListGroup.rawValue):\(query.normalizedPattern)"
        }
    }

    @ViewBuilder
    private var content: some View {
        switch presentationState {
        case .idle:
            SearchMessageCard(
                title: "Start with a pattern",
                message:
                    "Enter a word or phrase pattern above and live results will appear here from the bundled offline list.",
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
                message:
                    "Try widening the pattern with `?` for a single unknown letter or `*` for a longer run.",
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

            presentationState =
                resolvedMatches.isEmpty
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
    let wordListGroup: WordListGroup
    let searchService: AnagramSearchService

    @State private var presentationState: AnagramPresentationState = .idle

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                PatternEntryField(
                    session: session,
                    placeholder: "Example: stare",
                    instructions:
                        "Anagram solving currently supports one word made of letters only and searches the bundled test crossword list offline."
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
            "empty:\(wordListGroup.rawValue)"
        case .invalid(let message):
            "invalid:\(wordListGroup.rawValue):\(message)"
        case .valid(let query):
            "valid:\(wordListGroup.rawValue):\(query.letters)"
        }
    }

    @ViewBuilder
    private var content: some View {
        switch presentationState {
        case .idle:
            SearchMessageCard(
                title: "Start with letters",
                message:
                    "Enter a single word above and the anagram tab will look for rearrangements in the bundled test crossword list.",
                symbol: "arrow.trianglehead.2.clockwise",
                tint: .secondary
            )
            .accessibilityIdentifier("anagram-status-card")
        case .loading:
            SearchMessageCard(
                title: "Searching for anagrams",
                message:
                    "The anagram tool is checking the bundled test crossword list on this device.",
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

            presentationState =
                resolvedMatches.isEmpty
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
    let wordListGroup: WordListGroup
    let searchService: ScrabbleSearchService

    @State private var presentationState: ScrabblePresentationState = .idle

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                PatternEntryField(
                    session: session,
                    placeholder: "Example: stare? or trades",
                    instructions:
                        "Enter the letters in your rack. Use `?` for blank tiles. Add board letters below to constrain where known letters already appear in the word."
                )
                ScrabbleBoardFields(session: session)
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

    private var queryState: ScrabbleQueryState {
        ScrabbleQueryState(
            rackInput: session.rawPattern,
            startLetterInput: session.scrabbleStartLetter,
            endLetterInput: session.scrabbleEndLetter,
            otherLettersInput: session.scrabbleOtherLetters
        )
    }

    private var queryFingerprint: String {
        switch queryState {
        case .empty:
            "empty:\(wordListGroup.rawValue)"
        case .invalid(let message):
            "invalid:\(wordListGroup.rawValue):\(message)"
        case .valid(let query):
            "valid:\(wordListGroup.rawValue):\(query.normalizedDescription)"
        }
    }

    @ViewBuilder
    private var content: some View {
        switch presentationState {
        case .idle:
            SearchMessageCard(
                title: "Start with rack tiles",
                message:
                    "Enter your rack above, then optionally add board letters to constrain the start, end, or interior letters of a matching word from the bundled test list.",
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
                message: "Try another rack, adjust the board letters, or add `?` for blank tiles.",
                symbol: "text.magnifyingglass",
                tint: .secondary
            )
            .accessibilityIdentifier("scrabble-status-card")
        case .invalid(let message):
            SearchMessageCard(
                title: "Fix the Scrabble letters first",
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

            presentationState =
                resolvedMatches.isEmpty
                ? .empty(query.normalizedDescription)
                : .results(resolvedMatches)
        } catch is CancellationError {
            return
        } catch {
            presentationState = .failed(error.localizedDescription)
        }
    }
}

private struct ScrabbleBoardFields: View {
    @ObservedObject var session: SolverSession

    @FocusState private var focusedField: Field?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Board letters")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                boardField(
                    title: "Start letter",
                    text: $session.scrabbleStartLetter,
                    placeholder: "A",
                    identifier: "scrabble-start-letter-field",
                    field: .start
                )

                boardField(
                    title: "End letter",
                    text: $session.scrabbleEndLetter,
                    placeholder: "Z",
                    identifier: "scrabble-end-letter-field",
                    field: .end
                )
            }

            boardField(
                title: "Other letters",
                text: $session.scrabbleOtherLetters,
                placeholder: "Placed letters already on the board",
                identifier: "scrabble-other-letters-field",
                field: .other
            )

            Text(
                "Board letters stay fixed on the board. If start or end is empty, `other letters` can still satisfy that edge of the word."
            )
            .font(.footnote)
            .foregroundStyle(.secondary)
        }
    }

    private func boardField(
        title: String,
        text: Binding<String>,
        placeholder: String,
        identifier: String,
        field: Field
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.footnote.weight(.medium))
                .foregroundStyle(.secondary)

            TextField(placeholder, text: text)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .font(.body.monospaced())
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color(.secondarySystemBackground))
                )
                .focused($focusedField, equals: field)
                .accessibilityIdentifier(identifier)
                .onSubmit {
                    focusedField = nil
                }
        }
    }

    private enum Field: Hashable {
        case start
        case end
        case other
    }
}

private struct DefinitionsToolView: View {
    @ObservedObject var session: SolverSession
    let wordListGroup: WordListGroup
    let lookupService: DefinitionsLookupService

    @State private var presentationState: DefinitionsPresentationState = .idle

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                PatternEntryField(
                    session: session,
                    placeholder: "Example: solver or word game",
                    instructions:
                        "Enter a literal word or phrase to look it up in the bundled offline test definitions list."
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
            "empty:\(wordListGroup.rawValue)"
        case .invalid(let message):
            "invalid:\(wordListGroup.rawValue):\(message)"
        case .valid(let query):
            "valid:\(wordListGroup.rawValue):\(query.lookupKey)"
        }
    }

    @ViewBuilder
    private var content: some View {
        switch presentationState {
        case .idle:
            SearchMessageCard(
                title: "Start with a word",
                message:
                    "Enter a literal word or phrase above and the definitions tab will search the bundled offline test definitions list.",
                symbol: "book.closed",
                tint: .secondary
            )
            .accessibilityIdentifier("definitions-status-card")
        case .loading:
            SearchMessageCard(
                title: "Looking up definitions",
                message:
                    "The definitions tool is checking the bundled test definitions list on this device.",
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

            presentationState =
                resolvedEntry.map(DefinitionsPresentationState.result)
                ?? .empty(query.lookupKey)
        } catch is CancellationError {
            return
        } catch {
            presentationState = .failed(error.localizedDescription)
        }
    }
}

private struct ThesaurusToolView: View {
    @ObservedObject var session: SolverSession
    let wordListGroup: WordListGroup
    let lookupService: ThesaurusLookupService

    @State private var presentationState: ThesaurusPresentationState = .idle

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                PatternEntryField(
                    session: session,
                    placeholder: "Example: solver or word game",
                    instructions:
                        "Enter a literal word or phrase to look it up in the bundled offline test thesaurus list."
                )
                content
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 32)
        }
        .scrollIndicators(.hidden)
        .task(id: queryFingerprint) {
            await refreshThesaurus()
        }
    }

    private var queryState: ThesaurusLookupQueryState {
        ThesaurusLookupQueryState(rawInput: session.rawPattern)
    }

    private var queryFingerprint: String {
        switch queryState {
        case .empty:
            "empty:\(wordListGroup.rawValue)"
        case .invalid(let message):
            "invalid:\(wordListGroup.rawValue):\(message)"
        case .valid(let query):
            "valid:\(wordListGroup.rawValue):\(query.lookupKey)"
        }
    }

    @ViewBuilder
    private var content: some View {
        switch presentationState {
        case .idle:
            SearchMessageCard(
                title: "Start with a word",
                message:
                    "Enter a literal word or phrase above and the thesaurus tab will search the bundled offline test thesaurus list.",
                symbol: "text.book.closed",
                tint: .secondary
            )
            .accessibilityIdentifier("thesaurus-status-card")
        case .loading:
            SearchMessageCard(
                title: "Looking up synonyms",
                message:
                    "The thesaurus tool is checking the bundled test thesaurus list on this device.",
                symbol: "hourglass",
                tint: .blue
            )
            .accessibilityIdentifier("thesaurus-status-card")
        case .empty(let term):
            SearchMessageCard(
                title: "No synonyms for \(term)",
                message: "Try another literal word or phrase from the test thesaurus list.",
                symbol: "text.magnifyingglass",
                tint: .secondary
            )
            .accessibilityIdentifier("thesaurus-status-card")
        case .invalid(let message):
            SearchMessageCard(
                title: "Fix the lookup first",
                message: message,
                symbol: "exclamationmark.triangle",
                tint: .orange
            )
            .accessibilityIdentifier("thesaurus-status-card")
        case .failed(let message):
            SearchMessageCard(
                title: "Thesaurus lookup unavailable",
                message: message,
                symbol: "xmark.octagon",
                tint: .red
            )
            .accessibilityIdentifier("thesaurus-status-card")
        case .result(let entry):
            ThesaurusResultCard(entry: entry)
                .accessibilityIdentifier("thesaurus-result-card")
        }
    }

    @MainActor
    private func refreshThesaurus() async {
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

            presentationState =
                resolvedEntry.map(ThesaurusPresentationState.result)
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

private struct ThesaurusResultCard: View {
    let entry: ThesaurusEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(entry.word)
                .font(.title3.weight(.semibold))

            Text("Synonyms")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)

            LazyVStack(alignment: .leading, spacing: 10) {
                ForEach(entry.synonyms, id: \.self) { synonym in
                    Text(synonym)
                        .font(.body)
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

private enum ThesaurusPresentationState {
    case idle
    case loading
    case empty(String)
    case invalid(String)
    case failed(String)
    case result(ThesaurusEntry)
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
