import Foundation

enum QuizDirection: String, CaseIterable, Identifiable {
    case deToVi = "German → Vietnamese"
    case viToDe = "Vietnamese → German"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .deToVi: return "🇩🇪 German → 🇻🇳 Vietnamese"
        case .viToDe: return "🇻🇳 Vietnamese → 🇩🇪 German"
        }
    }

    var isGermanToVietnamese: Bool {
        switch self {
        case .deToVi: return true
        case .viToDe: return false
        }
    }
}
