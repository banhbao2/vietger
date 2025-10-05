import SwiftUI
import Combine

@MainActor
final class QuizCoordinator: ObservableObject {
    @Published var session: QuizSession
    @Published var stage: QuizStage = .setup
    @Published var answer = ""
    @Published var reveal = false
    @Published var isCorrect: Bool?
    @Published var reviewWords: [Word]?
    
    weak var environment: AppEnvironment?
    
    init(environment: AppEnvironment? = nil) {
        self.environment = environment
        self.session = QuizSession(
            configuration: QuizConfiguration(deck: .core, direction: .deToVi, size: 10, useAllWords: false),
            words: []
        )
    }
    
    var currentWord: Word? { session.current }
    
    // MARK: - Session Management
    func startSession(with config: QuizConfiguration) {
        guard let env = environment else { return }
        let words = selectWords(config: config, from: env)
        session = QuizSession(configuration: config, words: words)
        stage = .inQuiz
        resetQuestionState()
    }
    
    func startReviewSession(with config: QuizConfiguration, words: [Word]) {
        session = QuizSession(configuration: config, words: words.shuffled())
        stage = .inQuiz
        resetQuestionState()
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
        resetQuestionState()
        reviewWords = nil
    }
    
    // MARK: - Answer Management
    func evaluate() {
        guard let word = currentWord else { return }
        
        let isAnswerCorrect = checkAnswer(input: answer, for: word)
        isCorrect = isAnswerCorrect
        reveal = true
        
        if isAnswerCorrect {
            markWordCorrect(word)
        }
    }
    
    func evaluateRealtime() {
        guard let word = currentWord else { return }
        
        let isAnswerCorrect = checkAnswer(input: answer, for: word)
        isCorrect = isAnswerCorrect
        
        if isAnswerCorrect {
            markWordCorrect(word)
            reveal = true
        }
    }
    
    // MARK: - Navigation
    func advance() {
        if session.currentIndex + 1 < session.words.count {
            session.currentIndex += 1
            resetQuestionState()
        } else {
            completeSession()
        }
    }
    
    func goBack() {
        guard session.currentIndex > 0 else { return }
        session.currentIndex -= 1
        resetQuestionState()
    }
    
    // MARK: - Speech
    func speak(_ text: String, isSource: Bool) {
        guard let env = environment else { return }
        
        let language: SpeechLanguage = determineLanguage(isSource: isSource)
        env.speechService.speak(text, lang: language, rate: env.dataManager.settings.ttsRate)
    }
    
    // MARK: - Private Methods
    private func selectWords(config: QuizConfiguration, from environment: AppEnvironment) -> [Word] {
        var pool = environment.unlearnedWords(for: config.deck)
        if pool.isEmpty {
            pool = environment.words(for: config.deck)
        }
        
        pool.shuffle()
        return config.useAllWords ? pool : Array(pool.prefix(min(config.size, pool.count)))
    }
    
    private func checkAnswer(input: String, for word: Word) -> Bool {
        let normalizedInput = normalizeText(input)
        let expectedAnswers = getExpectedAnswers(for: word).map(normalizeText)
        return expectedAnswers.contains(normalizedInput)
    }
    
    private func getExpectedAnswers(for word: Word) -> [String] {
        session.configuration.direction.isGermanToVietnamese
            ? word.allVietnamese
            : word.allGerman
    }
    
    private func normalizeText(_ text: String) -> String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .lowercased()
    }
    
    private func markWordCorrect(_ word: Word) {
        session.correctIDs.insert(word.id)
        environment?.markLearned(word, deck: session.configuration.deck)
    }
    
    private func resetQuestionState() {
        answer = ""
        reveal = false
        isCorrect = nil
        
        if let word = currentWord {
            session.seenIDs.insert(word.id)
        }
    }
    
    private func determineLanguage(isSource: Bool) -> SpeechLanguage {
        let isGermanToVietnamese = session.configuration.direction.isGermanToVietnamese
        
        if isSource {
            return isGermanToVietnamese ? .german : .vietnamese
        } else {
            return isGermanToVietnamese ? .vietnamese : .german
        }
    }
}
