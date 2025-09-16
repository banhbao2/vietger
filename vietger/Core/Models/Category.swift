import Foundation

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
    case shapes
    case colors
    case materials
    case verbs
    case adverbs

    var title: String {
        switch self {
        case .pronouns: return "Pronouns"
        case .coreVerbs: return "Core Verbs"
        case .nouns: return "Nouns"
        case .commonThings: return "Common Things"
        case .adjectives: return "Adjectives"
        case .questionWords: return "Question Words"
        case .timeFrequency: return "Time & Frequency"
        case .prepositions: return "Prepositions"
        case .connectors: return "Connectors"
        case .adverbsFillers: return "Adverbs & Fillers"
        case .interjectionsExpressions: return "Interjections"
        case .other: return "Other"
        case .shapes: return "Shapes"
        case .colors: return "Colors"
        case .materials: return "Materials"
        case .verbs: return "Verbs"
        case .adverbs: return "Adverbs"
        }
    }
}
