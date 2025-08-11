import Foundation

enum QuizDirection: String, CaseIterable, Identifiable {
    case deToVi = "German → Vietnamese"
    case viToDe = "Vietnamese → German"

    var id: String { rawValue }

    // UI label with flags (so views don’t hardcode)
    var title: String {
        switch self {
        case .deToVi: return "🇩🇪 German → 🇻🇳 Vietnamese"
        case .viToDe: return "🇻🇳 Vietnamese → 🇩🇪 German"
        }
    }
}
