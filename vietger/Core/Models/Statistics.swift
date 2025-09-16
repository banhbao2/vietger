import Foundation

struct AppStatistics {
    let totalWords: Int
    let learnedWords: Int
    let currentStreak: Int
    let longestStreak: Int
    let totalXP: Int
    let coreProgress: Double
    let vyvuProgress: Double
    
    var unlearnedWords: Int { totalWords - learnedWords }
    var overallProgress: Double {
        guard totalWords > 0 else { return 0 }
        return Double(learnedWords) / Double(totalWords)
    }
}

struct SessionStatistics {
    let totalWords: Int
    let correctWords: Int
    let timeSpent: TimeInterval
    let xpEarned: Int
    
    var incorrectWords: Int { totalWords - correctWords }
    var accuracy: Double {
        guard totalWords > 0 else { return 0 }
        return Double(correctWords) / Double(totalWords)
    }
}
