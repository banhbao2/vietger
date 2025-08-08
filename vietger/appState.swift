import Foundation
import SwiftUI

final class AppState: ObservableObject {
    @Published var allWords: [Word] = WordsRepository.a1
    @Published private(set) var learnedIDs: Set<String> = []

    private let defaultsKey = "learnedWordIDs"

    init() {
        loadProgress()
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
}
