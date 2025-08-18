import SwiftUI

struct SwipeableQuizCard: View {
    let word: Word
    let direction: QuizDirection

    // State & feedback (controlled by parent)
    let reveal: Bool
    let isCorrect: Bool?

    // Actions
    let onReveal: () -> Void
    let onSpeakSource: (String) -> Void       // plays source language
    let onSpeakTarget: (String) -> Void       // plays target language
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

    private var sourceLangBadge: String {
        switch direction {
        case .deToVi: return "DE"
        case .viToDe: return "VI"
        }
    }

    private var targetLangBadge: String {
        switch direction {
        case .deToVi: return "VI"
        case .viToDe: return "DE"
        }
    }

    var body: some View {
        VStack(spacing: 14) {
            // HEADER ROW: Source label + speaker
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

            // FOOTER: helper hint or correctness
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
    }

    private var sourceLabelTitle: String {
        switch direction {
        case .deToVi: return "German"
        case .viToDe: return "Vietnamese"
        }
    }

    private var targetLabelTitle: String {
        switch direction {
        case .deToVi: return "Vietnamese"
        case .viToDe: return "German"
        }
    }
}
