import Foundation

enum QuizDirection: String, CaseIterable, Identifiable, Codable {
    case deToVi = "German → Vietnamese"
    case viToDe = "Vietnamese → German"

    var id: String { rawValue }
    var isGermanToVietnamese: Bool { self == .deToVi }
    
    var sourceFlag: String { isGermanToVietnamese ? "🇩🇪" : "🇻🇳" }
    var targetFlag: String { isGermanToVietnamese ? "🇻🇳" : "🇩🇪" }
}

enum QuizStage {
    case setup
    case inQuiz
    case summary
}

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
    
    var current: Word? {
        words.indices.contains(currentIndex) ? words[currentIndex] : nil
    }
    
    var progress: Double {
        words.isEmpty ? 0 : Double(currentIndex) / Double(words.count)
    }
    
    var accuracy: Double {
        seenIDs.isEmpty ? 0 : Double(correctIDs.count) / Double(seenIDs.count)
    }
}
