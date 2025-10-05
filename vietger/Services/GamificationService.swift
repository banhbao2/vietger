import SwiftUI

final class GamificationService: ObservableObject {
    private let dataManager: DataManager
    
    @Published var currentStreak: Int = 0
    @Published var totalXP: Int = 0
    @Published var longestStreak: Int = 0
    
    // MARK: - Constants
    private enum XPConstants {
        static let basePointsPerWord = 10
        static let perfectScoreBonus = 50
        static let longSessionBonus = 30
        static let streakBonus = 20
        static let minWordsForPerfectBonus = 5
        static let minWordsForLongSession = 20
        static let minStreakForBonus = 7
    }
    
    init(dataManager: DataManager) {
        self.dataManager = dataManager
        loadStats()
    }
    
    func loadStats() {
        currentStreak = dataManager.userStreak
        totalXP = dataManager.totalXP
        longestStreak = dataManager.longestStreak
    }
    
    func completeSession(correctWords: Int, totalWords: Int) -> SessionRewards {
        let baseXP = correctWords * XPConstants.basePointsPerWord
        let bonusXP = calculateBonus(correctWords: correctWords, totalWords: totalWords)
        let totalSessionXP = baseXP + bonusXP
        
        updateXP(totalSessionXP)
        updateStreak()
        
        return SessionRewards(
            baseXP: baseXP,
            bonusXP: bonusXP,
            totalXP: totalSessionXP,
            newStreak: currentStreak
        )
    }
    
    private func calculateBonus(correctWords: Int, totalWords: Int) -> Int {
        guard totalWords > 0 else { return 0 }
        
        var bonus = 0
        let accuracy = Double(correctWords) / Double(totalWords)
        
        if accuracy == 1.0 && totalWords >= XPConstants.minWordsForPerfectBonus {
            bonus += XPConstants.perfectScoreBonus
        }
        
        if totalWords >= XPConstants.minWordsForLongSession {
            bonus += XPConstants.longSessionBonus
        }
        
        if currentStreak >= XPConstants.minStreakForBonus {
            bonus += XPConstants.streakBonus
        }
        
        return bonus
    }
    
    private func updateXP(_ amount: Int) {
        totalXP += amount
        dataManager.totalXP = totalXP
    }
    
    private func updateStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        guard let lastDate = dataManager.getLastSessionDate() else {
            startNewStreak()
            return
        }
        
        let lastDay = calendar.startOfDay(for: lastDate)
        let daysDiff = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0
        
        switch daysDiff {
        case 0:
            return // Same day, no streak update
        case 1:
            extendStreak()
        default:
            startNewStreak()
        }
        
        dataManager.updateLastSessionDate()
    }
    
    private func startNewStreak() {
        currentStreak = 1
        dataManager.userStreak = currentStreak
    }
    
    private func extendStreak() {
        currentStreak += 1
        dataManager.userStreak = currentStreak
        
        if currentStreak > longestStreak {
            longestStreak = currentStreak
            dataManager.longestStreak = longestStreak
        }
    }
}
