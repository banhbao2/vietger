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
                    onPick: { n in startSession(size: n) }  // ✅ Linking the start
                )
            case .inQuiz: quizScreen
            case .summary: summaryScreen
            }
        }
        .navigationTitle("Quiz")
        .sheet(isPresented: $showWordList) { wordListSheet }
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
                        .foregroundColor(idx <= currentIndex ? .primary : .secondary.opacity(0.5))
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
                    showWordList = false
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

// MARK: - Summary
private extension QuizView {
    var summaryScreen: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                let correctWords = sessionWords.filter { correctIDs.contains($0.id) }
                let openWords = sessionWords.filter { openIDs.contains($0.id) }
                Text("Session summary").font(.title2).bold()
                HStack {
                    summaryStat(title: "Correct", value: correctWords.count, color: .green)
                    summaryStat(title: "Open", value: openWords.count, color: .orange)
                }
                if !correctWords.isEmpty {
                    Text("✅ Correct").font(.headline)
                    ForEach(correctWords) { w in summaryRow(left: w.german, right: w.vietnamese) }
                }
                if !openWords.isEmpty {
                    Text("🟠 Open").font(.headline)
                    ForEach(openWords) { w in summaryRow(left: w.german, right: w.vietnamese) }
                }
                NavigationLink(destination: ContentView().environmentObject(appState)) {
                    Text("Close quiz")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .bold()
                        .background(.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
            .padding()
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
        resetQuestionUI()
        stage = .inQuiz
    }
    
    func advance() {
        if let word = current, !correctIDs.contains(word.id) { openIDs.insert(word.id) }
        if currentIndex + 1 >= sessionWords.count { stage = .summary }
        else { currentIndex += 1; resetQuestionUI() }
    }
    
    func goBack() {
        if currentIndex > 0 { currentIndex -= 1; resetQuestionUI() }
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
}

// MARK: - UI Components
private extension QuizView {
    func rowCard(label: String) -> some View {
        HStack { Text(label).font(.headline); Spacer(); Image(systemName: "chevron.right") }
            .padding().background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    func summaryStat(title: String, value: Int, color: Color) -> some View {
        VStack { Text("\(value)").font(.title2).bold().foregroundStyle(color); Text(title).font(.caption) }
            .frame(maxWidth: .infinity).padding()
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    func summaryRow(left: String, right: String) -> some View {
        HStack { Text(left).bold(); Spacer(); Text(right).foregroundStyle(.secondary) }
            .padding(10).background(Color.gray.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    NavigationStack { QuizView().environmentObject(AppState()) }
}
