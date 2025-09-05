import Foundation
import SwiftUI

enum QuizStage { case setup, inQuiz, summary }

@MainActor
final class QuizViewModel: ObservableObject {
    // Dependencies
    private var appState: AppState?
    private let engine: QuizEngine
    private let speech: SpeechService

    // Stage
    @Published var stage: QuizStage = .setup

    // Setup inputs
    @Published var chosenDeck: QuizDeck? = nil
    @Published var chosenDirection: QuizDirection? = nil
    @Published var selectedSize: Int? = nil     // -1 means "All"
    @Published var customSize: String = ""

    var useAllWords: Bool { selectedSize == -1 }

    // Session
    @Published var sessionWords: [Word] = []
    @Published var currentIndex: Int = 0
    var current: Word? { sessionWords.indices.contains(currentIndex) ? sessionWords[currentIndex] : nil }

    // Answer UI
    @Published var answer: String = ""
    @Published var reveal: Bool = false
    @Published var isCorrect: Bool? = nil

    // Progress tracking (per-session)
    @Published var correctIDs: Set<String> = []
    @Published var openIDs: Set<String> = []
    @Published var seenIDs: Set<String> = []

    // Derived
    var totalCount: Int { sessionWords.count }
    var oneBasedIndex: Int { min(currentIndex + 1, max(totalCount, 1)) }
    var progressFraction: Double { totalCount == 0 ? 0 : Double(currentIndex) / Double(totalCount) }
    var allSeen: Bool { !sessionWords.isEmpty && seenIDs.count == sessionWords.count }

    // Start is enabled when we have deck + direction + a non-empty pool
    var canStart: Bool {
        guard chosenDeck != nil, chosenDirection != nil else { return false }
        return !poolForSelection().isEmpty && (useAllWords || resolvedSize() > 0)
    }

    init(engine: QuizEngine = QuizEngine(), speech: SpeechService = DefaultSpeechService()) {
        self.engine = engine
        self.speech = speech
    }

    func configure(appState: AppState) { self.appState = appState }

    // MARK: - Helpers

    func resolvedSize() -> Int {
        if useAllWords { return Int.max }
        if let n = selectedSize, n > 0 { return n }
        if let m = Int(customSize), m > 0 { return m }
        return 0
    }

    private func poolForSelection() -> [Word] {
        guard let appState, let deck = chosenDeck else { return [] }

        switch deck {
        case .core:
            // For core deck, prefer unlearned words if available.
            return appState.unlearnedWords.isEmpty ? appState.allWords : appState.unlearnedWords
        case .vyvu:
            return WordsSource.loadVyvuFromBundle() ?? []
        }
    }

    // MARK: - Session lifecycle

    func startSession() {
        guard chosenDeck != nil, chosenDirection != nil else { return }
        var pool = poolForSelection()
        guard !pool.isEmpty else { return }

        if useAllWords {
            pool = pool.shuffled()
        } else {
            let size = resolvedSize()
            guard size > 0 else { return }
            pool = Array(pool.shuffled().prefix(min(size, pool.count)))
        }

        sessionWords = pool
        currentIndex = 0
        correctIDs = []
        openIDs = []
        seenIDs = []
        resetQuestionUI()
        stage = .inQuiz
        if let cur = current { markSeen(cur) }
    }

    // MARK: - Navigation

    func advance() {
        if let w = current, !correctIDs.contains(w.id) {
            openIDs.insert(w.id)
        }
        if currentIndex + 1 < sessionWords.count {
            currentIndex += 1
            if let cur = current { markSeen(cur) }
            resetQuestionUI()
        } else {
            stage = .summary
        }
    }

    func goBack() {
        guard currentIndex > 0 else { return }
        currentIndex -= 1
        if let cur = current { markSeen(cur) }
        resetQuestionUI()
    }

    // MARK: - Answering

    func resetQuestionUI() { answer = ""; reveal = false; isCorrect = nil }

    func evaluate(auto: Bool = false) {
        guard let word = current, let dir = chosenDirection else { return }
        if engine.isCorrect(input: answer, word: word, direction: dir) {
            isCorrect = true
            reveal = true
            markAsLearnedIfNeeded(word)
        } else if !auto {
            isCorrect = false
        }
    }

    func expectedAnswers(for w: Word) -> [String] {
        guard let dir = chosenDirection else { return [] }
        return engine.expectedAnswers(for: w, direction: dir)
    }

    // MARK: - Progress integration

    func isCurrentLearned(_ word: Word) -> Bool {
        guard let appState else { return false }
        return appState.learnedIDs.contains(word.id) || correctIDs.contains(word.id)
    }

    private func markAsLearnedIfNeeded(_ word: Word) {
        // Persist learned progress only for the core deck.
        if chosenDeck == .core {
            appState?.markLearned(word)
        }
        correctIDs.insert(word.id)
        openIDs.remove(word.id)
    }

    func markSeen(_ word: Word) { seenIDs.insert(word.id) }

    // MARK: - TTS helpers

    private var ttsRate: Float { appState?.settings.ttsRate ?? 0.45 }

    func speakSource(_ text: String) {
        guard let dir = chosenDirection else { return }
        let lang: SpeechLanguage = dir.isGermanToVietnamese ? .german : .vietnamese
        speech.speak(text, lang: lang, rate: ttsRate)
    }

    func speakTarget(_ text: String) {
        guard let dir = chosenDirection else { return }
        let lang: SpeechLanguage = dir.isGermanToVietnamese ? .vietnamese : .german
        speech.speak(text, lang: lang, rate: ttsRate)
    }
}
