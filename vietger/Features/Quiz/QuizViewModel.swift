import SwiftUI
import Combine

@MainActor
final class QuizSessionViewModel: ObservableObject {
    // Dependencies
    weak var appState: AppState?
    var environment: AppEnvironment?
    
    // Session
    @Published var session = QuizSession(
        configuration: QuizConfiguration(
            deck: .core,
            direction: .deToVi,
            size: 10,
            useAllWords: false
        ),
        words: []
    )
    
    @Published var stage: QuizStage = .setup
    @Published var answer = ""
    @Published var reveal = false
    @Published var isCorrect: Bool?
    
    private var engine: QuizEngine?
    private var gamification: GamificationService?
    private var speechService: SpeechService?
    private var dataService: DataService?  // NEW: Add DataService reference
    
    var currentWord: Word? { session.current }
    
    func configure(appState: AppState, environment: AppEnvironment) {
        self.appState = appState
        self.environment = environment
        self.engine = QuizEngine()
        self.gamification = environment.gamificationService
        self.speechService = environment.speechService
        self.dataService = environment.dataService  // NEW: Store DataService reference
    }
    
    func startSession(with config: QuizConfiguration, appState: AppState) {
        let words = selectWords(config: config, appState: appState)
        session = QuizSession(configuration: config, words: words)
        stage = .inQuiz
        resetQuestionUI()
    }
    
    func startReviewSession(with config: QuizConfiguration, words: [Word], appState: AppState) {
        session = QuizSession(configuration: config, words: words.shuffled())
        stage = .inQuiz
        resetQuestionUI()
    }
    
    private func selectWords(config: QuizConfiguration, appState: AppState) -> [Word] {
        var pool = appState.unlearnedWords(for: config.deck)
        if pool.isEmpty {
            pool = appState.words(for: config.deck)
        }
        
        pool.shuffle()
        
        if config.useAllWords {
            return pool
        } else {
            return Array(pool.prefix(min(config.size, pool.count)))
        }
    }
    
    func evaluate() {
        guard let word = currentWord,
              let engine = engine else { return }
        
        let correct = engine.isCorrect(
            input: answer,
            word: word,
            direction: session.configuration.direction
        )
        
        isCorrect = correct
        reveal = true // Show answer after evaluation
        
        if correct {
            session.correctIDs.insert(word.id)
            markAsLearned(word)
        }
    }
    
    // Real-time evaluation (as user types)
    func evaluateRealtime() {
        guard let word = currentWord,
              let engine = engine else { return }
        
        let correct = engine.isCorrect(
            input: answer,
            word: word,
            direction: session.configuration.direction
        )
        
        isCorrect = correct
        
        if correct {
            session.correctIDs.insert(word.id)
            markAsLearned(word)
            reveal = true
        }
    }
    
    func isWordLearned(_ word: Word) -> Bool {
        guard let appState = appState else { return false }
        return appState.isLearned(word, deck: session.configuration.deck) ||
               session.correctIDs.contains(word.id)
    }
    
    func markAsLearned(_ word: Word) {
        guard let appState = appState else { return }
        if !appState.isLearned(word, deck: session.configuration.deck) {
            appState.markLearned(word, deck: session.configuration.deck)
            session.correctIDs.insert(word.id)
        }
        isCorrect = true
        reveal = true
    }
    
    func speak(_ text: String, isSource: Bool) {
        guard let speechService = speechService else { return }
        let language: SpeechLanguage
        
        if isSource {
            language = session.configuration.direction.isGermanToVietnamese ? .german : .vietnamese
        } else {
            language = session.configuration.direction.isGermanToVietnamese ? .vietnamese : .german
        }
        
        let rate: Float = environment?.persistenceService.settings.ttsRate ?? 0.45
        speechService.speak(text, lang: language, rate: rate)
    }
    
    // NEW: Check if word has an example sentence
    func hasSentence(for word: Word) -> Bool {
        return dataService?.getSentence(for: word) != nil
    }
    
    // NEW: Get sentence for word
    func getSentence(for word: Word) -> Sentence? {
        return dataService?.getSentence(for: word)
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
        _ = gamification?.completeSession(
            correctWords: session.correctIDs.count,
            totalWords: session.words.count
        )
        stage = .summary
    }
    
    func reset() {
        stage = .setup
        session = QuizSession(
            configuration: session.configuration,
            words: []
        )
        resetQuestionUI()
    }
    
    func expectedAnswers(for word: Word) -> [String] {
        guard let engine = engine else { return [] }
        return engine.expectedAnswers(
            for: word,
            direction: session.configuration.direction
        )
    }
}
