import SwiftUI
import Combine

// MARK: - App Environment for Dependency Injection
@MainActor
final class AppEnvironment: ObservableObject {
    // Services
    let dataService: DataService
    let speechService: SpeechService
    let gamificationService: GamificationService
    let persistenceService: PersistenceService
    
    // Shared ViewModels (singleton pattern for heavy operations)
    private var quizViewModel: QuizSessionViewModel?  // Changed to QuizSessionViewModel
    private var wordListViewModel: WordListViewModel?
    
    init() {
        self.persistenceService = PersistenceService()
        self.dataService = DataService()
        self.speechService = DefaultSpeechService()
        self.gamificationService = GamificationService(persistence: persistenceService)
    }
    
    // Factory methods for ViewModels with caching
    func makeQuizViewModel(appState: AppState) -> QuizSessionViewModel {  // Changed return type
        if let existing = quizViewModel {
            existing.reset()
            return existing
        }
        let vm = QuizSessionViewModel()  // Changed to QuizSessionViewModel
        vm.configure(appState: appState, environment: self)
        quizViewModel = vm
        return vm
    }
    
    func makeWordListViewModel(appState: AppState) -> WordListViewModel {
        if let existing = wordListViewModel {
            return existing
        }
        let vm = WordListViewModel()
        vm.configure(appState: appState)
        wordListViewModel = vm
        return vm
    }
    
    // Clear cached ViewModels when memory warning
    func clearCache() {
        quizViewModel = nil
        wordListViewModel = nil
    }
}
