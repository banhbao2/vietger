import SwiftUI

struct QuizProgressHeader: View {
    @ObservedObject var viewModel: QuizSessionViewModel
    
    private var accuracy: Int {
        let total = viewModel.session.seenIDs.count
        let correct = viewModel.session.correctIDs.count
        guard total > 0 else { return 0 }
        return Int((Double(correct) / Double(total)) * 100)
    }
    
    var body: some View {
        VStack(spacing: Theme.Spacing.s) {
            LinearProgress(progress: viewModel.session.progress)
            
            HStack {
                Label("\(viewModel.session.currentIndex + 1)/\(viewModel.session.words.count)",
                      systemImage: "doc.text")
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
                
                Spacer()
                
                HStack(spacing: Theme.Spacing.m) {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Theme.Colors.success)
                            .font(.system(size: 14))
                        Text("\(viewModel.session.correctIDs.count)")
                            .font(Theme.Typography.caption)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "target")
                            .foregroundColor(Theme.Colors.primary)
                            .font(.system(size: 14))
                        Text("\(accuracy)%")
                            .font(Theme.Typography.caption)
                    }
                }
            }
        }
        .cardStyle()
    }
}

struct QuizCard: View {
    let word: Word
    let direction: QuizDirection
    let reveal: Bool
    let isCorrect: Bool?
    let isLearned: Bool
    let onReveal: () -> Void
    let onSpeakSource: (String) -> Void
    let onSpeakTarget: (String) -> Void
    let onShowSentence: () -> Void
    
    private var sourceText: String {
        direction.isGermanToVietnamese ? word.german : word.vietnamese
    }
    
    private var targetText: String {
        direction.isGermanToVietnamese ? word.vietnamese : word.german
    }
    
    var body: some View {
        VStack(spacing: Theme.Spacing.m) {
            // Source card - More compact design
            VStack(spacing: Theme.Spacing.s) {
                HStack {
                    Text(direction.sourceFlag)
                        .font(.system(size: 24))
                    
                    Spacer()
                    
                    if isLearned {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(Theme.Colors.success)
                            .font(.system(size: 18))
                    }
                    
                    Button {
                        onSpeakSource(sourceText)
                    } label: {
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.system(size: 18))
                            .foregroundColor(Theme.Colors.primary)
                            .padding(6)
                            .background(
                                Circle()
                                    .fill(Theme.Colors.primary.opacity(0.1))
                            )
                    }
                }
                
                Text(sourceText)
                    .font(.system(size: 32, weight: .semibold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Theme.Spacing.m)
            }
            .padding(Theme.Spacing.m)
            .background(Theme.Colors.card)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.card)
                    .stroke(borderColor(), lineWidth: 2)
            )
            .shadow(color: Theme.Shadow.subtle.color, radius: Theme.Shadow.subtle.radius, y: Theme.Shadow.subtle.y)
            
            // Target (revealed or reveal button)
            if reveal {
                VStack(spacing: Theme.Spacing.s) {
                    HStack {
                        Text(direction.targetFlag)
                            .font(.system(size: 20))
                        
                        Spacer()
                        
                        HStack(spacing: Theme.Spacing.s) {
                            // Example sentence button - ALWAYS VISIBLE
                            Button {
                                onShowSentence()
                            } label: {
                                Image(systemName: "text.quote")
                                    .font(.system(size: 16))
                                    .foregroundColor(Theme.Colors.primary)
                                    .padding(6)
                                    .background(
                                        Circle()
                                            .stroke(Theme.Colors.primary.opacity(0.3), lineWidth: 1)
                                    )
                            }
                            
                            Button {
                                onSpeakTarget(targetText)
                            } label: {
                                Image(systemName: "speaker.wave.2.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(Theme.Colors.primary)
                                    .padding(6)
                                    .background(
                                        Circle()
                                            .fill(Theme.Colors.primary.opacity(0.1))
                                    )
                            }
                        }
                    }
                    
                    Text(targetText)
                        .font(.system(size: 26, weight: .medium, design: .rounded))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Theme.Spacing.s)
                    
                    // Show alternatives if any - more compact
                    if direction.isGermanToVietnamese && !word.vietnameseAlt.isEmpty {
                        Text("Also: \(word.vietnameseAlt.joined(separator: ", "))")
                            .font(Theme.Typography.caption)
                            .foregroundColor(Theme.Colors.textSecondary)
                    } else if !direction.isGermanToVietnamese && !word.germanAlt.isEmpty {
                        Text("Also: \(word.germanAlt.joined(separator: ", "))")
                            .font(Theme.Typography.caption)
                            .foregroundColor(Theme.Colors.textSecondary)
                    }
                }
                .padding(Theme.Spacing.m)
                .background(
                    RoundedRectangle(cornerRadius: Theme.Radius.card)
                        .fill(Theme.Colors.success.opacity(0.08))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.Radius.card)
                        .stroke(Theme.Colors.success.opacity(0.2), lineWidth: 1)
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .bottom).combined(with: .opacity),
                    removal: .scale(scale: 0.9).combined(with: .opacity)
                ))
            } else {
                Button(action: onReveal) {
                    HStack(spacing: Theme.Spacing.s) {
                        Image(systemName: "eye")
                            .font(.system(size: 16))
                        Text("Reveal Answer")
                            .font(Theme.Typography.headline)
                    }
                    .foregroundColor(Theme.Colors.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .padding(.horizontal, Theme.Spacing.m)
                    .background(
                        RoundedRectangle(cornerRadius: Theme.Radius.button)
                            .fill(Theme.Colors.primary.opacity(0.1))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.Radius.button)
                            .stroke(Theme.Colors.primary.opacity(0.3), lineWidth: 1)
                    )
                }
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: reveal)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isCorrect)
    }
    
    private func borderColor() -> Color {
        guard let isCorrect = isCorrect else { return Color.clear }
        return isCorrect ? Theme.Colors.success : Theme.Colors.danger
    }
}
