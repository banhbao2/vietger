import Foundation

@MainActor
final class QuizSetupViewModel: ObservableObject {
    // Dependencies
    private weak var appState: AppState?
    
    // User selections
    @Published var selectedDeck: DeckType?
    @Published var selectedDirection: QuizDirection?
    // -1 means "All"
    @Published var selectedSize: Int = 10
    
    // Derived
    var canStart: Bool {
        guard let selectedDeck, let selectedDirection else { return false }
        let available = availableWords(for: selectedDeck)
        if selectedSize == -1 {
            return available > 0
        } else {
            return selectedSize > 0 && available > 0
        }
    }
    
    // Configure with app state (called from the View onAppear)
    func configure(appState: AppState) {
        self.appState = appState
        // Optionally set sensible defaults if data is available
        if selectedDeck == nil {
            // Choose a default deck if any words are present, prefer core
            if appState.unlearnedWords(for: .core).isEmpty,
               !appState.unlearnedWords(for: .vyvu).isEmpty {
                selectedDeck = .vyvu
            } else {
                selectedDeck = .core
            }
        }
        if selectedDirection == nil {
            selectedDirection = .deToVi
        }
    }
    
    // Available unlearned words for a given deck
    func availableWords(for deck: DeckType) -> Int {
        guard let appState else { return 0 }
        return appState.unlearnedWords(for: deck).count
    }
    
    // Build the configuration based on current selections
    func buildConfiguration() -> QuizConfiguration {
        let deck = selectedDeck ?? .core
        let direction = selectedDirection ?? .deToVi
        
        let useAll = selectedSize == -1
        let size = useAll ? availableWords(for: deck) : max(0, selectedSize)
        
        return QuizConfiguration(
            deck: deck,
            direction: direction,
            size: size,
            useAllWords: useAll
        )
    }
}
