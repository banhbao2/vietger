import SwiftUI
import Combine

@MainActor
final class AppEnvironment: ObservableObject {
    // MARK: - Data
    @Published private(set) var coreWords: [Word] = []
    @Published private(set) var vyvuWords: [Word] = []
    @Published private(set) var learnedIDsCore: Set<String> = []
    @Published private(set) var learnedIDsVyvu: Set<String> = []
    
    // MARK: - Services
    let dataManager: DataManager
    let speechService: SpeechService
    let gamificationService: GamificationService
    
    // MARK: - Computed Properties
    var statistics: AppStatistics {
        AppStatistics(
            totalWords: coreWords.count + vyvuWords.count,
            learnedWords: learnedIDsCore.count + learnedIDsVyvu.count,
            currentStreak: dataManager.userStreak,
            longestStreak: dataManager.longestStreak,
            totalXP: dataManager.totalXP,
            coreProgress: calculateProgress(learned: learnedIDsCore, total: coreWords),
            vyvuProgress: calculateProgress(learned: learnedIDsVyvu, total: vyvuWords)
        )
    }
    
    init() {
        self.dataManager = DataManager()
        self.speechService = DefaultSpeechService()
        self.gamificationService = GamificationService(dataManager: dataManager)
        
        Task {
            await loadData()
        }
    }
    
    // MARK: - Data Management
    private func loadData() async {
        let data = await dataManager.preloadAllData()
        coreWords = data.core
        vyvuWords = data.vyvu
        learnedIDsCore = dataManager.loadLearnedIDs(for: .core)
        learnedIDsVyvu = dataManager.loadLearnedIDs(for: .vyvu)
    }
    
    func words(for deck: DeckType) -> [Word] {
        deck == .core ? coreWords : vyvuWords
    }
    
    func unlearnedWords(for deck: DeckType) -> [Word] {
        let allWords = words(for: deck)
        let learnedSet = learnedIDs(for: deck)
        return allWords.filter { !learnedSet.contains($0.id) }
    }
    
    func isLearned(_ word: Word, deck: DeckType) -> Bool {
        learnedIDs(for: deck).contains(word.id)
    }
    
    func markLearned(_ word: Word, deck: DeckType) {
        updateLearnedStatus(word: word, deck: deck, isLearned: true)
    }
    
    func markUnlearned(_ word: Word, deck: DeckType) {
        updateLearnedStatus(word: word, deck: deck, isLearned: false)
    }
    
    func resetProgress(for deck: DeckType) {
        if deck == .core {
            learnedIDsCore.removeAll()
        } else {
            learnedIDsVyvu.removeAll()
        }
        dataManager.saveLearnedIDs([], for: deck)
        updateTotalWordsLearned()
    }
    
    // MARK: - Private Helpers
    private func learnedIDs(for deck: DeckType) -> Set<String> {
        deck == .core ? learnedIDsCore : learnedIDsVyvu
    }
    
    private func updateLearnedStatus(word: Word, deck: DeckType, isLearned: Bool) {
        if deck == .core {
            if isLearned {
                learnedIDsCore.insert(word.id)
            } else {
                learnedIDsCore.remove(word.id)
            }
            dataManager.saveLearnedIDs(learnedIDsCore, for: deck)
        } else {
            if isLearned {
                learnedIDsVyvu.insert(word.id)
            } else {
                learnedIDsVyvu.remove(word.id)
            }
            dataManager.saveLearnedIDs(learnedIDsVyvu, for: deck)
        }
        updateTotalWordsLearned()
    }
    
    private func updateTotalWordsLearned() {
        dataManager.totalWordsLearned = learnedIDsCore.count + learnedIDsVyvu.count
    }
    
    private func calculateProgress(learned: Set<String>, total: [Word]) -> Double {
        total.isEmpty ? 0 : Double(learned.count) / Double(total.count)
    }
}
