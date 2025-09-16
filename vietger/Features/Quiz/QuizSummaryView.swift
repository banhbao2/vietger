import SwiftUI

struct QuizSummaryView: View {
    let session: QuizSession
    let onDismiss: () -> Void
    let onReviewMistakes: ([Word]) -> Void // New callback for review
    
    @State private var animateResults = false
    @State private var selectedTab = 0 // 0: Overview, 1: Correct, 2: Mistakes
    
    private var correctWords: [Word] {
        session.words.filter { session.correctIDs.contains($0.id) }
    }
    
    private var incorrectWords: [Word] {
        session.words.filter { !session.correctIDs.contains($0.id) }
    }
    
    private var accuracy: Int {
        guard !session.words.isEmpty else { return 0 }
        return Int((Double(correctWords.count) / Double(session.words.count)) * 100)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with accuracy
            headerSection
            
            // Tab selector
            tabSelector
            
            // Content based on selected tab
            TabView(selection: $selectedTab) {
                overviewTab.tag(0)
                wordListTab(words: correctWords, isCorrect: true).tag(1)
                wordListTab(words: incorrectWords, isCorrect: false).tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            // Bottom buttons
            bottomButtons
        }
        .background(Theme.Colors.background)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.3)) {
                animateResults = true
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: Theme.Spacing.m) {
            // Accuracy circle
            ZStack {
                Circle()
                    .stroke(Theme.Colors.disabled.opacity(0.3), lineWidth: 12)
                    .frame(width: 120, height: 120)
                
                Circle()
                    .trim(from: 0, to: animateResults ? Double(accuracy) / 100 : 0)
                    .stroke(
                        accuracy >= 80 ? Theme.Colors.success :
                        accuracy >= 50 ? Theme.Colors.warning :
                        Theme.Colors.danger,
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 4) {
                    Text("\(accuracy)%")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                    Text("Accuracy")
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.Colors.textSecondary)
                }
                .scaleEffect(animateResults ? 1 : 0.5)
                .opacity(animateResults ? 1 : 0)
            }
            
            Text(motivationalMessage())
                .font(Theme.Typography.title2)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, Theme.Spacing.l)
        .padding(.horizontal, Theme.Spacing.m)
        .background(Theme.Colors.card)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card))
        .padding(Theme.Spacing.m)
        .shadow(color: Theme.Shadow.card.color, radius: Theme.Shadow.card.radius, y: Theme.Shadow.card.y)
    }
    
    private var tabSelector: some View {
        HStack(spacing: 0) {
            tabButton(title: "Overview", icon: "chart.bar", index: 0)
            tabButton(
                title: "Correct (\(correctWords.count))",
                icon: "checkmark.circle.fill",
                index: 1,
                color: Theme.Colors.success
            )
            tabButton(
                title: "Review (\(incorrectWords.count))",
                icon: "exclamationmark.triangle.fill",
                index: 2,
                color: Theme.Colors.warning
            )
        }
        .padding(4)
        .background(Theme.Colors.card)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.button))
        .padding(.horizontal, Theme.Spacing.m)
    }
    
    private func tabButton(title: String, icon: String, index: Int, color: Color = Theme.Colors.primary) -> some View {
        Button {
            withAnimation {
                selectedTab = index
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(selectedTab == index ? color : Theme.Colors.textSecondary)
                
                Text(title)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(selectedTab == index ? Theme.Colors.text : Theme.Colors.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Theme.Spacing.s)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.small)
                    .fill(selectedTab == index ? color.opacity(0.1) : Color.clear)
            )
        }
    }
    
    private var overviewTab: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.m) {
                // Stats cards
                HStack(spacing: Theme.Spacing.m) {
                    StatCard(
                        icon: "clock",
                        value: "\(session.words.count)",
                        label: "Words Practiced",
                        color: Theme.Colors.primary
                    )
                    
                    StatCard(
                        icon: "checkmark.circle",
                        value: "\(correctWords.count)",
                        label: "Correct",
                        color: Theme.Colors.success
                    )
                }
                
                // Insights
                VStack(alignment: .leading, spacing: Theme.Spacing.m) {
                    Text("Insights")
                        .font(Theme.Typography.headline)
                        .padding(.horizontal, Theme.Spacing.m)
                    
                    VStack(spacing: Theme.Spacing.s) {
                        if accuracy >= 80 {
                            InsightRow(
                                icon: "star.fill",
                                text: "Excellent performance! You've mastered most of these words.",
                                color: Theme.Colors.success
                            )
                        }
                        
                        if incorrectWords.count > 0 {
                            InsightRow(
                                icon: "book.fill",
                                text: "Review \(incorrectWords.count) word\(incorrectWords.count == 1 ? "" : "s") to improve",
                                color: Theme.Colors.warning
                            )
                        }
                        
                        if correctWords.count > 0 {
                            InsightRow(
                                icon: "checkmark.seal.fill",
                                text: "\(correctWords.count) word\(correctWords.count == 1 ? "" : "s") marked as learned",
                                color: Theme.Colors.success
                            )
                        }
                    }
                    .padding(.horizontal, Theme.Spacing.m)
                }
                
                Spacer(minLength: 100)
            }
            .padding(.vertical, Theme.Spacing.m)
        }
    }
    
    private func wordListTab(words: [Word], isCorrect: Bool) -> some View {
        ScrollView {
            if words.isEmpty {
                VStack(spacing: Theme.Spacing.m) {
                    Image(systemName: isCorrect ? "checkmark.circle" : "book.circle")
                        .font(.system(size: 48))
                        .foregroundColor(Theme.Colors.disabled)
                    
                    Text(isCorrect ? "No correct answers yet" : "Perfect! All answers were correct")
                        .font(Theme.Typography.body)
                        .foregroundColor(Theme.Colors.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, Theme.Spacing.xxl)
            } else {
                LazyVStack(spacing: Theme.Spacing.s) {
                    ForEach(words) { word in
                        WordReviewCard(
                            word: word,
                            direction: session.configuration.direction,
                            isCorrect: isCorrect
                        )
                    }
                }
                .padding(Theme.Spacing.m)
                .padding(.bottom, 100)
            }
        }
    }
    
    private var bottomButtons: some View {
        VStack(spacing: Theme.Spacing.m) {
            Button {
                onDismiss()
            } label: {
                Text("Continue Learning")
            }
            .buttonStyle(PrimaryButtonStyle())
            
            if !incorrectWords.isEmpty {
                Button {
                    onReviewMistakes(incorrectWords)
                } label: {
                    HStack {
                        Image(systemName: "arrow.triangle.2.circlepath")
                        Text("Review Mistakes (\(incorrectWords.count))")
                    }
                }
                .buttonStyle(SecondaryButtonStyle())
            }
        }
        .padding(Theme.Spacing.m)
        .background(
            Theme.Colors.card
                .shadow(color: Theme.Shadow.card.color, radius: Theme.Shadow.card.radius, y: -2)
        )
    }
    
    private func motivationalMessage() -> String {
        if accuracy >= 90 {
            return "Outstanding! 🌟"
        } else if accuracy >= 70 {
            return "Great job! 💪"
        } else if accuracy >= 50 {
            return "Good progress! 📈"
        } else {
            return "Keep practicing! 🎯"
        }
    }
}

// Word Review Card Component
struct WordReviewCard: View {
    let word: Word
    let direction: QuizDirection
    let isCorrect: Bool
    
    @State private var isExpanded = false
    
    private var sourceText: String {
        direction.isGermanToVietnamese ? word.german : word.vietnamese
    }
    
    private var targetText: String {
        direction.isGermanToVietnamese ? word.vietnamese : word.german
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(direction.sourceFlag)
                            .font(.system(size: 20))
                        Text(sourceText)
                            .font(Theme.Typography.headline)
                    }
                    
                    HStack(spacing: 6) {
                        Text(direction.targetFlag)
                            .font(.system(size: 20))
                        Text(targetText)
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.textSecondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(isCorrect ? Theme.Colors.success : Theme.Colors.danger)
                    .font(.system(size: 24))
            }
            .padding(Theme.Spacing.m)
            
            if !word.germanAlt.isEmpty || !word.vietnameseAlt.isEmpty {
                Button {
                    withAnimation {
                        isExpanded.toggle()
                    }
                } label: {
                    HStack {
                        Text("Show alternatives")
                            .font(Theme.Typography.caption)
                            .foregroundColor(Theme.Colors.primary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12))
                            .foregroundColor(Theme.Colors.primary)
                            .rotationEffect(.degrees(isExpanded ? 180 : 0))
                    }
                    .padding(.horizontal, Theme.Spacing.m)
                    .padding(.bottom, Theme.Spacing.s)
                }
                
                if isExpanded {
                    VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                        if !word.germanAlt.isEmpty {
                            Text("German: \(word.germanAlt.joined(separator: ", "))")
                                .font(Theme.Typography.caption)
                                .foregroundColor(Theme.Colors.textSecondary)
                        }
                        if !word.vietnameseAlt.isEmpty {
                            Text("Vietnamese: \(word.vietnameseAlt.joined(separator: ", "))")
                                .font(Theme.Typography.caption)
                                .foregroundColor(Theme.Colors.textSecondary)
                        }
                    }
                    .padding(.horizontal, Theme.Spacing.m)
                    .padding(.bottom, Theme.Spacing.s)
                }
            }
        }
        .background(Theme.Colors.card)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.card)
                .stroke(
                    isCorrect ? Theme.Colors.success.opacity(0.3) : Theme.Colors.danger.opacity(0.3),
                    lineWidth: 1
                )
        )
    }
}

struct InsightRow: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: Theme.Spacing.s) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: 16))
                .frame(width: 20)
            
            Text(text)
                .font(Theme.Typography.body)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(Theme.Spacing.m)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.small)
                .fill(color.opacity(0.1))
        )
    }
}
