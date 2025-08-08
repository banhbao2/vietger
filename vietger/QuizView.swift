import SwiftUI

enum QuizDirection: String, CaseIterable, Identifiable {
    case deToVi = "German → Vietnamese"
    case viToDe = "Vietnamese → German"
    var id: String { rawValue }
}

private enum QuizStage {
    case pickDirection
    case pickSize
    case inQuiz
    case summary
}

struct QuizView: View {
    @EnvironmentObject var appState: AppState

    // Flow
    @State private var stage: QuizStage = .pickDirection
    @State private var chosenDirection: QuizDirection? = nil

    // Session sizing
    @State private var presetSizes: [Int] = [5, 10, 25, 50, 100]
    @State private var selectedSize: Int? = nil
    @State private var customSize: String = ""

    // Quiz state
    @State private var sessionWords: [Word] = []
    @State private var currentIndex: Int = 0
    private var current: Word? { sessionWords.indices.contains(currentIndex) ? sessionWords[currentIndex] : nil }

    // Per-question UI
    @State private var answer: String = ""
    @State private var reveal: Bool = false
    @State private var isCorrect: Bool? = nil

    // Session tracking
    @State private var correctIDs: Set<String> = []
    @State private var openIDs: Set<String> = []

    var body: some View {
        if #available(iOS 17.0, *) {
            VStack {
                switch stage {
                case .pickDirection: directionPicker
                case .pickSize: sizePicker
                case .inQuiz: quizScreen
                case .summary: summaryScreen
                }
            }
            .navigationTitle("Quiz")
            .onChange(of: chosenDirection) { _, new in
                if new != nil { stage = .pickSize }
            }
        } else {
            // Fallback on earlier versions
        }
    }

    // MARK: - Direction picker

    private var directionPicker: some View {
        VStack(spacing: 20) {
            Text("Choose direction").font(.title2).bold().padding(.top)

            Button { chosenDirection = .deToVi } label: {
                rowCard(label: "🇩🇪 → 🇻🇳  German → Vietnamese")
            }

            Button { chosenDirection = .viToDe } label: {
                rowCard(label: "🇻🇳 → 🇩🇪  Vietnamese → German")
            }

            Spacer()
        }
        .padding()
    }

    // MARK: - Size picker

    private var sizePicker: some View {
        VStack(spacing: 16) {
            Text("How many words?").font(.title2).bold().padding(.top)

            // Presets
            ForEach(presetSizes, id: \.self) { n in
                Button {
                    selectedSize = n
                    startSession()
                } label: {
                    rowCard(label: "\(n) words")
                }
            }

            // Custom
            VStack(spacing: 10) {
                HStack { Text("Custom"); Spacer() }
                HStack {
                    TextField("Number", text: $customSize)
                        .keyboardType(.numberPad)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .padding(12)
                        .background(Color.gray.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                    Button("Start") {
                        let n = Int(customSize) ?? 0
                        selectedSize = max(1, n)
                        startSession()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(Int(customSize) ?? 0 <= 0)
                }
            }
            .padding(.top, 8)

            Button("Back") {
                chosenDirection = nil
                stage = .pickDirection
            }
            .buttonStyle(.bordered)

            Spacer()
        }
        .padding()
    }

    // MARK: - Quiz

    private var quizScreen: some View {
        VStack(spacing: 16) {
            // Progress header
            HStack {
                Text("Word \(min(currentIndex + 1, sessionWords.count))/\(sessionWords.count)")
                    .font(.subheadline).foregroundStyle(.secondary)
                Spacer()
            }

            if let word = current, let direction = chosenDirection {
                // Tap-to-reveal card
                Button {
                    withAnimation(.spring) { reveal.toggle() }
                } label: {
                    VStack(spacing: 8) {
                        Text(prompt(for: word, direction: direction))
                            .font(.title).bold()
                            .multilineTextAlignment(.center)

                        if reveal {
                            // 👇 show ALL acceptable answers joined with " / "
                            Text("→ \(expectedAnswers(for: word, direction: direction).joined(separator: " / "))")
                                .font(.title3)
                                .transition(.opacity.combined(with: .move(edge: .bottom)))
                                .foregroundStyle(isCorrect == true ? .green : .primary)
                        } else {
                            Text("Tap to reveal")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .padding(.top, 6)
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 160)
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                .buttonStyle(.plain)

                // Answer field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Type your answer").font(.caption).foregroundStyle(.secondary)

                    TextField("Enter translation…", text: $answer)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .submitLabel(.done)
                        .padding()
                        .background(Color.gray.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .onSubmit { evaluate(direction: direction) }
                        .onChange(of: answer) { _, _ in evaluate(direction: direction, auto: true) }

                    if let flag = isCorrect {
                        HStack(spacing: 6) {
                            Image(systemName: flag ? "checkmark.circle.fill" : "xmark.circle.fill")
                            Text(flag ? "Correct! Marked as learned." :
                                 "Not quite — tap to reveal or skip")
                        }
                        .font(.subheadline)
                        .foregroundStyle(flag ? .green : .red)
                        .transition(.opacity)
                    }
                }

                // Controls
                HStack {
                    if !isCurrentLearned(word) {
                        Button("Mark as learned") {
                            markAsLearned(word)
                            advance()
                        }
                        .buttonStyle(.borderedProminent)
                    }

                    Button("Next") {
                        advance()
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.top, 8)
            } else {
                ProgressView()
            }

            Spacer()
        }
        .padding()
    }

    // MARK: - Summary

    private var summaryScreen: some View {
        let correctWords = sessionWords.filter { correctIDs.contains($0.id) }
        let openWords = sessionWords.filter { openIDs.contains($0.id) }

        return ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Session summary").font(.title2).bold()

                HStack {
                    summaryStat(title: "Correct", value: correctWords.count, color: .green)
                    summaryStat(title: "Open", value: openWords.count, color: .orange)
                }

                if !correctWords.isEmpty {
                    Text("✅ Correct").font(.headline).padding(.top, 8)
                    ForEach(correctWords) { w in
                        summaryRow(left: w.german, right: w.vietnamese) // display primary strings
                    }
                }

                if !openWords.isEmpty {
                    Text("🟠 Open").font(.headline).padding(.top, 8)
                    ForEach(openWords) { w in
                        summaryRow(left: w.german, right: w.vietnamese)
                    }
                }

                // Close button
                NavigationLink(destination: ContentView().environmentObject(appState)) {
                    Text("Close quiz")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .bold()
                        .background(.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.top, 20)
                }

                Spacer(minLength: 20)
            }
            .padding()
        }
    }

    // MARK: - Helpers

    private func rowCard(label: String) -> some View {
        HStack {
            Text(label).font(.headline)
            Spacer()
            Image(systemName: "chevron.right")
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func summaryStat(title: String, value: Int, color: Color) -> some View {
        VStack {
            Text("\(value)").font(.title2).bold().foregroundStyle(color)
            Text(title).font(.caption)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func summaryRow(left: String, right: String) -> some View {
        HStack {
            Text(left).bold()
            Spacer()
            Text(right).foregroundStyle(.secondary)
        }
        .padding(10)
        .background(Color.gray.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func prompt(for w: Word, direction: QuizDirection) -> String {
        // 👈 uses allGerman/allVietnamese
        direction == .deToVi ? (w.allGerman.first ?? "") : (w.allVietnamese.first ?? "")
    }

    // Returns ALL acceptable answers for the target side (for checking and reveal)
    private func expectedAnswers(for w: Word, direction: QuizDirection) -> [String] {
        // 👈 uses allGerman/allVietnamese
        direction == .deToVi ? w.allVietnamese : w.allGerman
    }

    private func normalize(_ s: String) -> String {
        s.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    private func isCurrentLearned(_ word: Word) -> Bool {
        appState.learnedIDs.contains(word.id) || correctIDs.contains(word.id)
    }

    private func markAsLearned(_ word: Word) {
        appState.markLearned(word)
        correctIDs.insert(word.id)
        openIDs.remove(word.id)
        isCorrect = true
        reveal = true
    }

    private func evaluate(direction: QuizDirection, auto: Bool = false) {
        guard let word = current else { return }
        let answers = expectedAnswers(for: word, direction: direction).map(normalize)
        let ok = answers.contains(normalize(answer))

        if ok {
            withAnimation(.spring) {
                isCorrect = true
                reveal = true
            }
            // Count as correct + persist
            markAsLearned(word)
        } else if !auto {
            withAnimation { isCorrect = false }
        }
    }

    private func advance() {
        // Classify current word if not already correct
        if let word = current, !correctIDs.contains(word.id) {
            openIDs.insert(word.id)
        }
        // Next item or finish
        let next = currentIndex + 1
        if next >= sessionWords.count {
            stage = .summary
        } else {
            currentIndex = next
            resetQuestionUI()
        }
    }

    private func resetQuestionUI() {
        answer = ""
        reveal = false
        isCorrect = nil
    }

    private func startSession() {
        // Build a random subset of UNLEARNED words
        let pool = appState.unlearnedWords.shuffled()
        let requested = selectedSize ?? 10
        let count = max(1, min(requested, pool.count))
        sessionWords = Array(pool.prefix(count))

        correctIDs.removeAll()
        openIDs.removeAll()
        currentIndex = 0
        resetQuestionUI()

        stage = .inQuiz
    }
}

#Preview {
    let state = AppState()
    return NavigationStack { QuizView().environmentObject(state) }
}
