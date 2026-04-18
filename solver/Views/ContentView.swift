import SwiftUI

private enum SolverLayoutMetrics {
    static let horizontalInset: CGFloat = 20
    static let inputTextInset: CGFloat = 14
    static let floatingControlsBottomPadding: CGFloat = 12
    static let toolContentBottomPadding: CGFloat = 104
}

struct ContentView: View {
    @StateObject private var session: SolverSession
    @State private var services: SolverServices

    init() {
        let session = SolverSession()
        _session = StateObject(wrappedValue: session)
        _services = State(
            initialValue: SolverServices(wordListGroup: session.selectedWordListGroup))
    }

    var body: some View {
        SolverHomeView(
            session: session,
            wordListGroup: services.wordListGroup,
            crosswordService: services.crosswordService,
            scrabbleService: services.scrabbleService,
            anagramService: services.anagramService,
            definitionsService: services.definitionsService,
            thesaurusService: services.thesaurusService,
            solutionDetailsService: services.solutionDetailsService
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
    let solutionDetailsService: SolutionDetailsLookupService

    @State private var presentedSheet: SolverSecondarySheet?
    @State private var presentedSolutionWord: String?
    @State private var presentedSolutionOrigin: SolutionDetailsPresentationOrigin?
    @State private var solutionDetailsState: SolutionDetailsPresentationState = .idle

    var body: some View {
        ToolTabs(
            session: session,
            wordListGroup: wordListGroup,
            crosswordService: crosswordService,
            scrabbleService: scrabbleService,
            anagramService: anagramService,
            definitionsService: definitionsService,
            thesaurusService: thesaurusService,
            onPresentSolutionDetails: presentSolutionDetails,
            onEndSolutionHover: endSolutionHover
        )
        .padding(.horizontal, SolverLayoutMetrics.horizontalInset)
        .padding(.top, 12)
        .background(Color(.systemGroupedBackground))
        .overlay {
            if let presentedSolutionWord {
                Color.black.opacity(0.09)
                    .ignoresSafeArea()
                    .onTapGesture {
                        dismissSolutionDetails()
                    }

                SolutionDetailsOverlayCard(
                    displayWord: presentedSolutionWord,
                    state: solutionDetailsState,
                    onDismiss: dismissSolutionDetails
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, SolverLayoutMetrics.horizontalInset)
            }
        }
        .overlay(alignment: .bottom) {
            BottomStatusBar(
                session: session,
                onPresentSheet: { presentedSheet = $0 }
            )
            .padding(.horizontal, SolverLayoutMetrics.horizontalInset)
            .padding(.bottom, SolverLayoutMetrics.floatingControlsBottomPadding)
        }
        .sheet(item: $presentedSheet) { sheet in
            SolverSecondarySheetView(
                sheet: sheet,
                session: session
            )
        }
        .task(id: solutionDetailsTaskID) {
            await refreshSolutionDetails()
        }
    }

    private var solutionDetailsTaskID: String {
        presentedSolutionWord ?? ""
    }

    private func presentSolutionDetails(
        for displayWord: String,
        origin: SolutionDetailsPresentationOrigin
    ) {
        presentedSolutionWord = displayWord
        presentedSolutionOrigin = origin
        solutionDetailsState = .loading(displayWord: displayWord)
    }

    private func endSolutionHover() {
        if presentedSolutionOrigin == .hover {
            dismissSolutionDetails()
        }
    }

    private func dismissSolutionDetails() {
        presentedSolutionWord = nil
        presentedSolutionOrigin = nil
        solutionDetailsState = .idle
    }

    @MainActor
    private func refreshSolutionDetails() async {
        guard let presentedSolutionWord else {
            solutionDetailsState = .idle
            return
        }

        solutionDetailsState = .loading(displayWord: presentedSolutionWord)

        do {
            let details = try await solutionDetailsService.lookupDetails(for: presentedSolutionWord)

            guard Task.isCancelled == false, self.presentedSolutionWord == presentedSolutionWord else {
                return
            }

            solutionDetailsState =
                details.hasAnyContent
                ? .loaded(details)
                : .empty(displayWord: presentedSolutionWord)
        } catch is CancellationError {
            return
        } catch {
            guard self.presentedSolutionWord == presentedSolutionWord else {
                return
            }

            solutionDetailsState = .failed(
                displayWord: presentedSolutionWord,
                message: error.localizedDescription
            )
        }
    }
}

private struct SolverServices {
    let wordListGroup: WordListGroup
    let crosswordService: CrosswordSearchService
    let scrabbleService: ScrabbleSearchService
    let anagramService: AnagramSearchService
    let definitionsService: DefinitionsLookupService
    let thesaurusService: ThesaurusLookupService
    let solutionDetailsService: SolutionDetailsLookupService

    init(wordListGroup: WordListGroup) {
        self.wordListGroup = wordListGroup
        self.crosswordService = CrosswordSearchService(wordListGroup: wordListGroup)
        self.scrabbleService = ScrabbleSearchService(wordListGroup: wordListGroup)
        self.anagramService = AnagramSearchService(wordListGroup: wordListGroup)
        self.definitionsService = DefinitionsLookupService(wordListGroup: wordListGroup)
        self.thesaurusService = ThesaurusLookupService(wordListGroup: wordListGroup)
        self.solutionDetailsService = SolutionDetailsLookupService(
            definitionsService: definitionsService,
            thesaurusService: thesaurusService
        )
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
    let onPresentSolutionDetails: (String, SolutionDetailsPresentationOrigin) -> Void
    let onEndSolutionHover: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Keep the selector outside the tool scroll views so it stays reachable while tool content scrolls.
            ToolSelector(selectedTool: $session.selectedTool)
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
                searchService: crosswordService,
                onPresentSolutionDetails: onPresentSolutionDetails,
                onEndSolutionHover: onEndSolutionHover
            )
        case .scrabble:
            ScrabbleToolView(
                session: session,
                wordListGroup: wordListGroup,
                searchService: scrabbleService,
                onPresentSolutionDetails: onPresentSolutionDetails,
                onEndSolutionHover: onEndSolutionHover
            )
        case .anagramSolver:
            AnagramToolView(
                session: session,
                wordListGroup: wordListGroup,
                searchService: anagramService,
                onPresentSolutionDetails: onPresentSolutionDetails,
                onEndSolutionHover: onEndSolutionHover
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

private struct BottomStatusBar: View {
    @ObservedObject var session: SolverSession
    let onPresentSheet: (SolverSecondarySheet) -> Void

    @State private var isWordListDialogPresented = false
    @State private var isSecondaryMenuPresented = false

    var body: some View {
        HStack(spacing: 12) {
            WordListStatusButton(
                session: session,
                isPresented: $isWordListDialogPresented
            )
            Spacer(minLength: 0)
            SecondaryActionsButton(isPresented: $isSecondaryMenuPresented)
        }
        .padding(.vertical, 8)
        .accessibilityIdentifier("bottom-status-bar")
        .confirmationDialog(
            "Word list",
            isPresented: $isWordListDialogPresented,
            titleVisibility: .visible
        ) {
            ForEach(WordListGroup.allCases) { group in
                Button(group.title) {
                    session.selectedWordListGroup = group
                }
            }
        } message: {
            Text(
                "Choose the bundled word-list group Solver should use across the implemented tools."
            )
        }
        .confirmationDialog(
            "More",
            isPresented: $isSecondaryMenuPresented,
            titleVisibility: .visible
        ) {
            Button("Preferences") {
                onPresentSheet(.preferences)
            }

            Button("Help") {
                onPresentSheet(.help)
            }

            Button("About") {
                onPresentSheet(.about)
            }
        }
    }
}

private struct WordListStatusButton: View {
    @ObservedObject var session: SolverSession
    @Binding var isPresented: Bool

    var body: some View {
        Button {
            isPresented = true
        } label: {
            Text(session.selectedWordListGroup.title)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 9)
                .background(
                    Capsule(style: .continuous)
                        .fill(.ultraThinMaterial)
                )
                .overlay(
                    Capsule(style: .continuous)
                        .strokeBorder(Color(.separator).opacity(0.18))
                )
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Word list")
        .accessibilityValue(session.selectedWordListGroup.title)
        .accessibilityHint("Shows the active bundled word list and lets you switch it.")
        .accessibilityIdentifier("word-list-preferences-button")
    }
}

private struct SecondaryActionsButton: View {
    @Binding var isPresented: Bool

    var body: some View {
        Button {
            isPresented = true
        } label: {
            Label("More", systemImage: "line.3.horizontal")
                .labelStyle(.iconOnly)
                .font(.body.weight(.semibold))
                .foregroundStyle(.primary)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(.ultraThinMaterial)
                )
                .overlay(
                    Circle()
                        .strokeBorder(Color(.separator).opacity(0.18))
                )
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("More")
        .accessibilityHint("Open preferences, help, and about.")
        .accessibilityIdentifier("secondary-actions-button")
    }
}

private enum SolverSecondarySheet: String, Identifiable {
    case preferences
    case help
    case about

    var id: String { rawValue }
}

private struct SolverSecondarySheetView: View {
    let sheet: SolverSecondarySheet
    @ObservedObject var session: SolverSession

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    content
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
            }
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch sheet {
        case .preferences:
            PreferencesSheetContent(session: session)
        case .help:
            HelpSheetContent()
        case .about:
            AboutSheetContent()
        }
    }

    private var title: String {
        switch sheet {
        case .preferences:
            "Preferences"
        case .help:
            "Help"
        case .about:
            "About"
        }
    }
}

private struct PreferencesSheetContent: View {
    @ObservedObject var session: SolverSession

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(
                "Choose the bundled word-list group Solver should use across the implemented tools."
            )
            .font(.body)
            .foregroundStyle(.secondary)

            VStack(spacing: 12) {
                ForEach(WordListGroup.allCases) { group in
                    Button {
                        session.selectedWordListGroup = group
                    } label: {
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(group.title)
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                Text(group.sourceDescription)
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer(minLength: 0)

                            if session.selectedWordListGroup == group {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(Color.accentColor)
                            }
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(Color(.secondarySystemBackground))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .strokeBorder(
                                    session.selectedWordListGroup == group
                                        ? Color.accentColor : Color(.separator).opacity(0.35),
                                    lineWidth: session.selectedWordListGroup == group ? 2 : 1
                                )
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

private struct HelpSheetContent: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            helpSection(
                title: "Crossword",
                body:
                    "Use letters to lock positions, `?` or `.` for one unknown letter, `*` or `+` for a run of letters, and `-` to split words."
            )
            helpSection(
                title: "Scrabble",
                body:
                    "Use the main field for rack letters, `?` for blanks, and the extra fields for letters already on the board."
            )
            helpSection(
                title: "Definitions and Thesaurus",
                body:
                    "Enter literal words or phrases only. These tools do not support wildcard or rack-style input."
            )
        }
    }

    private func helpSection(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)
            Text(body)
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }
}

private struct AboutSheetContent: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Solver")
                .font(.title2.weight(.semibold))

            Text(
                "Solver is an offline word-game helper for crossword patterns, Scrabble racks, anagrams, definitions, and thesaurus lookup."
            )
            .font(.body)
            .foregroundStyle(.secondary)

            Text(
                "All implemented searches and lookups run locally from bundled word lists on this device."
            )
            .font(.body)
            .foregroundStyle(.secondary)
        }
    }
}

private struct CrosswordToolView: View {
    @ObservedObject var session: SolverSession
    let wordListGroup: WordListGroup
    let searchService: CrosswordSearchService
    let onPresentSolutionDetails: (String, SolutionDetailsPresentationOrigin) -> Void
    let onEndSolutionHover: () -> Void

    @State private var presentationState: CrosswordPresentationState = .idle

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                PatternEntryField(
                    session: session,
                    placeholder: "Example: c?t or pancho villa",
                    instructions:
                        "Letters stay fixed, `?` or `.` match one letter, `*` or `+` match a run, and spaces or `-` split words."
                )
                content
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, SolverLayoutMetrics.toolContentBottomPadding)
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
            WordResultsCard(
                entries: matches.map(\.displayText),
                onPresentSolutionDetails: onPresentSolutionDetails,
                onEndSolutionHover: onEndSolutionHover
            )
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
    let onPresentSolutionDetails: (String, SolutionDetailsPresentationOrigin) -> Void
    let onEndSolutionHover: () -> Void

    @State private var presentationState: AnagramPresentationState = .idle

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                PatternEntryField(
                    session: session,
                    placeholder: "Example: stare or villap-ancho",
                    instructions:
                        "Anagram solving supports letters-only input, including separated phrase input such as `villap-ancho`, and searches the bundled crossword list offline."
                )
                content
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, SolverLayoutMetrics.toolContentBottomPadding)
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
            "valid:\(wordListGroup.rawValue):\(query.normalizedInput)"
        }
    }

    @ViewBuilder
    private var content: some View {
        switch presentationState {
        case .idle:
            SearchMessageCard(
                title: "Start with letters",
                message:
                    "Enter letters above and the anagram tab will look for rearrangements in the bundled crossword list, including phrase entries.",
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
                message: "Try another arrangement of letters from the selected bundled crossword list.",
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
            WordResultsCard(
                entries: matches.map(\.displayText),
                onPresentSolutionDetails: onPresentSolutionDetails,
                onEndSolutionHover: onEndSolutionHover
            )
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
                ? .empty(query.normalizedInput)
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
    let onPresentSolutionDetails: (String, SolutionDetailsPresentationOrigin) -> Void
    let onEndSolutionHover: () -> Void

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
            .padding(.bottom, SolverLayoutMetrics.toolContentBottomPadding)
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
            WordResultsCard(
                entries: matches.map(\.displayText),
                onPresentSolutionDetails: onPresentSolutionDetails,
                onEndSolutionHover: onEndSolutionHover
            )
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
            .padding(.bottom, SolverLayoutMetrics.toolContentBottomPadding)
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
            .padding(.bottom, SolverLayoutMetrics.toolContentBottomPadding)
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
    let onPresentSolutionDetails: (String, SolutionDetailsPresentationOrigin) -> Void
    let onEndSolutionHover: () -> Void

    var body: some View {
        LazyVStack(alignment: .leading, spacing: 12) {
            ForEach(Array(entries.enumerated()), id: \.offset) { index, entry in
                WordResultRow(
                    entry: entry,
                    showsDivider: index < entries.count - 1,
                    onPresentSolutionDetails: onPresentSolutionDetails,
                    onEndSolutionHover: onEndSolutionHover
                )
            }
        }
        .padding(.leading, SolverLayoutMetrics.inputTextInset)
        .padding(.top, 4)
    }
}

private struct WordResultRow: View {
    let entry: String
    let showsDivider: Bool
    let onPresentSolutionDetails: (String, SolutionDetailsPresentationOrigin) -> Void
    let onEndSolutionHover: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(entry)
                .font(.body.monospaced())
                .frame(maxWidth: .infinity, alignment: .leading)

            if showsDivider {
                Divider()
            }
        }
        .contentShape(Rectangle())
        .onLongPressGesture(minimumDuration: 0.35) {
            onPresentSolutionDetails(entry, .longPress)
        }
        .accessibilityHint("Long press for local definition and thesaurus details.")
        .modifier(SolutionHoverPresentationModifier(
            onHoverStart: {
                onPresentSolutionDetails(entry, .hover)
            },
            onHoverEnd: onEndSolutionHover
        ))
    }
}

private struct SolutionHoverPresentationModifier: ViewModifier {
    let onHoverStart: () -> Void
    let onHoverEnd: () -> Void

    func body(content: Content) -> some View {
        content.onContinuousHover { phase in
            switch phase {
            case .active:
                onHoverStart()
            case .ended:
                onHoverEnd()
            }
        }
    }
}

private struct SolutionDetailsOverlayCard: View {
    let displayWord: String
    let state: SolutionDetailsPresentationState
    let onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 12) {
                Text(displayWord)
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Button("Done") {
                    onDismiss()
                }
                .font(.footnote.weight(.semibold))
            }

            content
        }
        .frame(maxWidth: 340, alignment: .leading)
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(Color(.separator).opacity(0.12))
        )
        .shadow(color: Color.black.opacity(0.16), radius: 18, y: 10)
        .accessibilityIdentifier("solution-details-overlay")
    }

    @ViewBuilder
    private var content: some View {
        switch state {
        case .idle, .loading:
            VStack(alignment: .leading, spacing: 12) {
                ProgressView()
                Text("Loading local definition and thesaurus details.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        case .empty:
            Text("No bundled definition or thesaurus entry is available for this solution in the current word list.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        case .failed(_, let message):
            Text(message)
                .font(.footnote)
                .foregroundStyle(.secondary)
        case .loaded(let details):
            VStack(alignment: .leading, spacing: 16) {
                if let definition = details.definition {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Definition")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(.secondary)

                        Text(definition.pronunciation)
                            .font(.body.monospaced())
                            .foregroundStyle(.secondary)

                        Text(definition.definition)
                            .font(.body)
                    }
                }

                if let thesaurus = details.thesaurus {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Synonyms")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(.secondary)

                        ForEach(Array(thesaurus.synonyms.enumerated()), id: \.offset) { index, synonym in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(synonym)
                                    .font(.body)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                if index < thesaurus.synonyms.count - 1 {
                                    Divider()
                                }
                            }
                        }
                    }
                }
            }
        }
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
        .padding(.leading, SolverLayoutMetrics.inputTextInset)
        .padding(.top, 4)
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
                ForEach(Array(entry.synonyms.enumerated()), id: \.offset) { index, synonym in
                    VStack(alignment: .leading, spacing: 10) {
                        Text(synonym)
                            .font(.body)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        if index < entry.synonyms.count - 1 {
                            Divider()
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, SolverLayoutMetrics.inputTextInset)
        .padding(.top, 4)
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
            .padding(.bottom, SolverLayoutMetrics.toolContentBottomPadding)
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
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: symbol)
                .font(.headline.weight(.semibold))
                .foregroundStyle(tint)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)

                Text(message)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, SolverLayoutMetrics.inputTextInset)
        .padding(.top, 4)
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

private enum SolutionDetailsPresentationOrigin {
    case longPress
    case hover
}

private enum SolutionDetailsPresentationState {
    case idle
    case loading(displayWord: String)
    case empty(displayWord: String)
    case failed(displayWord: String, message: String)
    case loaded(SolutionDetails)
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
