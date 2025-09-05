import Foundation
import SwiftUI

@MainActor
final class AppState: ObservableObject {

    // MARK: - Persistent learned IDs (per deck)
    @AppStorage("learnedIDs_core") private var learnedIDsCoreData: Data = .init()
    @AppStorage("learnedIDs_vyvu") private var learnedIDsVyvuData: Data = .init()

    /// Core deck learned IDs (kept name "learnedIDs" for compatibility with old code)
    @Published private(set) var learnedIDs: Set<String> = []
    /// Vyvu deck learned IDs
    @Published private(set) var learnedIDsVyvu: Set<String> = []

    // MARK: - Word sources
    /// Core deck words (kept name "allWords" for compatibility)
    @Published private(set) var allWords: [Word] = []
    /// Vyvu deck words
    @Published private(set) var vyvuWords: [Word] = []

    // Derived lists
    var unlearnedWords: [Word] { allWords.filter { !learnedIDs.contains($0.id) } }
    var unlearnedVyvu: [Word]  { vyvuWords.filter { !learnedIDsVyvu.contains($0.id) } }

    // Settings
    struct Settings: Codable { var ttsRate: Float = 0.45 }
    @Published var settings = Settings()

    init() {
        // Load both decks
        allWords  = WordsSource.loadFromBundle() ?? []
        vyvuWords = WordsSource.loadVyvuFromBundle() ?? []

        // Restore learned sets
        learnedIDs      = Self.decodeSet(from: learnedIDsCoreData)
        learnedIDsVyvu  = Self.decodeSet(from: learnedIDsVyvuData)
    }

    // MARK: - Public API (used by quiz + word list)

    func isLearned(_ word: Word, forVyvu: Bool) -> Bool {
        forVyvu ? learnedIDsVyvu.contains(word.id) : learnedIDs.contains(word.id)
    }

    func markLearned(_ word: Word, forVyvu: Bool) {
        if forVyvu {
            if learnedIDsVyvu.insert(word.id).inserted { persistVyvu() }
        } else {
            if learnedIDs.insert(word.id).inserted { persistCore() }
        }
        objectWillChange.send()
    }

    func markUnlearned(_ word: Word, forVyvu: Bool) {
        if forVyvu {
            if learnedIDsVyvu.remove(word.id) != nil { persistVyvu() }
        } else {
            if learnedIDs.remove(word.id) != nil { persistCore() }
        }
        objectWillChange.send()
    }

    func resetLearned(forVyvu: Bool) {
        if forVyvu { learnedIDsVyvu.removeAll(); persistVyvu() }
        else       { learnedIDs.removeAll();     persistCore() }
        objectWillChange.send()
    }

    // MARK: - Persistence helpers

    private func persistCore() { learnedIDsCoreData = Self.encodeSet(learnedIDs) }
    private func persistVyvu() { learnedIDsVyvuData = Self.encodeSet(learnedIDsVyvu) }

    private static func encodeSet(_ set: Set<String>) -> Data {
        (try? JSONEncoder().encode(Array(set))) ?? Data()
    }
    private static func decodeSet(from data: Data) -> Set<String> {
        (try? JSONDecoder().decode([String].self, from: data)).map(Set.init) ?? []
    }
}
