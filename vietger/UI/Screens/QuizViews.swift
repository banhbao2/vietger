import SwiftUI

// MARK: - Main Quiz View
struct QuizView: View {
    @EnvironmentObject var environment: AppEnvironment
    @StateObject private var coordinator = QuizCoordinator()
    
    var body: some View {
        ZStack {
            Theme.Colors.background.ignoresSafeArea()
            
            switch coordinator.stage {
            case .setup:
                QuizSetupView(coordinator: coordinator)
            case .inQuiz:
                QuizSessionView(coordinator: coordinator)
            case .summary:
                QuizSummaryView(coordinator: coordinator)
            }
        }
        .navigationTitle("Quiz")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            coordinator.environment = environment
        }
    }
}

// MARK: - Quiz Setup
struct QuizSetupView: View {
    @ObservedObject var coordinator: QuizCoordinator
    @State private var selectedDeck: DeckType = .vyvu
    @State private var selectedDirection: QuizDirection = .viToDe
    @State private var selectedSize: Int = -1
    
    private var isReviewMode: Bool { coordinator.reviewWords != nil }
    
    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.l) {
                if isReviewMode { reviewBanner }
                headerSection
                if !isReviewMode { deckSelection }
                directionSelection
                if !isReviewMode { sizeSelection }
                startButton
            }
            .padding(Theme.Spacing.m)
        }
    }
    
    private var reviewBanner: some View {
        BannerView(
            icon: "arrow.triangle.2.circlepath",
            text: "Review Mode: \(coordinator.reviewWords?.count ?? 0) words",
            color: Theme.Colors.warning
        )
    }
    
    private var headerSection: some View {
        VStack(spacing: Theme.Spacing.s) {
            Text(isReviewMode ? "Review Mistakes" : "Let's get started!")
                .font(Theme.Typography.title)
            Text(isReviewMode ? "Practice the words you missed" : "Choose your preferences")
                .font(Theme.Typography.body)
                .foregroundColor(Theme.Colors.textSecondary)
        }
    }
    
    private var deckSelection: some View {
        SelectionSection(title: "1. Choose your deck") {
            ForEach([DeckType.vyvu, DeckType.core], id: \.self) { deck in
                SelectionCard(
                    title: "\(deck.icon) \(deck.title)",
                    isSelected: selectedDeck == deck,
                    action: { selectedDeck = deck }
                )
            }
        }
    }
    
    private var directionSelection: some View {
        SelectionSection(title: "\(isReviewMode ? "1" : "2"). Translation direction") {
            HStack(spacing: Theme.Spacing.m) {
                ForEach([QuizDirection.viToDe, QuizDirection.deToVi], id: \.self) { direction in
                    DirectionCard(
                        direction: direction,
                        isSelected: selectedDirection == direction,
                        action: { selectedDirection = direction }
                    )
                }
            }
        }
    }
    
    private var sizeSelection: some View {
        SelectionSection(title: "3. Number of words") {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Theme.Spacing.s) {
                    ForEach([5, 10, 15, 20, -1], id: \.self) { size in
                        SizeSelectionButton(
                            size: size,
                            isSelected: selectedSize == size,
                            action: { selectedSize = size }
                        )
                    }
                }
            }
        }
    }
    
    private var startButton: some View {
        Button {
            startQuiz()
        } label: {
            HStack {
                Image(systemName: isReviewMode ? "arrow.triangle.2.circlepath" : "play.fill")
                Text(isReviewMode ? "Start Review" : "Start Quiz")
            }
        }
        .buttonStyle(PrimaryButtonStyle())
        .padding(.top, Theme.Spacing.m)
    }
    
    private func startQuiz() {
        let config = QuizConfiguration(
            deck: selectedDeck,
            direction: selectedDirection,
            size: isReviewMode ? (coordinator.reviewWords?.count ?? 0) : selectedSize,
            useAllWords: selectedSize == -1
        )
        
        if let reviewWords = coordinator.reviewWords {
            coordinator.startReviewSession(with: config, words: reviewWords)
        } else {
            coordinator.startSession(with: config)
        }
    }
}

// MARK: - Quiz Session
struct QuizSessionView: View {
    @ObservedObject var coordinator: QuizCoordinator
    @State private var shakeAmount: CGFloat = 0
    @State private var showSentenceModal = false
    
    var body: some View {
        VStack(spacing: Theme.Spacing.m) {
            progressHeader
            
            ScrollView {
                VStack(spacing: Theme.Spacing.l) {
                    if let word = coordinator.currentWord {
                        quizCard(for: word)
                        answerField
                        actionButtons
                        finishButton
                    }
                }
                .padding(Theme.Spacing.m)
            }
        }
        .sheet(isPresented: $showSentenceModal) {
            if let word = coordinator.currentWord {
                SentenceModalView(word: word, direction: coordinator.session.configuration.direction)
            }
        }
    }
    
    private var progressHeader: some View {
        ProgressHeader(
            currentIndex: coordinator.session.currentIndex,
            totalCount: coordinator.session.words.count,
            accuracy: coordinator.session.accuracy
        )
        .padding(.horizontal, Theme.Spacing.m)
    }
    
    private func quizCard(for word: Word) -> some View {
        VStack(spacing: Theme.Spacing.m) {
            sourceCard(for: word)
            
            if coordinator.reveal {
                targetCard(for: word, showSentenceModal: $showSentenceModal)
            } else {
                revealButton
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: coordinator.reveal)
    }
    
    private func sourceCard(for word: Word) -> some View {
        QuizCard(
            flag: coordinator.session.configuration.direction.sourceFlag,
            text: coordinator.session.configuration.direction.isGermanToVietnamese ? word.displayGerman : word.displayVietnamese,
            borderColor: borderColor(),
            actions: {
                cardActions(for: word, isSource: true)
            }
        )
        .shake(times: shakeAmount)
    }
    
    private func targetCard(for word: Word, showSentenceModal: Binding<Bool>) -> some View {
        TargetCard(
            flag: coordinator.session.configuration.direction.targetFlag,
            text: coordinator.session.configuration.direction.isGermanToVietnamese ? word.displayVietnamese : word.displayGerman,
            alternatives: getAlternatives(for: word),
            category: word.category.title,
            hasExample: word.exampleSentence != nil,
            onSpeakTapped: { speakTarget(for: word) },
            onExampleTapped: { showSentenceModal.wrappedValue = true }
        )
    }
    
    private var revealButton: some View {
        Button { coordinator.reveal = true } label: {
            HStack {
                Image(systemName: "eye")
                Text("Reveal Answer")
            }
            .foregroundColor(Theme.Colors.primary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.button)
                    .fill(Theme.Colors.primary.opacity(0.1))
            )
        }
    }
    
    private var answerField: some View {
        AnswerField(
            answer: $coordinator.answer,
            borderColor: borderColor(),
            onSubmit: checkAnswer,
            onChange: handleAnswerChange,
            onClear: clearAnswer
        )
    }
    
    private var actionButtons: some View {
        HStack(spacing: Theme.Spacing.m) {
            Button("Back") {
                coordinator.goBack()
                shakeAmount = 0
            }
            .buttonStyle(SecondaryButtonStyle())
            .disabled(coordinator.session.currentIndex == 0)
            
            Button("Next") {
                coordinator.advance()
                shakeAmount = 0
            }
            .buttonStyle(PrimaryButtonStyle())
        }
    }
    
    private var finishButton: some View {
        Button {
            coordinator.completeSession()
        } label: {
            HStack {
                Image(systemName: "flag.checkered")
                Text("Finish & Review")
            }
            .foregroundColor(Theme.Colors.primary)
            .frame(maxWidth: .infinity)
            .padding(Theme.Spacing.m)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.button)
                    .fill(Theme.Colors.primary.opacity(0.1))
            )
        }
        .padding(.top, Theme.Spacing.s)
    }
    
    // MARK: - Helper Methods
    private func cardActions(for word: Word, isSource: Bool) -> some View {
        HStack(spacing: Theme.Spacing.s) {
            LearnedToggleButton(
                isLearned: coordinator.environment?.isLearned(word, deck: coordinator.session.configuration.deck) == true,
                onToggle: { toggleLearned(for: word) }
            )
            
            SpeakButton {
                let text = isSource
                    ? (coordinator.session.configuration.direction.isGermanToVietnamese ? word.displayGerman : word.displayVietnamese)
                    : (coordinator.session.configuration.direction.isGermanToVietnamese ? word.displayVietnamese : word.displayGerman)
                coordinator.speak(text, isSource: isSource)
            }
        }
    }
    
    private func getAlternatives(for word: Word) -> [String] {
        coordinator.session.configuration.direction.isGermanToVietnamese
            ? word.vietnamese.alternatives
            : word.german.alternatives
    }
    
    private func speakTarget(for word: Word) {
        let text = coordinator.session.configuration.direction.isGermanToVietnamese
            ? word.displayVietnamese
            : word.displayGerman
        coordinator.speak(text, isSource: false)
    }
    
    private func toggleLearned(for word: Word) {
        let isCurrentlyLearned = coordinator.environment?.isLearned(word, deck: coordinator.session.configuration.deck) == true
        
        if isCurrentlyLearned {
            coordinator.environment?.markUnlearned(word, deck: coordinator.session.configuration.deck)
            coordinator.session.correctIDs.remove(word.id)
            coordinator.isCorrect = nil
            coordinator.reveal = false
        } else {
            coordinator.environment?.markLearned(word, deck: coordinator.session.configuration.deck)
            coordinator.session.correctIDs.insert(word.id)
            coordinator.isCorrect = true
            coordinator.reveal = true
        }
    }
    
    private func borderColor() -> Color {
        guard let isCorrect = coordinator.isCorrect else { return Theme.Colors.disabled }
        return isCorrect ? Theme.Colors.success : Theme.Colors.danger
    }
    
    private func handleAnswerChange() {
        coordinator.evaluateRealtime()
        
        if coordinator.isCorrect == true {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }
    
    private func checkAnswer() {
        coordinator.evaluate()
        if coordinator.isCorrect == false {
            withAnimation { shakeAmount += 1 }
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        } else if coordinator.isCorrect == true {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }
    
    private func clearAnswer() {
        coordinator.answer = ""
        coordinator.isCorrect = nil
    }
}

// MARK: - Quiz Summary
struct QuizSummaryView: View {
    @ObservedObject var coordinator: QuizCoordinator
    @State private var selectedTab = 0
    
    private var correctWords: [Word] {
        coordinator.session.words.filter { coordinator.session.correctIDs.contains($0.id) }
    }
    
    private var incorrectWords: [Word] {
        coordinator.session.words.filter { !coordinator.session.correctIDs.contains($0.id) }
    }
    
    private var accuracy: Int {
        guard !coordinator.session.words.isEmpty else { return 0 }
        return Int((Double(correctWords.count) / Double(coordinator.session.words.count)) * 100)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            AccuracyHeader(accuracy: accuracy)
            TabSelector(selectedTab: $selectedTab, correctCount: correctWords.count, incorrectCount: incorrectWords.count)
            
            TabView(selection: $selectedTab) {
                OverviewTab(totalWords: coordinator.session.words.count, correctWords: correctWords.count).tag(0)
                WordListTab(words: correctWords, isCorrect: true).tag(1)
                WordListTab(words: incorrectWords, isCorrect: false).tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            BottomActions(
                onContinue: { coordinator.reset() },
                onReview: hasIncorrectWords ? { startReviewMode() } : nil,
                reviewCount: incorrectWords.count
            )
        }
        .background(Theme.Colors.background)
    }
    
    private var hasIncorrectWords: Bool { !incorrectWords.isEmpty }
    
    private func startReviewMode() {
        coordinator.reviewWords = incorrectWords
        coordinator.stage = .setup
    }
}

// MARK: - Supporting Components
struct BannerView: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
            Text(text)
                .font(Theme.Typography.headline)
        }
        .frame(maxWidth: .infinity)
        .padding(Theme.Spacing.m)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.button))
    }
}

struct SelectionSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.m) {
            Text(title)
                .font(Theme.Typography.headline)
            content
        }
    }
}

struct SelectionCard: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(Theme.Typography.headline)
                Spacer()
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? Theme.Colors.primary : Theme.Colors.disabled)
            }
            .padding(Theme.Spacing.m)
            .background(Theme.Colors.card)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card))
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
            }
            .frame(maxWidth: .infinity)
            .padding(Theme.Spacing.m)
            .background(Theme.Colors.card)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SizeSelectionButton: View {
    let size: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(size == -1 ? "All" : "\(size)")
                .font(Theme.Typography.headline)
                .foregroundColor(isSelected ? .white : Theme.Colors.text)
                .padding(.horizontal, Theme.Spacing.m)
                .padding(.vertical, Theme.Spacing.s)
                .background(
                    Capsule().fill(isSelected ? Theme.Colors.primary : Theme.Colors.card)
                )
        }
    }
}

struct ProgressHeader: View {
    let currentIndex: Int
    let totalCount: Int
    let accuracy: Double
    
    var body: some View {
        VStack(spacing: Theme.Spacing.s) {
            LinearProgress(progress: Double(currentIndex) / Double(totalCount))
                .frame(height: 6)
            HStack {
                Text("Word \(min(currentIndex + 1, totalCount)) / \(totalCount)")
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
                Spacer()
                Text("\(Int(accuracy * 100))%")
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
            }
        }
    }
}

struct QuizCard<Actions: View>: View {
    let flag: String
    let text: String
    let borderColor: Color
    let actions: Actions
    
    init(flag: String, text: String, borderColor: Color, @ViewBuilder actions: () -> Actions) {
        self.flag = flag
        self.text = text
        self.borderColor = borderColor
        self.actions = actions()
    }
    
    var body: some View {
        VStack(spacing: Theme.Spacing.s) {
            HStack {
                Text(flag)
                    .font(.system(size: 24))
                Spacer()
                actions
            }
            
            Text(text)
                .font(.system(size: 32, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, Theme.Spacing.m)
        }
        .padding(Theme.Spacing.m)
        .background(Theme.Colors.card)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.card)
                .stroke(borderColor, lineWidth: 2)
        )
    }
}

struct TargetCard: View {
    let flag: String
    let text: String
    let alternatives: [String]
    let category: String
    let hasExample: Bool
    let onSpeakTapped: () -> Void
    let onExampleTapped: () -> Void
    
    var body: some View {
        VStack(spacing: Theme.Spacing.s) {
            HStack {
                Text(flag)
                    .font(.system(size: 20))
                
                Spacer()
                
                categoryBadge
                
                HStack(spacing: Theme.Spacing.s) {
                    if hasExample {
                        ActionButton(icon: "text.quote", action: onExampleTapped)
                    }
                    ActionButton(icon: "speaker.wave.2.fill", action: onSpeakTapped)
                }
            }
            
            Text(text)
                .font(.system(size: 26, weight: .medium))
                .frame(maxWidth: .infinity)
                .padding(.vertical, Theme.Spacing.s)
            
            if !alternatives.isEmpty {
                alternativesText
            }
        }
        .padding(Theme.Spacing.m)
        .background(Theme.Colors.success.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card))
        .transition(.asymmetric(
            insertion: .move(edge: .bottom).combined(with: .opacity),
            removal: .scale(scale: 0.9).combined(with: .opacity)
        ))
    }
    
    private var categoryBadge: some View {
        Text(category)
            .font(.system(size: 11, weight: .medium))
            .foregroundColor(Theme.Colors.primary)
            .padding(.horizontal, Theme.Spacing.s)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Theme.Colors.primary.opacity(0.1))
            )
    }
    
    private var alternativesText: some View {
        Text("Also: \(alternatives.joined(separator: ", "))")
            .font(Theme.Typography.caption)
            .foregroundColor(Theme.Colors.textSecondary)
    }
}

struct AnswerField: View {
    @Binding var answer: String
    let borderColor: Color
    let onSubmit: () -> Void
    let onChange: () -> Void
    let onClear: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.s) {
            Text("Your answer")
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textSecondary)
            
            HStack {
                TextField("Type translation...", text: $answer)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .padding(Theme.Spacing.m)
                    .background(
                        RoundedRectangle(cornerRadius: Theme.Radius.button)
                            .fill(Theme.Colors.card)
                            .overlay(
                                RoundedRectangle(cornerRadius: Theme.Radius.button)
                                    .stroke(borderColor, lineWidth: 2)
                            )
                    )
                    .onSubmit(onSubmit)
                    .onChange(of: answer) { _ in
                        onChange()
                    }
                
                if !answer.isEmpty {
                    Button(action: onClear) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Theme.Colors.textSecondary)
                    }
                }
            }
        }
    }
}

struct ActionButton: View {
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(Theme.Colors.primary)
                .frame(width: 30, height: 30)
                .background(
                    Circle().fill(Theme.Colors.primary.opacity(0.1))
                )
        }
    }
}

struct LearnedToggleButton: View {
    let isLearned: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            Image(systemName: isLearned ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 20))
                .foregroundColor(isLearned ? Theme.Colors.success : Theme.Colors.textSecondary)
                .frame(width: 36, height: 36)
                .background(
                    Circle().fill((isLearned ? Theme.Colors.success : Theme.Colors.textSecondary).opacity(0.1))
                )
        }
    }
}

struct SpeakButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "speaker.wave.2.fill")
                .font(.system(size: 18))
                .foregroundColor(Theme.Colors.primary)
                .frame(width: 36, height: 36)
                .background(
                    Circle().fill(Theme.Colors.primary.opacity(0.1))
                )
        }
    }
}

// MARK: - Summary Components
struct AccuracyHeader: View {
    let accuracy: Int
    
    var body: some View {
        VStack(spacing: Theme.Spacing.m) {
            ProgressRing(
                progress: Double(accuracy) / 100,
                size: 120,
                color: accuracyColor
            )
            .overlay(
                VStack(spacing: 4) {
                    Text("\(accuracy)%")
                        .font(.system(size: 36, weight: .bold))
                    Text("Accuracy")
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.Colors.textSecondary)
                }
            )
            
            Text(motivationalMessage)
                .font(Theme.Typography.title2)
        }
        .padding(.vertical, Theme.Spacing.l)
        .cardStyle()
        .padding(Theme.Spacing.m)
    }
    
    private var accuracyColor: Color {
        if accuracy >= 80 { return Theme.Colors.success }
        else if accuracy >= 50 { return Theme.Colors.warning }
        else { return Theme.Colors.danger }
    }
    
    private var motivationalMessage: String {
        switch accuracy {
        case 90...100: return "Outstanding! 🌟"
        case 70...89: return "Great job! 💪"
        case 50...69: return "Good progress! 📈"
        default: return "Keep practicing! 🎯"
        }
    }
}

struct TabSelector: View {
    @Binding var selectedTab: Int
    let correctCount: Int
    let incorrectCount: Int
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<3) { index in
                Button {
                    withAnimation { selectedTab = index }
                } label: {
                    VStack {
                        Image(systemName: tabIcon(for: index))
                            .font(.system(size: 20))
                        Text(tabTitle(for: index))
                            .font(.system(size: 11))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Theme.Spacing.s)
                    .background(
                        selectedTab == index ?
                        Theme.Colors.primary.opacity(0.1) : Color.clear
                    )
                }
            }
        }
        .background(Theme.Colors.card)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.button))
        .padding(.horizontal, Theme.Spacing.m)
    }
    
    private func tabIcon(for index: Int) -> String {
        switch index {
        case 0: return "chart.bar"
        case 1: return "checkmark.circle.fill"
        case 2: return "exclamationmark.triangle.fill"
        default: return ""
        }
    }
    
    private func tabTitle(for index: Int) -> String {
        switch index {
        case 0: return "Overview"
        case 1: return "Correct (\(correctCount))"
        case 2: return "Review (\(incorrectCount))"
        default: return ""
        }
    }
}

struct OverviewTab: View {
    let totalWords: Int
    let correctWords: Int
    
    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.m) {
                HStack(spacing: Theme.Spacing.m) {
                    StatCard(
                        icon: "clock",
                        value: "\(totalWords)",
                        label: "Words Practiced",
                        color: Theme.Colors.primary
                    )
                    
                    StatCard(
                        icon: "checkmark.circle",
                        value: "\(correctWords)",
                        label: "Correct",
                        color: Theme.Colors.success
                    )
                }
                Spacer(minLength: 100)
            }
            .padding(Theme.Spacing.m)
        }
    }
}

struct WordListTab: View {
    let words: [Word]
    let isCorrect: Bool
    
    var body: some View {
        ScrollView {
            if words.isEmpty {
                EmptyStateView(
                    icon: isCorrect ? "checkmark.circle" : "book.circle",
                    message: isCorrect ? "No correct answers yet" : "Perfect! All answers were correct"
                )
            } else {
                LazyVStack(spacing: Theme.Spacing.s) {
                    ForEach(words) { word in
                        WordReviewCard(word: word, isCorrect: isCorrect)
                    }
                }
                .padding(Theme.Spacing.m)
            }
        }
    }
}

struct EmptyStateView: View {
    let icon: String
    let message: String
    
    var body: some View {
        VStack(spacing: Theme.Spacing.m) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(Theme.Colors.disabled)
            
            Text(message)
                .font(Theme.Typography.body)
                .foregroundColor(Theme.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, Theme.Spacing.xxl)
    }
}

struct WordReviewCard: View {
    let word: Word
    let isCorrect: Bool
    
    var body: some View {
        HStack {
            wordContent
            Spacer()
            statusIcon
        }
        .padding(Theme.Spacing.m)
        .background(Theme.Colors.card)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card))
    }
    
    private var wordContent: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Text("🇩🇪")
                Text(word.displayGerman)
                    .font(Theme.Typography.headline)
            }
            
            HStack(spacing: 6) {
                Text("🇻🇳")
                Text(word.displayVietnamese)
                    .font(Theme.Typography.body)
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            
            categoryBadge
        }
    }
    
    private var categoryBadge: some View {
        Text(word.category.title)
            .font(Theme.Typography.caption2)
            .foregroundColor(Theme.Colors.primary)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(
                Capsule().fill(Theme.Colors.primary.opacity(0.1))
            )
    }
    
    private var statusIcon: some View {
        Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
            .foregroundColor(isCorrect ? Theme.Colors.success : Theme.Colors.danger)
    }
}

struct BottomActions: View {
    let onContinue: () -> Void
    let onReview: (() -> Void)?
    let reviewCount: Int
    
    var body: some View {
        VStack(spacing: Theme.Spacing.m) {
            Button("Continue Learning", action: onContinue)
                .buttonStyle(PrimaryButtonStyle())
            
            if let onReview = onReview, reviewCount > 0 {
                Button {
                    onReview()
                } label: {
                    HStack {
                        Image(systemName: "arrow.triangle.2.circlepath")
                        Text("Review Mistakes (\(reviewCount))")
                    }
                }
                .buttonStyle(SecondaryButtonStyle())
            }
        }
        .padding(Theme.Spacing.m)
        .background(Theme.Colors.card)
    }
}

// MARK: - Sentence Modal
struct SentenceModalView: View {
    let word: Word
    let direction: QuizDirection
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: Theme.Spacing.l) {
                    if let exampleSentence = word.exampleSentence {
                        wordReference
                        sentenceDisplay(exampleSentence)
                    } else {
                        emptyState
                    }
                }
                .padding(Theme.Spacing.m)
            }
            .navigationTitle(word.exampleSentence != nil ? "Example Sentence" : "No Sentence Available")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
    
    private var wordReference: some View {
        WordReferenceCard(word: word, direction: direction)
    }
    
    private func sentenceDisplay(_ exampleSentence: ExampleSentence) -> some View {
        VStack(spacing: Theme.Spacing.m) {
            SentenceCard(flag: "🇩🇪", text: exampleSentence.german, label: "German")
            SentenceCard(flag: "🇻🇳", text: exampleSentence.vietnamese, label: "Vietnamese")
        }
    }
    
    private var emptyState: some View {
        EmptyStateView(
            icon: "exclamationmark.triangle.fill",
            message: "No example sentence available"
        )
    }
}

struct WordReferenceCard: View {
    let word: Word
    let direction: QuizDirection
    
    var body: some View {
        VStack(spacing: Theme.Spacing.s) {
            Text("Word:")
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textSecondary)
            
            HStack(spacing: Theme.Spacing.m) {
                wordDisplay(
                    flag: direction.sourceFlag,
                    text: direction.isGermanToVietnamese ? word.displayGerman : word.displayVietnamese,
                    font: Theme.Typography.headline
                )
                
                Image(systemName: "arrow.right")
                    .foregroundColor(Theme.Colors.textSecondary)
                
                wordDisplay(
                    flag: direction.targetFlag,
                    text: direction.isGermanToVietnamese ? word.displayVietnamese : word.displayGerman,
                    font: Theme.Typography.body
                )
            }
            
            categoryBadge
        }
        .padding(Theme.Spacing.m)
        .background(Theme.Colors.primary.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.button))
    }
    
    private func wordDisplay(flag: String, text: String, font: Font) -> some View {
        VStack {
            Text(flag)
            Text(text).font(font)
        }
    }
    
    private var categoryBadge: some View {
        Text(word.category.title)
            .font(Theme.Typography.caption)
            .padding(.horizontal, Theme.Spacing.s)
            .padding(.vertical, 4)
            .background(
                Capsule().fill(Theme.Colors.primary.opacity(0.1))
            )
            .foregroundColor(Theme.Colors.primary)
    }
}

struct SentenceCard: View {
    let flag: String
    let text: String
    let label: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.s) {
            HStack {
                Text(flag)
                Text(label)
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            Text(text)
                .font(Theme.Typography.body)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Theme.Spacing.m)
        .background(Theme.Colors.background)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.button))
    }
}
