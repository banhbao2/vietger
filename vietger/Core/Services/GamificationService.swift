import SwiftUI

final class GamificationService: ObservableObject {
    private let persistence: PersistenceService
    
    @Published var currentStreak: Int = 0
    @Published var totalXP: Int = 0
    @Published var longestStreak: Int = 0
    
    init(persistence: PersistenceService) {
        self.persistence = persistence
        loadStats()
    }
    
    func loadStats() {
        currentStreak = persistence.userStreak
        totalXP = persistence.totalXP
        longestStreak = persistence.longestStreak
    }
    
    func awardXP(_ points: Int) {
        totalXP += points
        persistence.totalXP = totalXP
    }
    
    func completeSession(correctWords: Int, totalWords: Int) -> SessionRewards {
        let baseXP = correctWords * 10
        let bonusXP = calculateBonus(correctWords: correctWords, totalWords: totalWords)
        let totalXP = baseXP + bonusXP
        
        awardXP(totalXP)
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
        if accuracy == 1.0 && totalWords >= 5 {
            bonus += 50 // Perfect session
        }
        if totalWords >= 20 {
            bonus += 30 // Long session
        }
        if currentStreak >= 7 {
            bonus += 20 // Week streak
        }
        return bonus
    }
    
    private func updateStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        if let lastDate = persistence.getLastSessionDate() {
            let lastDay = calendar.startOfDay(for: lastDate)
            let daysDiff = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0
            
            if daysDiff == 0 {
                return // Already completed today
            } else if daysDiff == 1 {
                currentStreak += 1
                persistence.userStreak = currentStreak
                if currentStreak > longestStreak {
                    longestStreak = currentStreak
                    persistence.longestStreak = longestStreak
                }
            } else {
                currentStreak = 1
                persistence.userStreak = 1
            }
        } else {
            currentStreak = 1
            persistence.userStreak = 1
        }
        
        persistence.updateLastSessionDate()
    }
}

struct SessionRewards {
    let baseXP: Int
    let bonusXP: Int
    let totalXP: Int
    let newStreak: Int
}
