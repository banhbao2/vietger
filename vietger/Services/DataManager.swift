import SwiftUI
import Combine

final class DataManager: ObservableObject {
    // MARK: - Constants
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
    
    private enum FileNames {
        static let core = "words_sentences"
        static let vyvu = "vyvu_words_sentences"
    }
    
    // MARK: - Properties
    @AppStorage(Keys.userStreak) var userStreak: Int = 0
    @AppStorage(Keys.totalXP) var totalXP: Int = 0
    @AppStorage(Keys.longestStreak) var longestStreak: Int = 0
    @AppStorage(Keys.totalWordsLearned) var totalWordsLearned: Int = 0
    @Published var settings: Settings
    
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    private let dateFormatter = ISO8601DateFormatter()
    
    init() {
        self.settings = Self.loadSettings() ?? Settings()
    }
    
    // MARK: - Data Loading
    func preloadAllData() async -> (core: [Word], vyvu: [Word]) {
        async let core = loadWords(for: .core)
        async let vyvu = loadWords(for: .vyvu)
        return await (core, vyvu)
    }
    
    private func loadWords(for deck: DeckType) async -> [Word] {
        let fileName = deck == .core ? FileNames.core : FileNames.vyvu
        
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("⚠️ Failed to load \(fileName).json")
            return []
        }
        
        do {
            let file = try decoder.decode(WordsDataFile.self, from: data)
            print("✅ Loaded \(file.entries.count) words from \(fileName).json")
            return file.entries
        } catch {
            print("⚠️ Failed to decode \(fileName).json: \(error)")
            return []
        }
    }
    
    // MARK: - Persistence
    func loadLearnedIDs(for deck: DeckType) -> Set<String> {
        let key = deck == .core ? Keys.learnedIDsCore : Keys.learnedIDsVyvu
        guard let data = UserDefaults.standard.data(forKey: key),
              let ids = try? decoder.decode([String].self, from: data) else {
            return []
        }
        return Set(ids)
    }
    
    func saveLearnedIDs(_ ids: Set<String>, for deck: DeckType) {
        let key = deck == .core ? Keys.learnedIDsCore : Keys.learnedIDsVyvu
        guard let data = try? encoder.encode(Array(ids)) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
    
    func updateLastSessionDate() {
        UserDefaults.standard.set(dateFormatter.string(from: Date()), forKey: Keys.lastSessionDate)
    }
    
    func getLastSessionDate() -> Date? {
        guard let dateString = UserDefaults.standard.string(forKey: Keys.lastSessionDate) else {
            return nil
        }
        return dateFormatter.date(from: dateString)
    }
    
    func saveSettings() {
        guard let encoded = try? encoder.encode(settings) else { return }
        UserDefaults.standard.set(encoded, forKey: Keys.settings)
    }
    
    // MARK: - Private Helpers
    private static func loadSettings() -> Settings? {
        guard let data = UserDefaults.standard.data(forKey: Keys.settings),
              let settings = try? JSONDecoder().decode(Settings.self, from: data) else {
            return nil
        }
        return settings
    }
}

// MARK: - Data Models
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
