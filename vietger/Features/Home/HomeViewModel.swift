import SwiftUI

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var learnedWords: Int = 0
    @Published var unlearnedWords: Int = 0
    @Published var streak: Int = 0
    @Published var totalXP: Int = 0
    @Published var dailyTip: String = ""
    
    private let tips = [
        "Practice 5 minutes daily to maintain your streak!",
        "Review difficult words before bed for better retention.",
        "Use spaced repetition for long-term memory.",
        "Try speaking words out loud to improve pronunciation.",
        "Focus on one category at a time for better results."
    ]
    
    func loadStats(from appState: AppState) {
        let stats = appState.statistics
        learnedWords = stats.learnedWords
        unlearnedWords = stats.unlearnedWords
        streak = stats.currentStreak
        totalXP = stats.totalXP
        dailyTip = tips.randomElement() ?? tips[0]
    }
}
