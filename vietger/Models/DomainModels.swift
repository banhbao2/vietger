import Foundation

// MARK: - Core Models
struct Word: Identifiable, Hashable, Codable {
    let id: String
    let german: Translation
    let vietnamese: Translation
    let category: Category
    let exampleSentence: ExampleSentence?
    
    // Computed properties for compatibility
    var allGerman: [String] { [german.main] + german.alternatives }
    var allVietnamese: [String] { [vietnamese.main] + vietnamese.alternatives }
    var displayGerman: String { german.main }
    var displayVietnamese: String { vietnamese.main }
}

struct Translation: Codable, Hashable {
    let main: String
    let alternatives: [String]
}

struct ExampleSentence: Codable, Hashable {
    let german: String
    let vietnamese: String
}

// MARK: - Enums
enum Category: String, CaseIterable, Hashable, Codable {
    case pronouns, coreVerbs, nouns, commonThings, adjectives
    case questionWords, timeFrequency, prepositions, connectors
    case adverbsFillers, interjectionsExpressions, other
    case shapes, colors, materials, verbs, adverbs, phrases
    
    var title: String {
        switch self {
        case .pronouns: return "Pronomen"
        case .coreVerbs: return "Grundlegende Verben"
        case .nouns: return "Substantive"
        case .commonThings: return "Alltägliche Dinge"
        case .adjectives: return "Adjektive"
        case .questionWords: return "Fragewörter"
        case .timeFrequency: return "Zeit & Häufigkeit"
        case .prepositions: return "Präpositionen"
        case .connectors: return "Konnektoren"
        case .adverbsFillers: return "Adverbien & Füllwörter"
        case .interjectionsExpressions: return "Interjektionen"
        case .other: return "Sonstiges"
        case .shapes: return "Formen"
        case .colors: return "Farben"
        case .materials: return "Materialien"
        case .verbs: return "Verben"
        case .adverbs: return "Adverbien"
        case .phrases: return "Redewendungen"
        }
    }
}

enum DeckType: String, CaseIterable, Codable {
    case core, vyvu
    
    var title: String { self == .core ? "Common Words" : "Vyvu Study" }
    var icon: String { self == .core ? "📚" : "🎓" }
}

enum QuizDirection: String, CaseIterable, Identifiable, Codable {
    case deToVi = "German → Vietnamese"
    case viToDe = "Vietnamese → German"
    
    var id: String { rawValue }
    var isGermanToVietnamese: Bool { self == .deToVi }
    var sourceFlag: String { isGermanToVietnamese ? "🇩🇪" : "🇻🇳" }
    var targetFlag: String { isGermanToVietnamese ? "🇻🇳" : "🇩🇪" }
}

enum QuizStage: CaseIterable {
    case setup, inQuiz, summary
}

enum SpeechLanguage {
    case german, vietnamese

    var bcp47: String { self == .german ? "de-DE" : "vi-VN" }
    var fallbackBCP47: String { bcp47 }
    var label: String { self == .german ? "DE" : "VI" }
}

// MARK: - Quiz Models
struct QuizConfiguration {
    let deck: DeckType
    let direction: QuizDirection
    let size: Int
    let useAllWords: Bool
}

struct QuizSession {
    let configuration: QuizConfiguration
    let words: [Word]
    var currentIndex: Int = 0
    var correctIDs: Set<String> = []
    var seenIDs: Set<String> = []
    
    var current: Word? { words.indices.contains(currentIndex) ? words[currentIndex] : nil }
    var progress: Double { words.isEmpty ? 0 : Double(currentIndex) / Double(words.count) }
    var accuracy: Double { seenIDs.isEmpty ? 0 : Double(correctIDs.count) / Double(seenIDs.count) }
}

// MARK: - Statistics
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
        totalWords > 0 ? Double(learnedWords) / Double(totalWords) : 0
    }
}

struct SessionStatistics {
    let totalWords: Int
    let correctWords: Int
    let timeSpent: TimeInterval
    let xpEarned: Int
    
    var incorrectWords: Int { totalWords - correctWords }
    var accuracy: Double { totalWords > 0 ? Double(correctWords) / Double(totalWords) : 0 }
}

struct SessionRewards {
    let baseXP: Int
    let bonusXP: Int
    let totalXP: Int
    let newStreak: Int
}

// MARK: - Settings
struct Settings: Codable {
    var ttsRate: Float = 0.45
    var dailyGoal: Int = 10
    var enableNotifications: Bool = true
    var enableHaptics: Bool = true
    var preferredDeck: DeckType = .core
    var preferredDirection: QuizDirection = .deToVi
}
