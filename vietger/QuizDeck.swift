import Foundation

enum QuizDeck: String, CaseIterable, Identifiable {
    case core = "Most common daily words"
    case vyvu = "Studying for Vyvu"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .core: return "🗒️ Most common daily words"
        case .vyvu: return "📘 Studying for Vyvu"
        }
    }
}
