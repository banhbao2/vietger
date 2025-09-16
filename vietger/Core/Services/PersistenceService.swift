import SwiftUI
import Combine

// MARK: - Persistence Service
final class PersistenceService: ObservableObject {
    // UserDefaults keys
    private enum Keys {
        static let learnedIDsCore = "learnedIDs_core"
        static let learnedIDsVyvu = "learnedIDs_vyvu"
        static let userStreak = "userStreak"
        static let totalXP = "totalXP"
        static let lastSessionDate = "lastSessionDate"
        static let longestStreak = "longestStreak"
        static let totalWordsLearned = "totalWordsLearned"
        static let settings = "settings"
    }
    
    @AppStorage(Keys.learnedIDsCore) private var learnedIDsCoreData: Data = .init()
    @AppStorage(Keys.learnedIDsVyvu) private var learnedIDsVyvuData: Data = .init()
    @AppStorage(Keys.userStreak) var userStreak: Int = 0
    @AppStorage(Keys.totalXP) var totalXP: Int = 0
    @AppStorage(Keys.lastSessionDate) private var lastSessionDateString: String = ""
    @AppStorage(Keys.longestStreak) var longestStreak: Int = 0
    @AppStorage(Keys.totalWordsLearned) var totalWordsLearned: Int = 0
    
    // Settings
    @Published var settings: Settings
    
    init() {
        if let data = UserDefaults.standard.data(forKey: Keys.settings),
           let decoded = try? JSONDecoder().decode(Settings.self, from: data) {
            self.settings = decoded
        } else {
            self.settings = Settings()
        }
    }
    
    // MARK: - Learned IDs Management
    func loadLearnedIDs(for deck: DeckType) -> Set<String> {
        let data = deck == .core ? learnedIDsCoreData : learnedIDsVyvuData
        return Self.decodeSet(from: data)
    }
    
    func saveLearnedIDs(_ ids: Set<String>, for deck: DeckType) {
        let data = Self.encodeSet(ids)
        if deck == .core {
            learnedIDsCoreData = data
        } else {
            learnedIDsVyvuData = data
        }
    }
    
    // MARK: - Session Management
    func updateLastSessionDate() {
        lastSessionDateString = ISO8601DateFormatter().string(from: Date())
    }
    
    func getLastSessionDate() -> Date? {
        guard !lastSessionDateString.isEmpty else { return nil }
        return ISO8601DateFormatter().date(from: lastSessionDateString)
    }
    
    // MARK: - Settings
    func saveSettings() {
        if let encoded = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(encoded, forKey: Keys.settings)
        }
    }
    
    // MARK: - Helpers
    private static func encodeSet(_ set: Set<String>) -> Data {
        (try? JSONEncoder().encode(Array(set))) ?? Data()
    }
    
    private static func decodeSet(from data: Data) -> Set<String> {
        (try? JSONDecoder().decode([String].self, from: data)).map(Set.init) ?? []
    }
}

// MARK: - Settings Model
struct Settings: Codable {
    var ttsRate: Float = 0.45
    var dailyGoal: Int = 10
    var enableNotifications: Bool = true
    var enableHaptics: Bool = true
    var preferredDeck: DeckType = .core
    var preferredDirection: QuizDirection = .deToVi
}

// MARK: - Deck Type
enum DeckType: String, CaseIterable, Codable {
    case core = "core"
    case vyvu = "vyvu"
    
    var title: String {
        switch self {
        case .core: return "Common Words"
        case .vyvu: return "Vyvu Study"
        }
    }
    
    var icon: String {
        switch self {
        case .core: return "📚"
                case .vyvu: return "🎓"
                }
            }
        }
