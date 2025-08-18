import SwiftUI

struct SwipeableQuizCard: View {
    let word: Word
    let direction: QuizDirection

    // State & feedback (controlled by parent)
    let reveal: Bool
    let isCorrect: Bool?
    let isLearned: Bool        // drives outline + badge + bounce

    // Actions
    let onReveal: () -> Void
    let onSpeakSource: (String) -> Void
    let onSpeakTarget: (String) -> Void
    let onNext: () -> Void
    let onBack: () -> Void

    // Expected answers (for hints/reveal display, provided by parent)
    let expectedAnswers: [String]

    private var sourceText: String {
        switch direction {
        case .deToVi: return word.german
        case .viToDe: return word.vietnamese
        }
    }
    private var targetText: String {
        switch direction {
        case .deToVi: return word.vietnamese
        case .viToDe: return word.german
        }
    }

    private var sourceLangBadge: String { direction == .deToVi ? "DE" : "VI" }
    private var targetLangBadge: String { direction == .deToVi ? "VI" : "DE" }
    private var sourceLabelTitle: String { direction == .deToVi ? "German" : "Vietnamese" }
    private var targetLabelTitle: String { direction == .deToVi ? "Vietnamese" : "German" }

    var body: some View {
        ZStack {
            // Card content
            VStack(spacing: 14) {
                // HEADER: Source label + (right) speaker
                HStack(spacing: 10) {
                    Text(sourceLabelTitle)
                        .font(.footnote).fontWeight(.semibold)
                        .foregroundStyle(.secondary)

                    Spacer()

                    Button {
                        onSpeakSource(sourceText)
                    } label: {
                        Label("Play \(sourceLangBadge)", systemImage: "speaker.wave.2.fill")
                            .labelStyle(.iconOnly)
                            .padding(8)
                            .background(Capsule().fill(Color.gray.opacity(0.12)))
                    }
                    .accessibilityLabel("Play \(sourceLangBadge) pronunciation")
                }

                // SOURCE TEXT
                Text(sourceText)
                    .font(.title2).fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)

                // REVEAL AREA
                Group {
                    if reveal {
                        Divider().padding(.vertical, 4)

                        HStack(spacing: 10) {
                            Text(targetLabelTitle)
                                .font(.footnote).fontWeight(.semibold)
                                .foregroundStyle(.secondary)

                            Spacer()

                            Button {
                                onSpeakTarget(targetText)
                            } label: {
                                Label("Play \(targetLangBadge)", systemImage: "speaker.wave.2.fill")
                                    .labelStyle(.iconOnly)
                                    .padding(8)
                                    .background(Capsule().fill(Color.gray.opacity(0.12)))
                            }
                            .accessibilityLabel("Play \(targetLangBadge) pronunciation")
                        }

                        Text(targetText)
                            .font(.title3)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    } else {
                        Button {
                            onReveal()
                        } label: {
                            Label("Reveal", systemImage: "eye")
                        }
                        .buttonStyle(.bordered)
                        .padding(.top, 6)
                        .accessibilityHint("Shows the translation and enables its speaker button")
                    }
                }

                // FOOTER FEEDBACK
                if let isCorrect {
                    HStack(spacing: 6) {
                        Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                        Text(isCorrect ? "Correct" : "Try again")
                    }
                    .foregroundStyle(isCorrect ? .green : .red)
                    .font(.subheadline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 4)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                // Outline animates to green when learned
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(isLearned ? Color.green : Color.clear, lineWidth: 2)
            )
            // 🔹 Bounce the whole card subtly when it becomes learned
            .scaleEffect(isLearned ? 1.02 : 1.0)
            .animation(.spring(response: 0.28, dampingFraction: 0.62, blendDuration: 0.2), value: isLearned)

            // Learned badge at TOP-LEFT (won't clash with TTS on the right)
            if isLearned {
                VStack {
                    HStack {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.seal.fill")
                            Text("Learned").fontWeight(.semibold)
                        }
                        .font(.caption2)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(Color.green.opacity(0.15)))
                        .foregroundStyle(.green)
                        .accessibilityLabel("Word learned")
                        .transition(.scale.combined(with: .opacity)) // 🔹 appear nicely

                        Spacer()
                    }
                    Spacer()
                }
                .padding(10)
                .allowsHitTesting(false) // never intercept taps
                // 🔹 bounce the badge too
                .scaleEffect(isLearned ? 1.06 : 1.0)
                .animation(.spring(response: 0.28, dampingFraction: 0.62, blendDuration: 0.2), value: isLearned)
            }
        }
    }
}
