import SwiftUI

struct QuizView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var vm = QuizViewModel()

    var body: some View {
        VStack {
            switch vm.stage {
            case .setup:
                QuizSetupView(
                    chosenDirection: $vm.chosenDirection,
                    selectedSize: $vm.selectedSize,
                    customSize: $vm.customSize,
                    canStart: vm.canStart,
                    onStart: { vm.startSession() }
                )

            case .inQuiz:
                quizScreen

            case .summary:
                SummaryView(
                    sessionWords: vm.sessionWords,
                    correctIDs: vm.correctIDs
                )
                .environmentObject(appState)

            }
        }
        .navigationTitle("Quiz")
        // HIDE the nav bar back button ONLY during the quiz
        .navigationBarBackButtonHidden(vm.stage == .inQuiz)
        // DISABLE edge-swipe-to-go-back ONLY during the quiz
        .background(ScopedPopGestureGuard(disabled: vm.stage == .inQuiz))
        .onAppear { vm.configure(appState: appState) }
    }
}

// MARK: - Quiz Screen
private extension QuizView {
    var quizScreen: some View {
        VStack(spacing: 16) {
            QuizProgressHeader(
                progress: vm.progressFraction,
                currentIndex: vm.currentIndex,
                total: vm.totalCount,
                correctCount: vm.correctIDs.count
            )

            if let word = vm.current, let dir = vm.chosenDirection {
                SwipeableQuizCard(
                    word: word,
                    direction: dir,
                    reveal: vm.reveal,
                    isCorrect: vm.isCorrect,
                    isLearned: vm.isCurrentLearned(word),
                    onReveal: { vm.reveal.toggle() },
                    onSpeakSource: { vm.speakSource($0) },
                    onSpeakTarget: { vm.speakTarget($0) },
                    onNext: { vm.advance() },
                    onBack: { vm.goBack() },
                    expectedAnswers: vm.expectedAnswers(for: word)
                )

                answerField(direction: dir)

                HStack(spacing: 10) {
                    Button("Back") { vm.goBack() }
                        .buttonStyle(.bordered)
                        .disabled(vm.currentIndex == 0)

                    if !vm.isCurrentLearned(word) {
                        Button("Mark as learned") {
                            vm.markAsLearned(word)
                            withAnimation(.spring(response: 0.28, dampingFraction: 0.62)) {
                                vm.reveal = true
                            }
#if os(iOS)
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
#endif
                        }
                        .buttonStyle(.borderedProminent)
                    }

                    Button("Next") { vm.advance() }
                        .buttonStyle(.bordered)
                }
                .padding(.top, 8)

                Button {
                    vm.stage = .summary
                } label: {
                    Label("Finish & Review", systemImage: "checkmark.circle.fill")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)   // ← always enabled now
                .padding(.top, 4)
            } else {
                ProgressView()
            }

            Spacer()
        }
        .padding()
    }

    func answerField(direction: QuizDirection) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Type your answer").font(.caption).foregroundStyle(.secondary)
            TextField("Enter translation…", text: $vm.answer)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .submitLabel(.done)
                .padding()
                .background(Color.gray.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .onSubmit { vm.evaluate() }
                .onChange(of: vm.answer) { _, _ in vm.evaluate(auto: true) }
        }
    }
}

#Preview {
    NavigationStack {
        QuizView().environmentObject(AppState())
    }
}

// MARK: - Scoped pop-gesture guard (local to this file)
import UIKit
struct ScopedPopGestureGuard: UIViewControllerRepresentable {
    /// When true, disables interactive pop; when false, restores previous value.
    var disabled: Bool

    func makeUIViewController(context: Context) -> Controller {
        Controller(disabled: disabled)
    }

    func updateUIViewController(_ uiViewController: Controller, context: Context) {
        uiViewController.apply(disabled: disabled)
    }

    final class Controller: UIViewController {
        private var storedWasEnabled: Bool?
        private var currentDisabled: Bool

        init(disabled: Bool) {
            self.currentDisabled = disabled
            super.init(nibName: nil, bundle: nil)
        }
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            guard let nc = navigationController else { return }
            storedWasEnabled = nc.interactivePopGestureRecognizer?.isEnabled
            apply(disabled: currentDisabled)
        }

        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            if let nc = navigationController, let prev = storedWasEnabled {
                nc.interactivePopGestureRecognizer?.isEnabled = prev
            }
            storedWasEnabled = nil
        }

        func apply(disabled: Bool) {
            currentDisabled = disabled
            guard let nc = navigationController else { return }
            if disabled {
                nc.interactivePopGestureRecognizer?.isEnabled = false
            } else {
                nc.interactivePopGestureRecognizer?.isEnabled = storedWasEnabled ?? true
            }
        }
    }
}
