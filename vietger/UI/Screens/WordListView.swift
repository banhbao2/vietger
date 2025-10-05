import SwiftUI

struct WordListView: View {
    @EnvironmentObject var environment: AppEnvironment
    @State private var selectedDeck: DeckType = .core
    @State private var searchText = ""
    @State private var showStats = true
    @State private var showResetAlert = false
    
    var body: some View {
        ZStack {
            Theme.Colors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                if showStats { statsHeader }
                deckSelector
                searchBar
                wordList
            }
        }
        .navigationTitle("Vocabulary")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbarContent }
        .alert("Reset Progress?", isPresented: $showResetAlert) {
            resetAlertButtons
        } message: {
            Text("This will mark all words as not learned.")
        }
    }
    
    // MARK: - Computed Properties
    private var words: [Word] { environment.words(for: selectedDeck) }
    
    private var filteredWords: [Word] {
        guard !searchText.isEmpty else { return words }
        return words.filter { word in
            wordContainsSearch(word, searchText: searchText)
        }
    }
    
    private var learnedCount: Int {
        words.filter { environment.isLearned($0, deck: selectedDeck) }.count
    }
    
    private var progress: Double {
        words.isEmpty ? 0 : Double(learnedCount) / Double(words.count)
    }
    
    // MARK: - View Components
    private var statsHeader: some View {
        VStack(spacing: Theme.Spacing.m) {
            statsCards
            LinearProgress(progress: progress)
            progressText
        }
        .padding(Theme.Spacing.m)
        .background(Theme.Colors.card)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card))
        .padding(Theme.Spacing.m)
    }
    
    private var statsCards: some View {
        HStack(spacing: Theme.Spacing.m) {
            StatCard(
                icon: "books.vertical",
                value: "\(words.count)",
                label: "Total",
                color: Theme.Colors.primary
            )
            
            StatCard(
                icon: "checkmark.seal",
                value: "\(learnedCount)",
                label: "Learned",
                color: Theme.Colors.success
            )
            
            StatCard(
                icon: "book.closed",
                value: "\(words.count - learnedCount)",
                label: "To Learn",
                color: Theme.Colors.warning
            )
        }
    }
    
    private var progressText: some View {
        Text("\(Int(progress * 100))% Complete")
            .font(Theme.Typography.caption)
            .foregroundColor(Theme.Colors.textSecondary)
    }
    
    private var deckSelector: some View {
        HStack(spacing: 0) {
            ForEach(DeckType.allCases, id: \.self) { deck in
                deckButton(for: deck)
            }
        }
        .padding(4)
        .background(Theme.Colors.card)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card))
        .padding(.horizontal, Theme.Spacing.m)
    }
    
    private func deckButton(for deck: DeckType) -> some View {
        Button { selectedDeck = deck } label: {
            HStack {
                Text(deck.icon)
                Text(deck.title)
                    .font(Theme.Typography.headline)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Theme.Spacing.s)
            .background(
                selectedDeck == deck ?
                Theme.Colors.primary.opacity(0.1) : Color.clear
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Theme.Colors.textSecondary)
            
            TextField("Search words...", text: $searchText)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
            
            if !searchText.isEmpty {
                clearSearchButton
            }
        }
        .padding(Theme.Spacing.m)
        .background(Theme.Colors.card)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.button))
        .padding(.horizontal, Theme.Spacing.m)
        .padding(.vertical, Theme.Spacing.s)
    }
    
    private var clearSearchButton: some View {
        Button { searchText = "" } label: {
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(Theme.Colors.textSecondary)
        }
    }
    
    private var wordList: some View {
        ScrollView {
            LazyVStack(spacing: Theme.Spacing.s) {
                ForEach(filteredWords) { word in
                    WordRow(
                        word: word,
                        isLearned: environment.isLearned(word, deck: selectedDeck),
                        onToggle: { toggleWordStatus(word) }
                    )
                }
            }
            .padding(.horizontal, Theme.Spacing.m)
            .padding(.bottom, Theme.Spacing.xxl)
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Menu {
                Button {
                    withAnimation { showStats.toggle() }
                } label: {
                    Label(showStats ? "Hide Stats" : "Show Stats", systemImage: "chart.bar")
                }
                
                Button(role: .destructive) {
                    showResetAlert = true
                } label: {
                    Label("Reset Progress", systemImage: "arrow.counterclockwise")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
            }
        }
    }
    
    private var resetAlertButtons: some View {
        Group {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                environment.resetProgress(for: selectedDeck)
            }
        }
    }
    
    // MARK: - Private Methods
    private func wordContainsSearch(_ word: Word, searchText: String) -> Bool {
        let lowercaseSearch = searchText.lowercased()
        return word.displayGerman.localizedCaseInsensitiveContains(lowercaseSearch) ||
               word.displayVietnamese.localizedCaseInsensitiveContains(lowercaseSearch) ||
               word.german.alternatives.contains { $0.localizedCaseInsensitiveContains(lowercaseSearch) } ||
               word.vietnamese.alternatives.contains { $0.localizedCaseInsensitiveContains(lowercaseSearch) }
    }
    
    private func toggleWordStatus(_ word: Word) {
        if environment.isLearned(word, deck: selectedDeck) {
            environment.markUnlearned(word, deck: selectedDeck)
        } else {
            environment.markLearned(word, deck: selectedDeck)
        }
    }
}

// MARK: - Supporting Views
struct WordRow: View {
    let word: Word
    let isLearned: Bool
    let onToggle: () -> Void
    @State private var isExpanded = false
    
    var body: some View {
        VStack(spacing: 0) {
            mainContent
            if isExpanded { expandedContent }
        }
        .background(Theme.Colors.card)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card))
        .overlay(learnedBorder)
    }
    
    private var mainContent: some View {
        HStack(spacing: Theme.Spacing.m) {
            toggleButton
            wordContent
            Spacer()
            expandButton
        }
        .padding(Theme.Spacing.m)
    }
    
    private var toggleButton: some View {
        Button(action: onToggle) {
            Image(systemName: isLearned ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 24))
                .foregroundColor(isLearned ? Theme.Colors.success : Theme.Colors.disabled)
        }
    }
    
    private var wordContent: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            Text(word.displayGerman)
                .font(Theme.Typography.headline)
            Text(word.displayVietnamese)
                .font(Theme.Typography.body)
                .foregroundColor(Theme.Colors.textSecondary)
        }
    }
    
    private var expandButton: some View {
        Button { withAnimation { isExpanded.toggle() } } label: {
            Image(systemName: "chevron.down")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Theme.Colors.textSecondary)
                .rotationEffect(.degrees(isExpanded ? 180 : 0))
        }
    }
    
    private var expandedContent: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.s) {
            Divider()
            categoryRow
            if !word.german.alternatives.isEmpty { alternativesRow(language: "Alt German", alternatives: word.german.alternatives) }
            if !word.vietnamese.alternatives.isEmpty { alternativesRow(language: "Alt Vietnamese", alternatives: word.vietnamese.alternatives) }
            if let sentence = word.exampleSentence { exampleSentenceView(sentence) }
        }
        .padding(Theme.Spacing.m)
    }
    
    private var categoryRow: some View {
        HStack {
            Label("Category", systemImage: "folder")
                .font(Theme.Typography.caption)
            Spacer()
            Text(word.category.title)
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textSecondary)
        }
    }
    
    private func alternativesRow(language: String, alternatives: [String]) -> some View {
        HStack(alignment: .top) {
            Label(language, systemImage: "text.bubble")
                .font(Theme.Typography.caption)
            Spacer()
            Text(alternatives.joined(separator: ", "))
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textSecondary)
                .multilineTextAlignment(.trailing)
        }
    }
    
    private func exampleSentenceView(_ sentence: ExampleSentence) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            Label("Example", systemImage: "text.quote")
                .font(Theme.Typography.caption)
            
            sentenceRow(flag: "🇩🇪", text: sentence.german)
            sentenceRow(flag: "🇻🇳", text: sentence.vietnamese)
        }
    }
    
    private func sentenceRow(flag: String, text: String) -> some View {
        HStack(alignment: .top) {
            Text(flag)
            Text(text)
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    private var learnedBorder: some View {
        RoundedRectangle(cornerRadius: Theme.Radius.card)
            .stroke(isLearned ? Theme.Colors.success.opacity(0.3) : Color.clear, lineWidth: 1)
    }
}
