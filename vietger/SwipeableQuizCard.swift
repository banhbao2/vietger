import SwiftUI
import AVFoundation

struct SwipeableQuizCard: View {
    let word: Word
    let direction: QuizDirection
    let reveal: Bool
    let isCorrect: Bool?
    let onReveal: () -> Void
    let onSpeak: (String) -> Void
    let onNext: () -> Void
    let onBack: () -> Void
    let expectedAnswers: [String]
    
    @State private var offset: CGSize = .zero
    @GestureState private var dragOffset: CGSize = .zero
    @State private var rotation: Double = 0
    
    var body: some View {
        VStack(spacing: 8) {
            Text(prompt(for: word, direction: direction))
                .font(.title).bold()
            
            if reveal {
                Text("→ \(expectedAnswers.joined(separator: " / "))")
                    .font(.title3)
                    .foregroundStyle(isCorrect == true ? .green : .primary)
                
                Button {
                    onSpeak(word.allGerman.first ?? "")
                } label: {
                    Label("Hear German", systemImage: "speaker.wave.2.fill")
                }
            } else {
                Text("Tap to reveal").font(.caption).foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 160)
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .offset(x: offset.width + dragOffset.width, y: 0)
        .rotationEffect(.degrees(rotation))
        .animation(.spring(), value: offset)
        .onTapGesture { withAnimation { onReveal() } }
        .gesture(
            DragGesture()
                .updating($dragOffset) { value, state, _ in
                    state = value.translation
                    rotation = Double(value.translation.width / 20)
                }
                .onEnded { value in
                    let horizontalAmount = value.translation.width
                    let swipeThreshold: CGFloat = 100
                    
                    if horizontalAmount < -swipeThreshold {
                        withAnimation(.spring()) {
                            offset.width = -1000
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            onNext()
                            resetCardPosition()
                        }
                    } else if horizontalAmount > swipeThreshold {
                        withAnimation(.spring()) {
                            offset.width = 1000
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            onBack()
                            resetCardPosition()
                        }
                    } else {
                        withAnimation(.spring()) {
                            resetCardPosition()
                        }
                    }
                }
        )
    }
    
    private func resetCardPosition() {
        offset = .zero
        rotation = 0
    }
    
    private func prompt(for w: Word, direction: QuizDirection) -> String {
        direction == .deToVi ? (w.allGerman.first ?? "") : (w.allVietnamese.first ?? "")
    }
}
