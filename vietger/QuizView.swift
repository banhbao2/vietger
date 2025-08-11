import SwiftUI
import AVFoundation

enum QuizStage { case pickDirection, pickSize, inQuiz, summary }

struct QuizView: View {
    @EnvironmentObject var appState: AppState
    @State private var stage: QuizStage = .pickDirection
    @State private var chosenDirection: QuizDirection?
    
    @State private var presetSizes = [5, 10, 25, 50, 100]
    @State private var selectedSize: Int?
    @State private var customSize = ""
    
    @State private var sessionWords: [Word] = []
    @State private var currentIndex = 0
    private var current: Word? { sessionWords.indices.contains(currentIndex) ? sessionWords[currentIndex] : nil }
    
    @State private var answer = ""
    @State private var reveal = false
    @State private var isCorrect: Bool?
    
    @State private var correctIDs = Set<String>()
    @State private var openIDs = Set<String>()
    
    // NEW: track which words have been seen at least once (by ID)
    @State private var seenIDs = Set<String>()
    private var allSeen: Bool { !sessionWords.isEmpty && seenIDs.count == sessionWords.count }
    
    @State private var showWordList = false
    
    private let speechSynth = AVSpeechSynthesizer()
    
    var body: some View {
        VStack {
            switch stage {
            case .pickDirection:
                DirectionPicker(selected: $chosenDirection) {
                    stage = .pickSize
                }
            case .pickSize:
                SizePicker(
                    customSize: $customSize,
                    stage: $stage,
                    onPick: { n in startSession(size: n) }
                )
            case .inQuiz:
                quizScreen
            case .summary:
                SummaryView(
                    sessionWords: sessionWords,
                    correctIDs: correctIDs,
                    openIDs: openIDs,
                    onClose: { stage = .pickDirection } // reset flow when done
                )
                .environmentObject(appState)
            }
        }
        .navigationTitle("Quiz")
        .sheet(isPresented: $showWordList) { wordListSheet }
        // Ensure the very first card counts as "seen"
        .onChange(of: stage) { _, newValue in
            if newValue == .inQuiz, let cur = current { markSeen(cur) }
        }
    }
}


// MARK: - Quiz Screen
private extension QuizView {
    var quizScreen: some View {
        VStack(spacing: 16) {
            HStack {
                Spacer()
                Text("Word \(currentIndex + 1)/\(sessionWords.count)")
                    .font(.subheadline).foregroundStyle(.secondary)
                Spacer()
                Button(action: { showWordList = true }) {
                    Image(systemName: "list.bullet")
                }
                .accessibilityLabel("Open word list")
            }
            .padding(.horizontal)
            
            if let word = current, let direction = chosenDirection {
                
                SwipeableQuizCard(
                    word: word,
                    direction: direction,
                    reveal: reveal,
                    isCorrect: isCorrect,
                    onReveal: { reveal.toggle() },
                    onSpeak: { speakGerman($0) },
                    onNext: { advance() },
                    onBack: { goBack() },
                    expectedAnswers: expectedAnswers(for: word, direction: direction)
                )
                // Count as seen whenever this view re-renders for this word
                .onAppear { markSeen(word) }
                
                // Small hint about finishing

                
                answerField(direction: direction)
                
                HStack {
                    Button("Back") { goBack() }
                        .buttonStyle(.bordered)
                        .disabled(currentIndex == 0)
                    
                    if !isCurrentLearned(word) {
                        Button("Mark as learned") {
                            markAsLearned(word)
                            advance()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    
                    Button("Next") { advance() }
                        .buttonStyle(.bordered)
                }
                .padding(.top, 8)
                
                // NEW: Separate finish action; only enabled when allSeen
                Button {
                    stage = .summary
                } label: {
                    Label("Finish & Review", systemImage: "checkmark.circle.fill")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(!allSeen)
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
            TextField("Enter translation…", text: $answer)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .submitLabel(.done)
                .padding()
                .background(Color.gray.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .onSubmit { evaluate(direction: direction) }
                .onChange(of: answer) { _, _ in evaluate(direction: direction, auto: true) }
        }
    }
}

// MARK: - Word List Sheet
private extension QuizView {
    var wordListSheet: some View {
        NavigationStack {
            List(sessionWords.indices, id: \.self) { idx in
                let w = sessionWords[idx]
                let displayText = chosenDirection == .deToVi ? w.german : w.vietnamese
                
                HStack {
                    Text(displayText)
                        .foregroundColor(seenIDs.contains(w.id) ? .primary : .secondary.opacity(0.5))
                    Spacer()
                    if correctIDs.contains(w.id) {
                        Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                    } else if openIDs.contains(w.id) || idx < currentIndex {
                        Image(systemName: "circle.fill").foregroundColor(.orange)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    currentIndex = idx
                    markSeen(sessionWords[idx]) // NEW: mark as seen when jumping via list
                    showWordList = false
                    resetQuestionUI()
                }
            }
            .navigationTitle("Quiz Words")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { showWordList = false }
                }
            }
        }
    }
}

// MARK: - Actions & Helpers
private extension QuizView {
    func startSession(size: Int) {
        let pool = appState.unlearnedWords.shuffled()
        sessionWords = Array(pool.prefix(max(1, min(size, pool.count))))
        currentIndex = 0
        correctIDs.removeAll()
        openIDs.removeAll()
        seenIDs.removeAll()             // NEW: reset seen
        resetQuestionUI()
        stage = .inQuiz
        if let cur = current { markSeen(cur) } // count first word as seen
    }
    
    func advance() {
        // If leaving a word unlearned, mark as open
        if let word = current, !correctIDs.contains(word.id) {
            openIDs.insert(word.id)
        }
        
        // Move forward if possible
        if currentIndex + 1 < sessionWords.count {
            currentIndex += 1
            if let cur = current { markSeen(cur) } // NEW: mark new word as seen
            resetQuestionUI()
        } else {
            // We're at the last index. Do NOT auto-finish.
            // If some words are unseen, jump to the first unseen to force coverage.
            if let idx = sessionWords.firstIndex(where: { !seenIDs.contains($0.id) }) {
                currentIndex = idx
                if let cur = current { markSeen(cur) }
                resetQuestionUI()
            } else {
                // All seen: stay on last card; user must tap the Finish button.
            }
        }
    }
    
    func goBack() {
        if currentIndex > 0 {
            currentIndex -= 1
            if let cur = current { markSeen(cur) } // harmless if already seen
            resetQuestionUI()
        }
    }
    
    func resetQuestionUI() {
        answer = ""; reveal = false; isCorrect = nil
    }
    
    func evaluate(direction: QuizDirection, auto: Bool = false) {
        guard let word = current else { return }
        let answers = expectedAnswers(for: word, direction: direction).map(normalize)
        if answers.contains(normalize(answer)) {
            isCorrect = true; reveal = true; markAsLearned(word)
        } else if !auto { isCorrect = false }
    }
    
    func expectedAnswers(for w: Word, direction: QuizDirection) -> [String] {
        direction == .deToVi ? w.allVietnamese : w.allGerman
    }
    
    func normalize(_ s: String) -> String {
        s.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
    
    func isCurrentLearned(_ word: Word) -> Bool {
        appState.learnedIDs.contains(word.id) || correctIDs.contains(word.id)
    }
    
    func markAsLearned(_ word: Word) {
        appState.markLearned(word)
        correctIDs.insert(word.id)
        openIDs.remove(word.id)
    }
    
    func speakGerman(_ text: String) {
        let voice = AVSpeechSynthesisVoice(language: "de-DE") ?? AVSpeechSynthesisVoice(language: "en-US")
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = voice
        utterance.rate = 0.45
        speechSynth.speak(utterance)
    }
    
    // NEW: seen tracking
    func markSeen(_ word: Word) {
        seenIDs.insert(word.id)
    }
}

// MARK: - UI Components still used here
private extension QuizView {
    func rowCard(label: String) -> some View {
        HStack { Text(label).font(.headline); Spacer(); Image(systemName: "chevron.right") }
            .padding().background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    NavigationStack { QuizView().environmentObject(AppState()) }
}
