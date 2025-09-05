import SwiftUI

struct QuizView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var vm = QuizViewModel()

    var body: some View {
        VStack {
            switch vm.stage {
            case .setup:
                QuizSetupView(vm: vm)

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
        .navigationBarBackButtonHidden(vm.stage == .inQuiz)
        .background(ScopedPopGestureGuard(disabled: vm.stage == .inQuiz))
        .onAppear { vm.configure(appState: appState) }
    }
}

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

                    if vm.chosenDeck == .core && !vm.isCurrentLearned(word) {
                        Button("Mark as learned") {
                            vm.evaluate(auto: true)
                            vm.correctIDs.insert(word.id)
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
                .buttonStyle(.borderedProminent)
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

// (Pop gesture helper unchanged)
import UIKit
struct ScopedPopGestureGuard: UIViewControllerRepresentable {
    var disabled: Bool
    func makeUIViewController(context: Context) -> Controller { Controller(disabled: disabled) }
    func updateUIViewController(_ uiViewController: Controller, context: Context) { uiViewController.apply(disabled: disabled) }
    final class Controller: UIViewController {
        private var storedWasEnabled: Bool?
        private var currentDisabled: Bool
        init(disabled: Bool) { self.currentDisabled = disabled; super.init(nibName: nil, bundle: nil) }
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
            nc.interactivePopGestureRecognizer?.isEnabled = !disabled
        }
    }
}
