import SwiftUI
import Combine

final class DataManager: ObservableObject {
    // MARK: - Keys
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
    
    // MARK: - Properties
    @AppStorage(Keys.userStreak) var userStreak: Int = 0
    @AppStorage(Keys.totalXP) var totalXP: Int = 0
    @AppStorage(Keys.longestStreak) var longestStreak: Int = 0
    @AppStorage(Keys.totalWordsLearned) var totalWordsLearned: Int = 0
    @Published var settings: Settings
    
    private let decoder = JSONDecoder()
    
    init() {
        if let data = UserDefaults.standard.data(forKey: Keys.settings),
           let decoded = try? JSONDecoder().decode(Settings.self, from: data) {
            self.settings = decoded
        } else {
            self.settings = Settings()
        }
    }
    
    // MARK: - Data Loading
    func preloadAllData() async -> (core: [Word], vyvu: [Word]) {
        async let core = loadWords(for: .core)
        async let vyvu = loadWords(for: .vyvu)
        return await (core, vyvu)
    }
    
    private func loadWords(for deck: DeckType) async -> [Word] {
        // Use the correct file names
        let resource = deck == .core ? "words_sentences" : "vyvu_words_sentences"
        guard let url = Bundle.main.url(forResource: resource, withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("⚠️ Failed to load \(resource).json")
            return []
        }
        
        // Parse the new JSON structure
        do {
            let file = try decoder.decode(WordsDataFile.self, from: data)
            print("✅ Loaded \(file.entries.count) words from \(resource).json")
            return file.entries
        } catch {
            print("⚠️ Failed to decode \(resource).json: \(error)")
            return []
        }
    }
    
    // MARK: - Persistence
    func loadLearnedIDs(for deck: DeckType) -> Set<String> {
        let key = deck == .core ? Keys.learnedIDsCore : Keys.learnedIDsVyvu
        guard let data = UserDefaults.standard.data(forKey: key),
              let ids = try? JSONDecoder().decode([String].self, from: data) else {
            return []
        }
        return Set(ids)
    }
    
    func saveLearnedIDs(_ ids: Set<String>, for deck: DeckType) {
        let key = deck == .core ? Keys.learnedIDsCore : Keys.learnedIDsVyvu
        if let data = try? JSONEncoder().encode(Array(ids)) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
    func updateLastSessionDate() {
        UserDefaults.standard.set(ISO8601DateFormatter().string(from: Date()),
                                  forKey: Keys.lastSessionDate)
    }
    
    func getLastSessionDate() -> Date? {
        guard let dateString = UserDefaults.standard.string(forKey: Keys.lastSessionDate) else {
            return nil
        }
        return ISO8601DateFormatter().date(from: dateString)
    }
    
    func saveSettings() {
        if let encoded = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(encoded, forKey: Keys.settings)
        }
    }
}

// MARK: - Data Models for JSON parsing
struct WordsDataFile: Codable {
    let dataModelVersion: Int
    let metadata: Metadata?
    let entries: [Word]
    
    struct Metadata: Codable {
        let sourceLanguage: String?
        let targetLanguage: String?
        let level: String?
        let totalEntries: Int?
        let lastUpdated: String?
        let description: String?
    }
}
