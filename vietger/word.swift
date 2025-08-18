import Foundation

// MARK: - Category

enum Category: String, CaseIterable, Hashable, Codable {
    case pronouns
    case coreVerbs
    case nouns
    case commonThings
    case adjectives
    case questionWords
    case timeFrequency
    case prepositions
    case connectors
    case adverbsFillers
    case interjectionsExpressions
    case other

    var title: String {
        switch self {
        case .pronouns: return "Pronouns & Personal Words"
        case .coreVerbs: return "Core Verbs"
        case .nouns: return "Nouns (People, Time, Places)"
        case .commonThings: return "Common Things"
        case .adjectives: return "Adjectives"
        case .questionWords: return "Question Words"
        case .timeFrequency: return "Time & Frequency"
        case .prepositions: return "Prepositions"
        case .connectors: return "Connectors"
        case .adverbsFillers: return "Common Adverbs & Fillers"
        case .interjectionsExpressions: return "Basic Interjections & Expressions"
        case .other: return "Other"
        }
    }

    /// Preferred section order for UI (if you ever need to display grouped lists)
    static let ordered: [Category] = [
        .pronouns, .coreVerbs, .nouns, .commonThings,
        .adjectives, .questionWords, .timeFrequency,
        .prepositions, .connectors, .adverbsFillers,
        .interjectionsExpressions, .other
    ]
}

// MARK: - Model

/// Supports multiple acceptable answers both ways.
/// Includes `category` so views don’t need to guess it.
struct Word: Identifiable, Hashable, Codable {
    let german: String
    let germanAlt: [String]
    let vietnamese: String
    let vietnameseAlt: [String]
    let category: Category

    /// Stable ID based on canonical forms (unchanged -> progress safe)
    var id: String { "\(german)↔\(vietnamese)" }

    /// Convenience for quiz matching
    var allGerman: [String] { [german] + germanAlt }
    var allVietnamese: [String] { [vietnamese] + vietnameseAlt }
}
