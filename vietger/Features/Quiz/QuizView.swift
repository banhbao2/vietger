import SwiftUI

struct QuizView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var environment: AppEnvironment
    @StateObject private var viewModel: QuizSessionViewModel
    @State private var showSetup = true
    @State private var reviewWords: [Word]? = nil
    
    init() {
        _viewModel = StateObject(wrappedValue: QuizSessionViewModel())
    }
    
    var body: some View {
        ZStack {
            Theme.Colors.background
                .ignoresSafeArea()
            
            if showSetup {
                QuizSetupView(
                    reviewWords: reviewWords,
                    onStart: { config in
                        if let words = reviewWords {
                            viewModel.startReviewSession(with: config, words: words, appState: appState)
                        } else {
                            viewModel.startSession(with: config, appState: appState)
                        }
                        showSetup = false
                        reviewWords = nil
                    }
                )
            } else if viewModel.stage == .summary {
                QuizSummaryView(
                    session: viewModel.session,
                    onDismiss: {
                        showSetup = true
                        viewModel.reset()
                    },
                    onReviewMistakes: { mistakes in
                        reviewWords = mistakes
                        showSetup = true
                        viewModel.reset()
                    }
                )
            } else {
                QuizSessionView(viewModel: viewModel)
            }
        }
        .navigationTitle("Quiz")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if viewModel.appState == nil {
                viewModel.configure(appState: appState, environment: environment)
            }
        }
    }
}

struct QuizSessionView: View {
    @ObservedObject var viewModel: QuizSessionViewModel
    @State private var shakeAmount: CGFloat = 0
    @State private var showSentenceModal = false
    
    var body: some View {
        ZStack {
            VStack(spacing: Theme.Spacing.m) {
                QuizProgressHeader(viewModel: viewModel)
                    .padding(.horizontal)
                
                ScrollView {
                    VStack(spacing: Theme.Spacing.l) {
                        if let word = viewModel.currentWord {
                            QuizCard(
                                word: word,
                                direction: viewModel.session.configuration.direction,
                                reveal: viewModel.reveal,
                                isCorrect: viewModel.isCorrect,
                                isLearned: viewModel.isWordLearned(word),
                                onReveal: { viewModel.reveal = true },
                                onSpeakSource: { text in
                                    viewModel.speak(text, isSource: true)
                                },
                                onSpeakTarget: { text in
                                    viewModel.speak(text, isSource: false)
                                },
                                onShowSentence: {
                                    showSentenceModal = true
                                }
                            )
                            .shake(times: shakeAmount)
                            
                            answerField
                            actionButtons
                            
                            // Finish early button
                            Button {
                                viewModel.completeSession()
                            } label: {
                                HStack {
                                    Image(systemName: "flag.checkered")
                                    Text("Finish & Review")
                                }
                                .font(Theme.Typography.headline)
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
                    }
                    .padding(Theme.Spacing.m)
                }
            }
            
            // Example sentence modal overlay - Always show when button clicked
            if showSentenceModal, let word = viewModel.currentWord {
                ExampleSentenceModal(
                    word: word,
                    sentence: viewModel.getSentence(for: word),  // Can be nil
                    direction: viewModel.session.configuration.direction,
                    isPresented: $showSentenceModal
                )
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showSentenceModal)
            }
        }
    }
    
    private var answerField: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.s) {
            Text("Your answer")
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textSecondary)
            
            HStack {
                TextField("Type translation...", text: $viewModel.answer)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .submitLabel(.done)
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
                    .onChange(of: viewModel.answer) { _, newValue in
                        if !newValue.isEmpty {
                            viewModel.evaluateRealtime()
                        } else {
                            viewModel.isCorrect = nil
                        }
                    }
                
                if !viewModel.answer.isEmpty {
                    Button {
                        viewModel.answer = ""
                        viewModel.isCorrect = nil
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
                viewModel.goBack()
                shakeAmount = 0
            } label: {
                Text("Back")
            }
            .buttonStyle(SecondaryButtonStyle())
            .frame(width: 100)
            .disabled(viewModel.session.currentIndex == 0)
            
            if let word = viewModel.currentWord, !viewModel.isWordLearned(word) {
                Button {
                    viewModel.markAsLearned(word)
                } label: {
                    Label("Mark learned", systemImage: "checkmark.circle")
                        .labelStyle(.titleAndIcon)
                }
                .buttonStyle(SuccessButtonStyle())
            }
            
            Button {
                viewModel.advance()
                shakeAmount = 0
            } label: {
                Text("Next")
            }
            .buttonStyle(PrimaryButtonStyle())
            .frame(width: 100)
        }
    }
    
    private func borderColor() -> Color {
        if let isCorrect = viewModel.isCorrect {
            return isCorrect ? Theme.Colors.success : Theme.Colors.danger
        }
        return Theme.Colors.disabled
    }
    
    private func checkAnswer() {
        viewModel.evaluate()
        if viewModel.isCorrect == false {
            withAnimation(.default) {
                shakeAmount += 1
            }
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
        } else if viewModel.isCorrect == true {
            let notificationFeedback = UINotificationFeedbackGenerator()
            notificationFeedback.notificationOccurred(.success)
        }
    }
}
