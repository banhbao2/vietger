import SwiftUI
import Combine

@MainActor
final class WordListViewModel: ObservableObject {
    @Published var selectedDeck: DeckType = .core
    @Published var searchText = ""
    @Published var showStats = true
    @Published var showResetAlert = false
    
    @Published private(set) var words: [Word] = []
    @Published private(set) var learnedCount = 0
    @Published private(set) var totalWords = 0
    
    private weak var appState: AppState?
    private var cancellables = Set<AnyCancellable>()
    
    var filteredWords: [Word] {
        guard !searchText.isEmpty else { return words }
        return words.filter { word in
            word.german.localizedCaseInsensitiveContains(searchText) ||
            word.vietnamese.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var progress: Double {
        guard totalWords > 0 else { return 0 }
        return Double(learnedCount) / Double(totalWords)
    }
    
    func configure(appState: AppState) {
        self.appState = appState
        
        $selectedDeck
            .sink { [weak self] _ in
                self?.loadWords()
            }
            .store(in: &cancellables)
    }
    
    func loadWords() {
        guard let appState = appState else { return }
        words = appState.words(for: selectedDeck)
        totalWords = words.count
        updateLearnedCount()
    }
    
    private func updateLearnedCount() {
        guard let appState = appState else { return }
        learnedCount = words.filter { appState.isLearned($0, deck: selectedDeck) }.count
    }
    
    func isLearned(_ word: Word) -> Bool {
        appState?.isLearned(word, deck: selectedDeck) ?? false
    }
    
    func toggleWordStatus(_ word: Word) {
        guard let appState = appState else { return }
        
        if isLearned(word) {
            appState.markUnlearned(word, deck: selectedDeck)
        } else {
            appState.markLearned(word, deck: selectedDeck)
        }
        updateLearnedCount()
    }
    
    func resetProgress() {
        appState?.resetProgress(for: selectedDeck)
        updateLearnedCount()
    }
}
