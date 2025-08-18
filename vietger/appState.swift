import Foundation
import SwiftUI

struct AppSettings: Codable {
    var hapticsEnabled: Bool = true
    var ttsRate: Float = 0.45
    var dailyGoal: Int = 10
}

final class AppState: ObservableObject {
    // No fallback to WordsRepository — JSON is the source of truth
    @Published var allWords: [Word] = []
    @Published private(set) var learnedIDs: Set<String> = []

    @Published var settings: AppSettings = AppSettings() {
        didSet { saveSettings() }
    }

    private let defaultsKey = "learnedWordIDs"
    private let settingsKey = "appSettings"

    init() {
        // Load words from bundle JSON (required)
        if let jsonWords = WordsSource.loadFromBundle(), !jsonWords.isEmpty {
            allWords = jsonWords
        } else {
            // Make it loud in debug so you don't ship without data
            assertionFailure("words.json missing or empty. Ensure it's in the bundle with Target Membership checked.")
            allWords = []
        }

        loadProgress()
        loadSettings()
    }

    var unlearnedWords: [Word] {
        allWords.filter { !learnedIDs.contains($0.id) }
    }

    // MARK: - Progress ops
    func markLearned(_ word: Word) {
        learnedIDs.insert(word.id)
        saveProgress()
        objectWillChange.send()
    }

    func markUnlearned(_ word: Word) {
        learnedIDs.remove(word.id)
        saveProgress()
        objectWillChange.send()
    }

    func toggleLearned(_ word: Word) {
        if learnedIDs.contains(word.id) { learnedIDs.remove(word.id) }
        else { learnedIDs.insert(word.id) }
        saveProgress()
        objectWillChange.send()
    }

    func resetAllProgress() {
        learnedIDs.removeAll()
        saveProgress()
        objectWillChange.send()
    }

    // MARK: - Persistence
    private func saveProgress() {
        let arr = Array(learnedIDs)
        UserDefaults.standard.set(arr, forKey: defaultsKey)
    }

    private func loadProgress() {
        if let arr = UserDefaults.standard.stringArray(forKey: defaultsKey) {
            learnedIDs = Set(arr)
        }
    }

    private func saveSettings() {
        if let data = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(data, forKey: settingsKey)
        }
    }

    private func loadSettings() {
        if let data = UserDefaults.standard.data(forKey: settingsKey),
           let s = try? JSONDecoder().decode(AppSettings.self, from: data) {
            settings = s
        }
    }
}
