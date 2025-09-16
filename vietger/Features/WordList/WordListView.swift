import SwiftUI

struct WordListView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = WordListViewModel()
    
    var body: some View {
        ZStack {
            Theme.Colors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                if viewModel.showStats {
                    WordListStatsHeader(viewModel: viewModel)
                        .padding(Theme.Spacing.m)
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
                            viewModel.showStats.toggle()
                        }
                    } label: {
                        Label(viewModel.showStats ? "Hide Stats" : "Show Stats",
                              systemImage: "chart.bar")
                    }
                    
                    Button(role: .destructive) {
                        viewModel.showResetAlert = true
                    } label: {
                        Label("Reset Progress", systemImage: "arrow.counterclockwise")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .alert("Reset Progress?", isPresented: $viewModel.showResetAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                viewModel.resetProgress()
            }
        } message: {
            Text("This will mark all words as not learned.")
        }
        .onAppear {
            viewModel.configure(appState: appState)
            viewModel.loadWords()
        }
    }
    
    private var deckSelector: some View {
        HStack(spacing: 0) {
            ForEach(DeckType.allCases, id: \.self) { deck in
                Button {
                    viewModel.selectedDeck = deck
                } label: {
                    HStack {
                        Text(deck.icon)
                        Text(deck.title)
                            .font(Theme.Typography.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Theme.Spacing.s)
                    .background(
                        viewModel.selectedDeck == deck ?
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
            
            TextField("Search words...", text: $viewModel.searchText)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
            
            if !viewModel.searchText.isEmpty {
                Button {
                    viewModel.searchText = ""
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
                ForEach(viewModel.filteredWords) { word in
                    WordRow(
                        word: word,
                        isLearned: viewModel.isLearned(word),
                        onToggle: {
                            viewModel.toggleWordStatus(word)
                        }
                    )
                }
            }
            .padding(.horizontal, Theme.Spacing.m)
            .padding(.bottom, Theme.Spacing.xxl)
        }
    }
}

struct WordListStatsHeader: View {
    @ObservedObject var viewModel: WordListViewModel
    
    var body: some View {
        VStack(spacing: Theme.Spacing.m) {
            HStack(spacing: Theme.Spacing.m) {
                StatCard(
                    icon: "books.vertical",
                    value: "\(viewModel.totalWords)",
                    label: "Total",
                    color: Theme.Colors.primary
                )
                
                StatCard(
                    icon: "checkmark.seal",
                    value: "\(viewModel.learnedCount)",
                    label: "Learned",
                    color: Theme.Colors.success
                )
                
                StatCard(
                    icon: "book.closed",
                    value: "\(viewModel.totalWords - viewModel.learnedCount)",
                    label: "To Learn",
                    color: Theme.Colors.warning
                )
            }
            
            LinearProgress(progress: viewModel.progress)
                .frame(height: 6)
            
            Text("\(Int(viewModel.progress * 100))% Complete")
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textSecondary)
        }
        .padding(Theme.Spacing.m)
        .background(Theme.Colors.card)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card))
    }
}
