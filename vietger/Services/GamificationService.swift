import SwiftUI

final class GamificationService: ObservableObject {
    private let dataManager: DataManager
    
    @Published var currentStreak: Int = 0
    @Published var totalXP: Int = 0
    @Published var longestStreak: Int = 0
    
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
        let baseXP = correctWords * 10
        let bonusXP = calculateBonus(correctWords: correctWords, totalWords: totalWords)
        let totalXP = baseXP + bonusXP
        
        self.totalXP += totalXP
        dataManager.totalXP = self.totalXP
        updateStreak()
        
        return SessionRewards(
            baseXP: baseXP,
            bonusXP: bonusXP,
            totalXP: totalXP,
            newStreak: currentStreak
        )
    }
    
    private func calculateBonus(correctWords: Int, totalWords: Int) -> Int {
        guard totalWords > 0 else { return 0 }
        let accuracy = Double(correctWords) / Double(totalWords)
        
        var bonus = 0
        if accuracy == 1.0 && totalWords >= 5 { bonus += 50 }
        if totalWords >= 20 { bonus += 30 }
        if currentStreak >= 7 { bonus += 20 }
        return bonus
    }
    
    private func updateStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        if let lastDate = dataManager.getLastSessionDate() {
            let lastDay = calendar.startOfDay(for: lastDate)
            let daysDiff = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0
            
            if daysDiff == 0 {
                return
            } else if daysDiff == 1 {
                currentStreak += 1
                if currentStreak > longestStreak {
                    longestStreak = currentStreak
                    dataManager.longestStreak = longestStreak
                }
            } else {
                currentStreak = 1
            }
        } else {
            currentStreak = 1
        }
        
        dataManager.userStreak = currentStreak
        dataManager.updateLastSessionDate()
    }
}
