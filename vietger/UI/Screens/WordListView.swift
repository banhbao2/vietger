import SwiftUI

struct WordListView: View {
    @EnvironmentObject var environment: AppEnvironment
    @State private var selectedDeck: DeckType = .core
    @State private var searchText = ""
    @State private var showStats = true
    @State private var showResetAlert = false
    
    private var words: [Word] {
        environment.words(for: selectedDeck)
    }
    
    private var filteredWords: [Word] {
        guard !searchText.isEmpty else { return words }
        return words.filter { word in
            word.displayGerman.localizedCaseInsensitiveContains(searchText) ||
            word.displayVietnamese.localizedCaseInsensitiveContains(searchText) ||
            word.german.alternatives.contains { $0.localizedCaseInsensitiveContains(searchText) } ||
            word.vietnamese.alternatives.contains { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    private var learnedCount: Int {
        words.filter { environment.isLearned($0, deck: selectedDeck) }.count
    }
    
    private var progress: Double {
        guard !words.isEmpty else { return 0 }
        return Double(learnedCount) / Double(words.count)
    }
    
    var body: some View {
        ZStack {
            Theme.Colors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                if showStats {
                    statsHeader
                }
                
                deckSelector
                searchBar
                wordList
            }
        }
        .navigationTitle("Vocabulary")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        withAnimation {
                            showStats.toggle()
                        }
                    } label: {
                        Label(showStats ? "Hide Stats" : "Show Stats",
                              systemImage: "chart.bar")
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
        .alert("Reset Progress?", isPresented: $showResetAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                environment.resetProgress(for: selectedDeck)
            }
        } message: {
            Text("This will mark all words as not learned.")
        }
    }
    
    private var statsHeader: some View {
        VStack(spacing: Theme.Spacing.m) {
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
            
            LinearProgress(progress: progress)
            
            Text("\(Int(progress * 100))% Complete")
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textSecondary)
        }
        .padding(Theme.Spacing.m)
        .background(Theme.Colors.card)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card))
        .padding(Theme.Spacing.m)
    }
    
    private var deckSelector: some View {
        HStack(spacing: 0) {
            ForEach(DeckType.allCases, id: \.self) { deck in
                Button {
                    selectedDeck = deck
                } label: {
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
        }
        .padding(4)
        .background(Theme.Colors.card)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card))
        .padding(.horizontal, Theme.Spacing.m)
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Theme.Colors.textSecondary)
            
            TextField("Search words...", text: $searchText)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
            
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Theme.Colors.textSecondary)
                }
            }
        }
        .padding(Theme.Spacing.m)
        .background(Theme.Colors.card)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.button))
        .padding(.horizontal, Theme.Spacing.m)
        .padding(.vertical, Theme.Spacing.s)
    }
    
    private var wordList: some View {
        ScrollView {
            LazyVStack(spacing: Theme.Spacing.s) {
                ForEach(filteredWords) { word in
                    WordRow(
                        word: word,
                        isLearned: environment.isLearned(word, deck: selectedDeck),
                        onToggle: {
                            if environment.isLearned(word, deck: selectedDeck) {
                                environment.markUnlearned(word, deck: selectedDeck)
                            } else {
                                environment.markLearned(word, deck: selectedDeck)
                            }
                        }
                    )
                }
            }
            .padding(.horizontal, Theme.Spacing.m)
            .padding(.bottom, Theme.Spacing.xxl)
        }
    }
}

struct WordRow: View {
    let word: Word
    let isLearned: Bool
    let onToggle: () -> Void
    @State private var isExpanded = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: Theme.Spacing.m) {
                Button(action: onToggle) {
                    Image(systemName: isLearned ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 24))
                        .foregroundColor(isLearned ? Theme.Colors.success : Theme.Colors.disabled)
                }
                
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    Text(word.displayGerman)
                        .font(Theme.Typography.headline)
                    Text(word.displayVietnamese)
                        .font(Theme.Typography.body)
                        .foregroundColor(Theme.Colors.textSecondary)
                }
                
                Spacer()
                
                Button {
                    withAnimation {
                        isExpanded.toggle()
                    }
                } label: {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Theme.Colors.textSecondary)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
            }
            .padding(Theme.Spacing.m)
            
            if isExpanded {
                VStack(alignment: .leading, spacing: Theme.Spacing.s) {
                    Divider()
                    
                    HStack {
                        Label("Category", systemImage: "folder")
                            .font(Theme.Typography.caption)
                        Spacer()
                        Text(word.category.title)
                            .font(Theme.Typography.caption)
                            .foregroundColor(Theme.Colors.textSecondary)
                    }
                    
                    if !word.german.alternatives.isEmpty {
                        HStack(alignment: .top) {
                            Label("Alt German", systemImage: "text.bubble")
                                .font(Theme.Typography.caption)
                            Spacer()
                            Text(word.german.alternatives.joined(separator: ", "))
                                .font(Theme.Typography.caption)
                                .foregroundColor(Theme.Colors.textSecondary)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                    
                    if !word.vietnamese.alternatives.isEmpty {
                        HStack(alignment: .top) {
                            Label("Alt Vietnamese", systemImage: "text.bubble")
                                .font(Theme.Typography.caption)
                            Spacer()
                            Text(word.vietnamese.alternatives.joined(separator: ", "))
                                .font(Theme.Typography.caption)
                                .foregroundColor(Theme.Colors.textSecondary)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                    
                    if let sentence = word.exampleSentence {
                        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                            Label("Example", systemImage: "text.quote")
                                .font(Theme.Typography.caption)
                            
                            HStack(alignment: .top) {
                                Text("🇩🇪")
                                Text(sentence.german)
                                    .font(Theme.Typography.caption)
                                    .foregroundColor(Theme.Colors.textSecondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            
                            HStack(alignment: .top) {
                                Text("🇻🇳")
                                Text(sentence.vietnamese)
                                    .font(Theme.Typography.caption)
                                    .foregroundColor(Theme.Colors.textSecondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                }
                .padding(Theme.Spacing.m)
            }
        }
        .background(Theme.Colors.card)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.card)
                .stroke(isLearned ? Theme.Colors.success.opacity(0.3) : Color.clear, lineWidth: 1)
        )
    }
}
