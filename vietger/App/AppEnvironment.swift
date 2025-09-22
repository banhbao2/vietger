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
            coreProgress: coreWords.isEmpty ? 0 : Double(learnedIDsCore.count) / Double(coreWords.count),
            vyvuProgress: vyvuWords.isEmpty ? 0 : Double(learnedIDsVyvu.count) / Double(vyvuWords.count)
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
    @MainActor
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
        let words = self.words(for: deck)
        let learnedSet = deck == .core ? learnedIDsCore : learnedIDsVyvu
        return words.filter { !learnedSet.contains($0.id) }
    }
    
    func isLearned(_ word: Word, deck: DeckType) -> Bool {
        let learnedSet = deck == .core ? learnedIDsCore : learnedIDsVyvu
        return learnedSet.contains(word.id)
    }
    
    func markLearned(_ word: Word, deck: DeckType) {
        if deck == .core {
            learnedIDsCore.insert(word.id)
        } else {
            learnedIDsVyvu.insert(word.id)
        }
        dataManager.saveLearnedIDs(deck == .core ? learnedIDsCore : learnedIDsVyvu, for: deck)
        dataManager.totalWordsLearned = learnedIDsCore.count + learnedIDsVyvu.count
    }
    
    func markUnlearned(_ word: Word, deck: DeckType) {
        if deck == .core {
            learnedIDsCore.remove(word.id)
        } else {
            learnedIDsVyvu.remove(word.id)
        }
        dataManager.saveLearnedIDs(deck == .core ? learnedIDsCore : learnedIDsVyvu, for: deck)
        dataManager.totalWordsLearned = learnedIDsCore.count + learnedIDsVyvu.count
    }
    
    func resetProgress(for deck: DeckType) {
        if deck == .core {
            learnedIDsCore.removeAll()
        } else {
            learnedIDsVyvu.removeAll()
        }
        dataManager.saveLearnedIDs([], for: deck)
        dataManager.totalWordsLearned = learnedIDsCore.count + learnedIDsVyvu.count
    }
}
