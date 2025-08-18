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
                    correctIDs: vm.correctIDs,
                    openIDs: vm.openIDs,
                    onClose: { vm.resetToSetup() }
                )
                .environmentObject(appState)
            }
        }
        .navigationTitle("Quiz")
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
                    onReveal: { vm.reveal.toggle() },
                    onSpeakSource: { vm.speakSource($0) },
                    onSpeakTarget: { vm.speakTarget($0) },
                    onNext: { vm.advance() },
                    onBack: { vm.goBack() },
                    expectedAnswers: vm.expectedAnswers(for: word)
                )

                answerField(direction: dir)

                HStack {
                    Button("Back") { vm.goBack() }
                        .buttonStyle(.bordered)
                        .disabled(vm.currentIndex == 0)

                    if let w = vm.current, !vm.isCurrentLearned(w) {
                        Button("Mark as learned") {
                            vm.markAsLearned(w); vm.advance()
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
                .disabled(!vm.allSeen)
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
