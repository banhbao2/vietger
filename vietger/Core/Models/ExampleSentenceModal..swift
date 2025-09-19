import SwiftUI

struct ExampleSentenceModal: View {
    let word: Word
    let sentence: Sentence?  // Now optional
    let direction: QuizDirection
    @Binding var isPresented: Bool
    
    private var sourceWord: String {
        direction.isGermanToVietnamese ? word.german : word.vietnamese
    }
    
    private var targetWord: String {
        direction.isGermanToVietnamese ? word.vietnamese : word.german
    }
    
    private var sourceSentence: String {
        sentence?.german ?? ""
    }
    
    private var targetSentence: String {
        sentence?.vietnamese ?? ""
    }
    
    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }
            
            // Modal content
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text(sentence != nil ? "Example Sentence" : "No Sentence Available")
                        .font(Theme.Typography.title2)
                    
                    Spacer()
                    
                    Button {
                        isPresented = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Theme.Colors.textSecondary)
                    }
                }
                .padding(Theme.Spacing.m)
                
                ScrollView {
                    VStack(spacing: Theme.Spacing.l) {
                        if sentence != nil {
                            // Normal content when sentence exists
                            // Word reference
                            VStack(spacing: Theme.Spacing.s) {
                                Text("Word:")
                                    .font(Theme.Typography.caption)
                                    .foregroundColor(Theme.Colors.textSecondary)
                                
                                HStack(spacing: Theme.Spacing.m) {
                                    WordPair(
                                        flag: direction.sourceFlag,
                                        text: sourceWord,
                                        isSource: true
                                    )
                                    
                                    Image(systemName: "arrow.right")
                                        .foregroundColor(Theme.Colors.textSecondary)
                                    
                                    WordPair(
                                        flag: direction.targetFlag,
                                        text: targetWord,
                                        isSource: false
                                    )
                                }
                            }
                            .padding(Theme.Spacing.m)
                            .background(
                                RoundedRectangle(cornerRadius: Theme.Radius.button)
                                    .fill(Theme.Colors.primary.opacity(0.05))
                            )
                            
                            // Both sentences displayed together
                            VStack(spacing: Theme.Spacing.m) {
                                // Source sentence
                                SentenceCard(
                                    flag: direction.sourceFlag,
                                    sentence: sourceSentence,
                                    highlightWord: sourceWord,
                                    label: direction.isGermanToVietnamese ? "German" : "Vietnamese"
                                )
                                
                                // Visual separator
                                HStack(spacing: Theme.Spacing.s) {
                                    Rectangle()
                                        .fill(Theme.Colors.disabled.opacity(0.3))
                                        .frame(height: 1)
                                        .frame(maxWidth: .infinity)
                                    
                                    Image(systemName: "arrow.up.arrow.down")
                                        .font(.system(size: 14))
                                        .foregroundColor(Theme.Colors.textSecondary)
                                    
                                    Rectangle()
                                        .fill(Theme.Colors.disabled.opacity(0.3))
                                        .frame(height: 1)
                                        .frame(maxWidth: .infinity)
                                }
                                .padding(.horizontal, Theme.Spacing.m)
                                
                                // Target sentence (translation)
                                SentenceCard(
                                    flag: direction.targetFlag,
                                    sentence: targetSentence,
                                    highlightWord: targetWord,
                                    label: direction.isGermanToVietnamese ? "Vietnamese" : "German"
                                )
                            }
                        } else {
                            // Error state when no sentence found
                            VStack(spacing: Theme.Spacing.l) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 48))
                                    .foregroundColor(Theme.Colors.warning)
                                
                                Text("No example sentence available")
                                    .font(Theme.Typography.headline)
                                    .foregroundColor(Theme.Colors.text)
                                
                                // Debug info - show German word needed
                                VStack(spacing: Theme.Spacing.s) {
                                    Text("Looking for German word:")
                                        .font(Theme.Typography.caption)
                                        .foregroundColor(Theme.Colors.textSecondary)
                                    
                                    Text("\"\(word.german)\"")
                                        .font(.system(.caption, design: .monospaced))
                                        .foregroundColor(Theme.Colors.primary)
                                        .padding(Theme.Spacing.s)
                                        .background(
                                            RoundedRectangle(cornerRadius: Theme.Radius.small)
                                                .fill(Theme.Colors.primary.opacity(0.1))
                                        )
                                    
                                    Text("Check that this word exists as a 'wordId' in your sentences JSON file")
                                        .font(Theme.Typography.caption2)
                                        .foregroundColor(Theme.Colors.textSecondary)
                                        .multilineTextAlignment(.center)
                                }
                                .padding(Theme.Spacing.m)
                                .background(
                                    RoundedRectangle(cornerRadius: Theme.Radius.button)
                                        .fill(Theme.Colors.background)
                                )
                            }
                            .padding(Theme.Spacing.m)
                        }
                    }
                    .padding(Theme.Spacing.m)
                }
                
                // Close button
                Button {
                    isPresented = false
                } label: {
                    Text(sentence != nil ? "Got it!" : "Close")
                }
                .applyCloseButtonStyle(hasSentence: sentence != nil)
                .padding(Theme.Spacing.m)
            }
            .background(Theme.Colors.card)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card))
            .shadow(color: Theme.Shadow.card.color, radius: 20, y: 10)
            .padding(Theme.Spacing.l)
            .transition(.asymmetric(
                insertion: .scale(scale: 0.8).combined(with: .opacity),
                removal: .scale(scale: 1.1).combined(with: .opacity)
            ))
        }
    }
}

// Keep existing helper views the same
struct WordPair: View {
    let flag: String
    let text: String
    let isSource: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            Text(flag)
                .font(.system(size: 24))
            Text(text)
                .font(isSource ? Theme.Typography.headline : Theme.Typography.body)
                .foregroundColor(isSource ? Theme.Colors.text : Theme.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
    }
}

struct SentenceCard: View {
    let flag: String
    let sentence: String
    let highlightWord: String
    let label: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.s) {
            HStack {
                Text(flag)
                    .font(.system(size: 20))
                Text(label)
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            
            Text(highlightedText)
                .font(Theme.Typography.body)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Theme.Spacing.m)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.button)
                .fill(Theme.Colors.background)
        )
    }
    
    private var highlightedText: AttributedString {
        var attributedString = AttributedString(sentence)
        
        // Find and highlight the word in the sentence
        if let range = sentence.range(of: highlightWord, options: .caseInsensitive) {
            let nsRange = NSRange(range, in: sentence)
            let start = attributedString.index(attributedString.startIndex, offsetByCharacters: nsRange.location)
            let end = attributedString.index(start, offsetByCharacters: nsRange.length)
            
            attributedString[start..<end].foregroundColor = Theme.Colors.primary
            attributedString[start..<end].font = Theme.Typography.headline
        }
        
        return attributedString
    }
}

// Helper to avoid a ternary with different ButtonStyle types
private extension View {
    @ViewBuilder
    func applyCloseButtonStyle(hasSentence: Bool) -> some View {
        if hasSentence {
            self.buttonStyle(PrimaryButtonStyle())
        } else {
            self.buttonStyle(SecondaryButtonStyle())
        }
    }
}
