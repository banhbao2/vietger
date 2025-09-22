import SwiftUI
import Combine

@MainActor
final class QuizCoordinator: ObservableObject {
    @Published var session: QuizSession = QuizSession(
        configuration: QuizConfiguration(deck: .core, direction: .deToVi, size: 10, useAllWords: false),
        words: []
    )
    @Published var stage: QuizStage = .setup
    @Published var answer = ""
    @Published var reveal = false
    @Published var isCorrect: Bool?
    @Published var reviewWords: [Word]? = nil
    
    weak var environment: AppEnvironment?
    
    init(environment: AppEnvironment? = nil) {
        self.environment = environment
    }
    
    var currentWord: Word? { session.current }
    
    func startSession(with config: QuizConfiguration) {
        guard let env = environment else { return }
        let words = selectWords(config: config, environment: env)
        session = QuizSession(configuration: config, words: words)
        stage = .inQuiz
        resetQuestionUI()
    }
    
    func startReviewSession(with config: QuizConfiguration, words: [Word]) {
        session = QuizSession(configuration: config, words: words.shuffled())
        stage = .inQuiz
        resetQuestionUI()
    }
    
    private func selectWords(config: QuizConfiguration, environment: AppEnvironment) -> [Word] {
        var pool = environment.unlearnedWords(for: config.deck)
        if pool.isEmpty {
            pool = environment.words(for: config.deck)
        }
        pool.shuffle()
        return config.useAllWords ? pool : Array(pool.prefix(min(config.size, pool.count)))
    }
    
    func evaluate() {
        guard let word = currentWord else { return }
        let correct = isCorrect(input: answer, word: word, direction: session.configuration.direction)
        isCorrect = correct
        reveal = true
        
        if correct {
            session.correctIDs.insert(word.id)
            environment?.markLearned(word, deck: session.configuration.deck)
        }
    }
    
    func evaluateRealtime() {
        guard let word = currentWord else { return }
        let correct = isCorrect(input: answer, word: word, direction: session.configuration.direction)
        isCorrect = correct
        
        if correct {
            session.correctIDs.insert(word.id)
            environment?.markLearned(word, deck: session.configuration.deck)
            reveal = true
        }
    }
    
    private func isCorrect(input: String, word: Word, direction: QuizDirection) -> Bool {
        let normalizedInput = normalize(input)
        let expectedAnswers = (direction.isGermanToVietnamese ? word.allVietnamese : word.allGerman)
            .map(normalize)
        return expectedAnswers.contains(normalizedInput)
    }
    
    private func normalize(_ text: String) -> String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .lowercased()
    }
    
    func advance() {
        if session.currentIndex + 1 < session.words.count {
            session.currentIndex += 1
            resetQuestionUI()
        } else {
            completeSession()
        }
    }
    
    func goBack() {
        guard session.currentIndex > 0 else { return }
        session.currentIndex -= 1
        resetQuestionUI()
    }
    
    private func resetQuestionUI() {
        answer = ""
        reveal = false
        isCorrect = nil
        
        if let word = currentWord {
            session.seenIDs.insert(word.id)
        }
    }
    
    func completeSession() {
        _ = environment?.gamificationService.completeSession(
            correctWords: session.correctIDs.count,
            totalWords: session.words.count
        )
        stage = .summary
    }
    
    func reset() {
        stage = .setup
        session = QuizSession(configuration: session.configuration, words: [])
        resetQuestionUI()
        reviewWords = nil
    }
    
    func speak(_ text: String, isSource: Bool) {
        guard let env = environment else { return }
        let language: SpeechLanguage = isSource
            ? (session.configuration.direction.isGermanToVietnamese ? .german : .vietnamese)
            : (session.configuration.direction.isGermanToVietnamese ? .vietnamese : .german)
        
        env.speechService.speak(text, lang: language, rate: env.dataManager.settings.ttsRate)
    }
}
