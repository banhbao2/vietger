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
            if coordinator.environment == nil {
                coordinator.environment = environment
            }
        }
    }
}

// MARK: - Setup View
struct QuizSetupView: View {
    @ObservedObject var coordinator: QuizCoordinator
    @State private var selectedDeck: DeckType = .vyvu
    @State private var selectedDirection: QuizDirection = .viToDe
    @State private var selectedSize: Int = -1  // Preselect "All"
    
    private var isReviewMode: Bool { coordinator.reviewWords != nil }
    
    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.l) {
                if isReviewMode {
                    reviewModeBanner
                }
                
                headerSection
                
                if !isReviewMode {
                    deckSelection
                }
                
                directionSelection
                
                if !isReviewMode {
                    sizeSelection
                }
                
                startButton
            }
            .padding(Theme.Spacing.m)
        }
        .onAppear {
            if isReviewMode, let _ = coordinator.reviewWords?.first {
                selectedDeck = .core
            }
        }
    }
    
    private var reviewModeBanner: some View {
        HStack {
            Image(systemName: "arrow.triangle.2.circlepath")
                .foregroundColor(Theme.Colors.warning)
            Text("Review Mode: \(coordinator.reviewWords?.count ?? 0) words")
                .font(Theme.Typography.headline)
        }
        .frame(maxWidth: .infinity)
        .padding(Theme.Spacing.m)
        .background(Theme.Colors.warning.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.button))
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
    
    private var startButton: some View {
        Button {
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
        } label: {
            HStack {
                Image(systemName: isReviewMode ? "arrow.triangle.2.circlepath" : "play.fill")
                Text(isReviewMode ? "Start Review" : "Start Quiz")
            }
        }
        .buttonStyle(PrimaryButtonStyle())
        .padding(.top, Theme.Spacing.m)
    }
    
    private var deckSelection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.m) {
            Text("1. Choose your deck")
                .font(Theme.Typography.headline)
            
            ForEach([DeckType.vyvu, DeckType.core], id: \.self) { deck in
                Button {
                    selectedDeck = deck
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: Theme.Spacing.s) {
                            Text("\(deck.icon) \(deck.title)")
                                .font(Theme.Typography.headline)
                        }
                        Spacer()
                        Image(systemName: selectedDeck == deck ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(selectedDeck == deck ? Theme.Colors.primary : Theme.Colors.disabled)
                    }
                    .padding(Theme.Spacing.m)
                    .background(Theme.Colors.card)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card))
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    private var directionSelection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.m) {
            Text("\(isReviewMode ? "1" : "2"). Translation direction")
                .font(Theme.Typography.headline)
            
            HStack(spacing: Theme.Spacing.m) {
                ForEach([QuizDirection.viToDe, QuizDirection.deToVi], id: \.self) { direction in
                    Button {
                        selectedDirection = direction
                    } label: {
                        VStack(spacing: Theme.Spacing.m) {
                            HStack {
                                Text(direction.sourceFlag)
                                    .font(.system(size: 32))
                                Image(systemName: "arrow.right")
                                    .foregroundColor(Theme.Colors.textSecondary)
                                Text(direction.targetFlag)
                                    .font(.system(size: 32))
                            }
                            
                            Image(systemName: selectedDirection == direction ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(selectedDirection == direction ? Theme.Colors.primary : Theme.Colors.disabled)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(Theme.Spacing.m)
                        .background(Theme.Colors.card)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card))
                    }
                    .buttonStyle(PlainButtonStyle())
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
                    ForEach([5, 10, 15, 20, -1], id: \.self) { size in
                        Button {
                            selectedSize = size
                        } label: {
                            let isSelected = selectedSize == size
                            Text(size == -1 ? "All" : "\(size)")
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
            }
        }
    }
}

// MARK: - Session View
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
                        quizCard(word: word)
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
                SentenceModalView(
                    word: word,
                    direction: coordinator.session.configuration.direction
                )
            }
        }
    }
    
    private var progressHeader: some View {
        VStack(spacing: Theme.Spacing.s) {
            LinearProgress(progress: coordinator.session.progress)
                .frame(height: 6)
            HStack {
                Text("Word \(min(coordinator.session.currentIndex + 1, coordinator.session.words.count)) / \(coordinator.session.words.count)")
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
                Spacer()
                Text("\(Int(coordinator.session.accuracy * 100))%")
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
            }
        }
        .padding(.horizontal, Theme.Spacing.m)
    }
    
    private func quizCard(word: Word) -> some View {
        VStack(spacing: Theme.Spacing.m) {
            // Source card
            VStack(spacing: Theme.Spacing.s) {
                HStack {
                    Text(coordinator.session.configuration.direction.sourceFlag)
                        .font(.system(size: 24))
                    
                    Spacer()
                    
                    // Mark as learned button
                    Button {
                        if coordinator.environment?.isLearned(word, deck: coordinator.session.configuration.deck) == true {
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
                    } label: {
                        let learned = coordinator.environment?.isLearned(word, deck: coordinator.session.configuration.deck) == true
                        Image(systemName: learned ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 20))
                            .foregroundColor(learned ? Theme.Colors.success : Theme.Colors.textSecondary)
                            .frame(width: 36, height: 36)
                            .background(
                                Circle()
                                    .fill((learned ? Theme.Colors.success : Theme.Colors.textSecondary).opacity(0.1))
                            )
                    }
                    
                    Button {
                        let text = coordinator.session.configuration.direction.isGermanToVietnamese ?
                                   word.displayGerman : word.displayVietnamese
                        coordinator.speak(text, isSource: true)
                    } label: {
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.system(size: 18))
                            .foregroundColor(Theme.Colors.primary)
                            .frame(width: 36, height: 36)
                            .background(
                                Circle()
                                    .fill(Theme.Colors.primary.opacity(0.1))
                            )
                    }
                }
                
                Text(coordinator.session.configuration.direction.isGermanToVietnamese ?
                     word.displayGerman : word.displayVietnamese)
                    .font(.system(size: 32, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Theme.Spacing.m)
            }
            .padding(Theme.Spacing.m)
            .background(Theme.Colors.card)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.card)
                    .stroke(borderColor(), lineWidth: 2)
            )
            .shake(times: shakeAmount)
            
            // Target/Reveal section
            if coordinator.reveal {
                VStack(spacing: Theme.Spacing.s) {
                    HStack {
                        Text(coordinator.session.configuration.direction.targetFlag)
                            .font(.system(size: 20))
                        
                        Spacer()
                        
                        // Category label - Updated without icon
                        Text(word.category.title)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(Theme.Colors.primary)
                            .padding(.horizontal, Theme.Spacing.s)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Theme.Colors.primary.opacity(0.1))
                            )
                        
                        HStack(spacing: Theme.Spacing.s) {
                            // Example sentence button
                            if word.exampleSentence != nil {
                                Button {
                                    showSentenceModal = true
                                } label: {
                                    Image(systemName: "text.quote")
                                        .font(.system(size: 16))
                                        .foregroundColor(Theme.Colors.primary)
                                        .frame(width: 30, height: 30)
                                        .background(
                                            Circle()
                                                .fill(Theme.Colors.primary.opacity(0.1))
                                        )
                                }
                            }
                            
                            Button {
                                let text = coordinator.session.configuration.direction.isGermanToVietnamese ?
                                           word.displayVietnamese : word.displayGerman
                                coordinator.speak(text, isSource: false)
                            } label: {
                                Image(systemName: "speaker.wave.2.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(Theme.Colors.primary)
                                    .frame(width: 30, height: 30)
                                    .background(
                                        Circle()
                                            .fill(Theme.Colors.primary.opacity(0.1))
                                    )
                            }
                        }
                    }
                    
                    Text(coordinator.session.configuration.direction.isGermanToVietnamese ?
                         word.displayVietnamese : word.displayGerman)
                        .font(.system(size: 26, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Theme.Spacing.s)
                    
                    // Show alternatives if any
                    if coordinator.session.configuration.direction.isGermanToVietnamese && !word.vietnamese.alternatives.isEmpty {
                        Text("Also: \(word.vietnamese.alternatives.joined(separator: ", "))")
                            .font(Theme.Typography.caption)
                            .foregroundColor(Theme.Colors.textSecondary)
                    } else if !coordinator.session.configuration.direction.isGermanToVietnamese && !word.german.alternatives.isEmpty {
                        Text("Also: \(word.german.alternatives.joined(separator: ", "))")
                            .font(Theme.Typography.caption)
                            .foregroundColor(Theme.Colors.textSecondary)
                    }
                }
                .padding(Theme.Spacing.m)
                .background(Theme.Colors.success.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card))
                .transition(.asymmetric(
                    insertion: .move(edge: .bottom).combined(with: .opacity),
                    removal: .scale(scale: 0.9).combined(with: .opacity)
                ))
            } else {
                Button {
                    coordinator.reveal = true
                } label: {
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
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: coordinator.reveal)
    }
    
    private var answerField: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.s) {
            Text("Your answer")
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textSecondary)
            
            HStack {
                TextField("Type translation...", text: $coordinator.answer)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .padding(Theme.Spacing.m)
                    .background(
                        RoundedRectangle(cornerRadius: Theme.Radius.button)
                            .fill(Theme.Colors.card)
                            .overlay(
                                RoundedRectangle(cornerRadius: Theme.Radius.button)
                                    .stroke(borderColor(), lineWidth: 2)
                            )
                    )
                    .onSubmit {
                        checkAnswer()
                    }
                    .onChange(of: coordinator.answer) { _, _ in
                        coordinator.evaluateRealtime()
                    }
                
                if !coordinator.answer.isEmpty {
                    Button {
                        coordinator.answer = ""
                        coordinator.isCorrect = nil
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Theme.Colors.textSecondary)
                    }
                }
            }
        }
    }
    
    private var actionButtons: some View {
        HStack(spacing: Theme.Spacing.m) {
            Button {
                coordinator.goBack()
                shakeAmount = 0
            } label: {
                Text("Back")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(SecondaryButtonStyle())
            .disabled(coordinator.session.currentIndex == 0)
            
            Button {
                coordinator.advance()
                shakeAmount = 0
            } label: {
                Text("Next")
                    .frame(maxWidth: .infinity)
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
    
    private func borderColor() -> Color {
        if let isCorrect = coordinator.isCorrect {
            return isCorrect ? Theme.Colors.success : Theme.Colors.danger
        }
        return Theme.Colors.disabled
    }
    
    private func checkAnswer() {
        coordinator.evaluate()
        if coordinator.isCorrect == false {
            withAnimation {
                shakeAmount += 1
            }
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        } else if coordinator.isCorrect == true {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }
}

// MARK: - Summary View
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
            accuracyHeader
            tabSelector
            
            TabView(selection: $selectedTab) {
                overviewTab.tag(0)
                wordListTab(words: correctWords, isCorrect: true).tag(1)
                wordListTab(words: incorrectWords, isCorrect: false).tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            bottomButtons
        }
        .background(Theme.Colors.background)
    }
    
    private var accuracyHeader: some View {
        VStack(spacing: Theme.Spacing.m) {
            ZStack {
                Circle()
                    .stroke(Theme.Colors.disabled.opacity(0.3), lineWidth: 12)
                    .frame(width: 120, height: 120)
                
                Circle()
                    .trim(from: 0, to: Double(accuracy) / 100)
                    .stroke(
                        accuracy >= 80 ? Theme.Colors.success :
                        accuracy >= 50 ? Theme.Colors.warning :
                        Theme.Colors.danger,
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 4) {
                    Text("\(accuracy)%")
                        .font(.system(size: 36, weight: .bold))
                    Text("Accuracy")
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.Colors.textSecondary)
                }
            }
            
            Text(motivationalMessage())
                .font(Theme.Typography.title2)
        }
        .padding(.vertical, Theme.Spacing.l)
        .cardStyle()
        .padding(Theme.Spacing.m)
    }
    
    private var tabSelector: some View {
        HStack(spacing: 0) {
            ForEach(0..<3) { index in
                Button {
                    withAnimation {
                        selectedTab = index
                    }
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
        case 1: return "Correct (\(correctWords.count))"
        case 2: return "Review (\(incorrectWords.count))"
        default: return ""
        }
    }
    
    private var overviewTab: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.m) {
                HStack(spacing: Theme.Spacing.m) {
                    StatCard(
                        icon: "clock",
                        value: "\(coordinator.session.words.count)",
                        label: "Words Practiced",
                        color: Theme.Colors.primary
                    )
                    
                    StatCard(
                        icon: "checkmark.circle",
                        value: "\(correctWords.count)",
                        label: "Correct",
                        color: Theme.Colors.success
                    )
                }
                
                Spacer(minLength: 100)
            }
            .padding(Theme.Spacing.m)
        }
    }
    
    private func wordListTab(words: [Word], isCorrect: Bool) -> some View {
        ScrollView {
            if words.isEmpty {
                VStack(spacing: Theme.Spacing.m) {
                    Image(systemName: isCorrect ? "checkmark.circle" : "book.circle")
                        .font(.system(size: 48))
                        .foregroundColor(Theme.Colors.disabled)
                    
                    Text(isCorrect ? "No correct answers yet" : "Perfect! All answers were correct")
                        .font(Theme.Typography.body)
                        .foregroundColor(Theme.Colors.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, Theme.Spacing.xxl)
            } else {
                LazyVStack(spacing: Theme.Spacing.s) {
                    ForEach(words) { word in
                        WordReviewCard(
                            word: word,
                            direction: coordinator.session.configuration.direction,
                            isCorrect: isCorrect
                        )
                    }
                }
                .padding(Theme.Spacing.m)
            }
        }
    }
    
    private var bottomButtons: some View {
        VStack(spacing: Theme.Spacing.m) {
            Button {
                coordinator.reset()
            } label: {
                Text("Continue Learning")
            }
            .buttonStyle(PrimaryButtonStyle())
            
            if !incorrectWords.isEmpty {
                Button {
                    coordinator.reviewWords = incorrectWords
                    coordinator.stage = .setup
                } label: {
                    HStack {
                        Image(systemName: "arrow.triangle.2.circlepath")
                        Text("Review Mistakes (\(incorrectWords.count))")
                    }
                }
                .buttonStyle(SecondaryButtonStyle())
            }
        }
        .padding(Theme.Spacing.m)
        .background(Theme.Colors.card)
    }
    
    private func motivationalMessage() -> String {
        if accuracy >= 90 { return "Outstanding! 🌟" }
        else if accuracy >= 70 { return "Great job! 💪" }
        else if accuracy >= 50 { return "Good progress! 📈" }
        else { return "Keep practicing! 🎯" }
    }
}

// MARK: - Supporting Views
struct WordReviewCard: View {
    let word: Word
    let direction: QuizDirection
    let isCorrect: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(direction.sourceFlag)
                    Text(direction.isGermanToVietnamese ? word.displayGerman : word.displayVietnamese)
                        .font(Theme.Typography.headline)
                }
                
                HStack(spacing: 6) {
                    Text(direction.targetFlag)
                    Text(direction.isGermanToVietnamese ? word.displayVietnamese : word.displayGerman)
                        .font(Theme.Typography.body)
                        .foregroundColor(Theme.Colors.textSecondary)
                }
                
                // Category
                Text(word.category.title)
                    .font(Theme.Typography.caption2)
                    .foregroundColor(Theme.Colors.primary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(Theme.Colors.primary.opacity(0.1))
                    )
            }
            
            Spacer()
            
            Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(isCorrect ? Theme.Colors.success : Theme.Colors.danger)
        }
        .padding(Theme.Spacing.m)
        .background(Theme.Colors.card)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card))
    }
}

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
                        errorState
                    }
                }
                .padding(Theme.Spacing.m)
            }
            .navigationTitle(word.exampleSentence != nil ? "Example Sentence" : "No Sentence Available")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var wordReference: some View {
        VStack(spacing: Theme.Spacing.s) {
            Text("Word:")
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textSecondary)
            
            HStack(spacing: Theme.Spacing.m) {
                VStack {
                    Text(direction.sourceFlag)
                    Text(direction.isGermanToVietnamese ? word.displayGerman : word.displayVietnamese)
                        .font(Theme.Typography.headline)
                }
                
                Image(systemName: "arrow.right")
                    .foregroundColor(Theme.Colors.textSecondary)
                
                VStack {
                    Text(direction.targetFlag)
                    Text(direction.isGermanToVietnamese ? word.displayVietnamese : word.displayGerman)
                        .font(Theme.Typography.body)
                }
            }
            
            // Category
            HStack {
                Text(word.category.title)
                    .font(Theme.Typography.caption)
            }
            .padding(.horizontal, Theme.Spacing.s)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(Theme.Colors.primary.opacity(0.1))
            )
            .foregroundColor(Theme.Colors.primary)
        }
        .padding(Theme.Spacing.m)
        .background(Theme.Colors.primary.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.button))
    }
    
    private func sentenceDisplay(_ exampleSentence: ExampleSentence) -> some View {
        VStack(spacing: Theme.Spacing.m) {
            sentenceCard(
                flag: "🇩🇪",
                text: exampleSentence.german,
                label: "German"
            )
            
            sentenceCard(
                flag: "🇻🇳",
                text: exampleSentence.vietnamese,
                label: "Vietnamese"
            )
        }
    }
    
    private func sentenceCard(flag: String, text: String, label: String) -> some View {
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
    
    private var errorState: some View {
        VStack(spacing: Theme.Spacing.l) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(Theme.Colors.warning)
            
            Text("No example sentence available")
                .font(Theme.Typography.headline)
            
            Text("Looking for: \"\(word.displayGerman)\"")
                .font(.system(.caption, design: .monospaced))
                .padding(Theme.Spacing.s)
                .background(Theme.Colors.primary.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.small))
        }
        .padding(Theme.Spacing.m)
    }
}
