import Foundation

enum QuizDirection: String, CaseIterable, Identifiable {
    case deToVi      = "German → Vietnamese"
    case viToDe      = "Vietnamese → German"
    case vyvuStudy   = "Studying for Vyvu"     // used to pick the Vyvu deck

    var id: String { rawValue }

    var title: String {
        switch self {
        case .deToVi:     return "🇩🇪 German → 🇻🇳 Vietnamese"
        case .viToDe:     return "🇻🇳 Vietnamese → 🇩🇪 German"
        case .vyvuStudy:  return "📘 Studying for Vyvu"
        }
    }

    /// Orientation used by the quiz UI / TTS.
    /// Treat Vyvu mode as German→Vietnamese (you answer in Vietnamese).
    var isGermanToVietnamese: Bool {
        switch self {
        case .deToVi, .vyvuStudy: return true
        case .viToDe:             return false
        }
    }
}
