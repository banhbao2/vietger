import SwiftUI
import Combine

@MainActor
final class AppState: ObservableObject {
    // Data
    @Published private(set) var coreWords: [Word] = []
    @Published private(set) var vyvuWords: [Word] = []
    
    // Progress
    @Published private(set) var learnedIDsCore: Set<String> = []
    @Published private(set) var learnedIDsVyvu: Set<String> = []
    
    // Services
    private let dataService = DataService()
    private let persistence = PersistenceService()
    
    // Computed properties (cached)
    var unlearnedCore: [Word] {
        coreWords.filter { !learnedIDsCore.contains($0.id) }
    }
    
    var unlearnedVyvu: [Word] {
        vyvuWords.filter { !learnedIDsVyvu.contains($0.id) }
    }
    
    var statistics: AppStatistics {
        AppStatistics(
            totalWords: coreWords.count + vyvuWords.count,
            learnedWords: learnedIDsCore.count + learnedIDsVyvu.count,
            currentStreak: persistence.userStreak,
            longestStreak: persistence.longestStreak,
            totalXP: persistence.totalXP,
            coreProgress: coreWords.isEmpty ? 0 : Double(learnedIDsCore.count) / Double(coreWords.count),
            vyvuProgress: vyvuWords.isEmpty ? 0 : Double(learnedIDsVyvu.count) / Double(vyvuWords.count)
        )
    }
    
    init() {
        loadData()
        loadProgress()
    }
    
    private func loadData() {
        let data = dataService.preloadAllData()
        coreWords = data.core
        vyvuWords = data.vyvu
    }
    
    private func loadProgress() {
        learnedIDsCore = persistence.loadLearnedIDs(for: .core)
        learnedIDsVyvu = persistence.loadLearnedIDs(for: .vyvu)
    }
    
    // MARK: - Public API
    func isLearned(_ word: Word, deck: DeckType) -> Bool {
        let learnedSet = deck == .core ? learnedIDsCore : learnedIDsVyvu
        return learnedSet.contains(word.id)
    }
    
    func markLearned(_ word: Word, deck: DeckType) {
        if deck == .core {
            learnedIDsCore.insert(word.id)
            persistence.saveLearnedIDs(learnedIDsCore, for: .core)
        } else {
            learnedIDsVyvu.insert(word.id)
            persistence.saveLearnedIDs(learnedIDsVyvu, for: .vyvu)
        }
        persistence.totalWordsLearned = learnedIDsCore.count + learnedIDsVyvu.count
    }
    
    func markUnlearned(_ word: Word, deck: DeckType) {
        if deck == .core {
            learnedIDsCore.remove(word.id)
            persistence.saveLearnedIDs(learnedIDsCore, for: .core)
        } else {
            learnedIDsVyvu.remove(word.id)
            persistence.saveLearnedIDs(learnedIDsVyvu, for: .vyvu)
        }
        persistence.totalWordsLearned = learnedIDsCore.count + learnedIDsVyvu.count
    }
    
    func resetProgress(for deck: DeckType) {
        if deck == .core {
            learnedIDsCore.removeAll()
            persistence.saveLearnedIDs(learnedIDsCore, for: .core)
        } else {
            learnedIDsVyvu.removeAll()
            persistence.saveLearnedIDs(learnedIDsVyvu, for: .vyvu)
        }
        persistence.totalWordsLearned = learnedIDsCore.count + learnedIDsVyvu.count
    }
    
    func words(for deck: DeckType) -> [Word] {
        deck == .core ? coreWords : vyvuWords
    }
    
    func unlearnedWords(for deck: DeckType) -> [Word] {
        deck == .core ? unlearnedCore : unlearnedVyvu
    }
}
