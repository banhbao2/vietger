import SwiftUI

struct QuizSetupView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = QuizSetupViewModel()
    
    let reviewWords: [Word]?  // New property for review mode (accept from caller)
    let onStart: (QuizConfiguration) -> Void
    
    private var isReviewMode: Bool { reviewWords != nil }
    
    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.l) {
                // Review mode banner
                if isReviewMode {
                    HStack {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .foregroundColor(Theme.Colors.warning)
                        Text("Review Mode: \(reviewWords?.count ?? 0) words to practice")
                            .font(Theme.Typography.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(Theme.Spacing.m)
                    .background(Theme.Colors.warning.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.button))
                    .padding(.horizontal, Theme.Spacing.m)
                }
                
                headerSection
                
                // Only show deck selection if not in review mode
                if !isReviewMode {
                    deckSelection
                }
                
                if viewModel.selectedDeck != nil || isReviewMode {
                    directionSelection
                }
                
                if (viewModel.selectedDeck != nil && viewModel.selectedDirection != nil) ||
                   (isReviewMode && viewModel.selectedDirection != nil) {
                    if !isReviewMode {
                        sizeSelection
                    }
                }
                
                if viewModel.canStart || (isReviewMode && viewModel.selectedDirection != nil) {
                    startButton
                }
            }
            .padding(Theme.Spacing.m)
        }
        .onAppear {
            viewModel.configure(appState: appState)
            // Auto-select deck if in review mode
            if isReviewMode {
                viewModel.selectedDeck = .core // or determine from review words
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: Theme.Spacing.s) {
            Text(isReviewMode ? "Review Mistakes" : "Let's get started!")
                .font(Theme.Typography.title)
            Text(isReviewMode ? "Practice the words you missed" : "Choose your learning preferences")
                .font(Theme.Typography.body)
                .foregroundColor(Theme.Colors.textSecondary)
        }
    }
    
    private var deckSelection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.m) {
            Text("1. Choose your deck")
                .font(Theme.Typography.headline)
            
            ForEach(DeckType.allCases, id: \.self) { deck in
                DeckSelectionCard(
                    deck: deck,
                    isSelected: viewModel.selectedDeck == deck,
                    wordCount: viewModel.availableWords(for: deck)
                ) {
                    viewModel.selectedDeck = deck
                }
            }
        }
    }
    
    private var directionSelection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.m) {
            Text(isReviewMode ? "1. Translation direction" : "2. Translation direction")
                .font(Theme.Typography.headline)
            
            HStack(spacing: Theme.Spacing.m) {
                ForEach(QuizDirection.allCases, id: \.self) { direction in
                    DirectionCard(
                        direction: direction,
                        isSelected: viewModel.selectedDirection == direction
                    ) {
                        viewModel.selectedDirection = direction
                    }
                }
            }
        }
    }
    
    private var sizeSelection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.m) {
            Text("3. Number of words")
                .font(Theme.Typography.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Theme.Spacing.s) {
                    ForEach([5, 10, 15, 20], id: \.self) { size in
                        SizePill(
                            text: "\(size)",
                            isSelected: viewModel.selectedSize == size
                        ) {
                            viewModel.selectedSize = size
                        }
                    }
                    
                    SizePill(
                        text: "All",
                        isSelected: viewModel.selectedSize == -1
                    ) {
                        viewModel.selectedSize = -1
                    }
                }
            }
            
            // Info note
            if let deck = viewModel.selectedDeck {
                HStack {
                    Image(systemName: "info.circle")
                        .foregroundColor(Theme.Colors.primary)
                        .font(.system(size: 14))
                    
                    Text("\(viewModel.availableWords(for: deck)) unlearned words available")
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.Colors.textSecondary)
                }
                .padding(Theme.Spacing.s)
                .background(
                    RoundedRectangle(cornerRadius: Theme.Radius.small)
                        .fill(Theme.Colors.primary.opacity(0.1))
                )
            }
        }
    }
    
    private var startButton: some View {
        Button {
            if isReviewMode {
                // Use review words count as size
                var config = viewModel.buildConfiguration()
                config = QuizConfiguration(
                    deck: config.deck,
                    direction: viewModel.selectedDirection ?? .deToVi,
                    size: reviewWords?.count ?? 0,
                    useAllWords: false
                )
                onStart(config)
            } else {
                onStart(viewModel.buildConfiguration())
            }
        } label: {
            HStack {
                Image(systemName: isReviewMode ? "arrow.triangle.2.circlepath" : "play.fill")
                Text(isReviewMode ? "Start Review" : "Start Quiz")
            }
        }
        .buttonStyle(PrimaryButtonStyle())
        .padding(.top, Theme.Spacing.m)
    }
}

struct DeckSelectionCard: View {
    let deck: DeckType
    let isSelected: Bool
    let wordCount: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: Theme.Spacing.s) {
                    Text("\(deck.icon) \(deck.title)")
                        .font(Theme.Typography.headline)
                    Text("\(wordCount) words available")
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.Colors.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? Theme.Colors.primary : Theme.Colors.disabled)
                    .font(.system(size: 24))
            }
            .padding(Theme.Spacing.m)
            .background(Theme.Colors.card)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.card)
                    .stroke(isSelected ? Theme.Colors.primary : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct DirectionCard: View {
    let direction: QuizDirection
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: Theme.Spacing.m) {
                HStack {
                    Text(direction.sourceFlag)
                        .font(.system(size: 32))
                    Image(systemName: "arrow.right")
                        .foregroundColor(Theme.Colors.textSecondary)
                    Text(direction.targetFlag)
                        .font(.system(size: 32))
                }
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? Theme.Colors.primary : Theme.Colors.disabled)
                    .font(.system(size: 20))
            }
            .frame(maxWidth: .infinity)
            .padding(Theme.Spacing.m)
            .background(Theme.Colors.card)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.card)
                    .stroke(isSelected ? Theme.Colors.primary : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SizePill: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(Theme.Typography.headline)
                .foregroundColor(isSelected ? .white : Theme.Colors.text)
                .padding(.horizontal, Theme.Spacing.m)
                .padding(.vertical, Theme.Spacing.s)
                .background(
                    Capsule()
                        .fill(isSelected ? Theme.Colors.primary : Theme.Colors.card)
                )
        }
    }
}
