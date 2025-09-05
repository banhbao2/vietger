import SwiftUI

struct SwipeableQuizCard: View {
    let word: Word
    let direction: QuizDirection

    // State & feedback (controlled by parent)
    let reveal: Bool
    let isCorrect: Bool?
    let isLearned: Bool

    // Actions
    let onReveal: () -> Void
    let onSpeakSource: (String) -> Void
    let onSpeakTarget: (String) -> Void
    let onNext: () -> Void
    let onBack: () -> Void

    // Expected answers (for hints/reveal display, provided by parent)
    let expectedAnswers: [String]

    private var sourceText: String {
        direction.isGermanToVietnamese ? word.german : word.vietnamese
    }
    private var targetText: String {
        direction.isGermanToVietnamese ? word.vietnamese : word.german
    }

    private var sourceLangBadge: String { direction.isGermanToVietnamese ? "DE" : "VI" }
    private var targetLangBadge: String { direction.isGermanToVietnamese ? "VI" : "DE" }
    private var sourceLabelTitle: String { direction.isGermanToVietnamese ? "German" : "Vietnamese" }
    private var targetLabelTitle: String { direction.isGermanToVietnamese ? "Vietnamese" : "German" }

    var body: some View {
        ZStack {
            VStack(spacing: 14) {
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

                Text(sourceText)
                    .font(.title2).fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)

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
                        Button { onReveal() } label: {
                            Label("Reveal", systemImage: "eye")
                        }
                        .buttonStyle(.bordered)
                        .padding(.top, 6)
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(.thinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(isLearned ? Color.green.opacity(0.6) : Color.clear, lineWidth: 2)
            )
        }
    }
}
