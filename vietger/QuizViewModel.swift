import Foundation
import SwiftUI

enum QuizStage { case setup, inQuiz, summary }

@MainActor
final class QuizViewModel: ObservableObject {
    // Dependencies
    private var appState: AppState?            // injected later
    private let engine: QuizEngine
    private let speech: SpeechService

    // Stage
    @Published var stage: QuizStage = .setup

    // Setup inputs
    @Published var chosenDirection: QuizDirection? = nil
    @Published var selectedSize: Int? = nil
    @Published var customSize: String = ""

    // Session
    @Published var sessionWords: [Word] = []
    @Published var currentIndex: Int = 0
    var current: Word? { sessionWords.indices.contains(currentIndex) ? sessionWords[currentIndex] : nil }

    // Answer UI
    @Published var answer: String = ""
    @Published var reveal: Bool = false
    @Published var isCorrect: Bool? = nil

    // Progress tracking
    @Published var correctIDs: Set<String> = []
    @Published var openIDs: Set<String> = []
    @Published var seenIDs: Set<String> = []

    // Derived
    var totalCount: Int { sessionWords.count }
    var oneBasedIndex: Int { min(currentIndex + 1, max(totalCount, 1)) }
    var progressFraction: Double {
        guard totalCount > 0 else { return 0 }
        return Double(currentIndex) / Double(totalCount)
    }
    var allSeen: Bool { !sessionWords.isEmpty && seenIDs.count == sessionWords.count }
    var canStart: Bool { chosenDirection != nil && resolvedSize() > 0 }

    // Init without AppState (we'll inject later)
    init(engine: QuizEngine = QuizEngine(), speech: SpeechService = DefaultSpeechService()) {
        self.engine = engine
        self.speech = speech
    }

    // Inject AppState after the view appears
    func configure(appState: AppState) {
        self.appState = appState
    }

    // MARK: - Setup helpers
    func resolvedSize() -> Int {
        if let n = selectedSize { return n }
        if let m = Int(customSize), m > 0 { return m }
        return 0
    }

    // MARK: - Session lifecycle
    func startSession() {
        guard let appState else { return }
        let size = resolvedSize()
        guard size > 0 else { return }
        let poolBase = appState.unlearnedWords.isEmpty ? appState.allWords : appState.unlearnedWords
        let pool = poolBase.shuffled()
        sessionWords = Array(pool.prefix(max(1, min(size, pool.count))))
        currentIndex = 0
        correctIDs.removeAll()
        openIDs.removeAll()
        seenIDs.removeAll()
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
        } else if let idx = sessionWords.firstIndex(where: { !seenIDs.contains($0.id) }) {
            currentIndex = idx
            if let cur = current { markSeen(cur) }
            resetQuestionUI()
        }
    }

    func goBack() {
        guard currentIndex > 0 else { return }
        currentIndex -= 1
        if let cur = current { markSeen(cur) }
        resetQuestionUI()
    }

    // MARK: - Answering
    func resetQuestionUI() {
        answer = ""; reveal = false; isCorrect = nil
    }

    func evaluate(auto: Bool = false) {
        guard let word = current, let dir = chosenDirection else { return }
        if engine.isCorrect(input: answer, word: word, direction: dir) {
            isCorrect = true
            reveal = true
            markAsLearned(word)
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

    func markAsLearned(_ word: Word) {
        appState?.markLearned(word)
        correctIDs.insert(word.id)
        openIDs.remove(word.id)
    }

    func markSeen(_ word: Word) { seenIDs.insert(word.id) }

    // MARK: - TTS helpers (DE + VI)
    private var ttsRate: Float { appState?.settings.ttsRate ?? 0.45 }

    func speakSource(_ text: String) {
        guard let dir = chosenDirection else { return }
        let lang: SpeechLanguage = (dir == .deToVi) ? .german : .vietnamese
        speech.speak(text, lang: lang, rate: ttsRate)
    }

    func speakTarget(_ text: String) {
        guard let dir = chosenDirection else { return }
        let lang: SpeechLanguage = (dir == .deToVi) ? .vietnamese : .german
        speech.speak(text, lang: lang, rate: ttsRate)
    }
}
