import SwiftUI

struct HomeView: View {
    @EnvironmentObject var environment: AppEnvironment
    @State private var dailyTip = ""
    
    private let tips = [
        "Practice 5 minutes daily to maintain your streak!",
        "Review difficult words before bed for better retention.",
        "Use spaced repetition for long-term memory.",
        "Try speaking words out loud to improve pronunciation.",
        "Focus on one category at a time for better results."
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Colors.primaryGradient.ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: Theme.Spacing.l) {
                        headerSection
                        welcomeCard
                        progressSection
                        actionSection
                        dailyTipCard
                    }
                    .padding(.horizontal, Theme.Spacing.m)
                    .padding(.bottom, Theme.Spacing.xxl)
                }
            }
            .onAppear { selectRandomTip() }
        }
    }
    
    // MARK: - View Components
    private var headerSection: some View {
        VStack(spacing: Theme.Spacing.m) {
            Text("Vyvu")
                .font(.system(size: 42, weight: .bold, design: .serif))
                .foregroundColor(.white)
                .shadow(radius: 4)
            
            HStack(spacing: Theme.Spacing.m) {
                StreakBadge(days: environment.statistics.currentStreak)
                XPBadge(xp: environment.statistics.totalXP)
            }
        }
        .padding(.top, Theme.Spacing.m)
    }
    
    private var welcomeCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: Theme.Spacing.s) {
                Text("👋 Xin chào bạn!")
                    .font(Theme.Typography.title2)
                Text("Ready to continue learning?")
                    .font(Theme.Typography.body)
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            Spacer()
            Text("🎯")
                .font(.system(size: 40))
        }
        .cardStyle()
    }
    
    private var progressSection: some View {
        HStack(spacing: Theme.Spacing.m) {
            StatCard(
                icon: "checkmark.circle.fill",
                value: "\(environment.statistics.learnedWords)",
                label: "Learned",
                color: Theme.Colors.success
            )
            
            StatCard(
                icon: "book.fill",
                value: "\(environment.statistics.unlearnedWords)",
                label: "To Learn",
                color: Theme.Colors.primary
            )
        }
    }
    
    private var actionSection: some View {
        VStack(spacing: Theme.Spacing.m) {
            NavigationActionCard(
                title: "Start Quiz",
                subtitle: "Test your knowledge",
                icon: "play.circle.fill",
                iconColor: Theme.Colors.success,
                destination: QuizView(),
                isRecommended: true
            )
            
            NavigationActionCard(
                title: "Word List",
                subtitle: "Browse vocabulary",
                icon: "list.bullet.rectangle",
                iconColor: Theme.Colors.primary,
                destination: WordListView(),
                isRecommended: false
            )
        }
    }
    
    private var dailyTipCard: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.s) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(Theme.Colors.warning)
                Text("Daily Tip")
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            
            Text(dailyTip)
                .font(Theme.Typography.body)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Theme.Spacing.m)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.card)
                .fill(Theme.Colors.warning.opacity(0.1))
        )
    }
    
    // MARK: - Private Methods
    private func selectRandomTip() {
        dailyTip = tips.randomElement() ?? tips[0]
    }
}

// MARK: - Supporting Views
struct NavigationActionCard<Destination: View>: View {
    let title: String
    let subtitle: String
    let icon: String
    let iconColor: Color
    let destination: Destination
    let isRecommended: Bool
    
    var body: some View {
        NavigationLink(destination: destination) {
            HStack(spacing: Theme.Spacing.m) {
                iconSection
                textSection
                Spacer()
                chevron
            }
            .cardStyle()
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var iconSection: some View {
        ZStack {
            Circle()
                .fill(iconColor.opacity(0.15))
                .frame(width: 56, height: 56)
            
            Image(systemName: icon)
                .font(.system(size: 26))
                .foregroundColor(iconColor)
        }
    }
    
    private var textSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            HStack(spacing: Theme.Spacing.s) {
                Text(title)
                    .font(Theme.Typography.headline)
                    .foregroundColor(Theme.Colors.text)
                
                if isRecommended {
                    recommendedBadge
                }
            }
            
            Text(subtitle)
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textSecondary)
        }
    }
    
    private var recommendedBadge: some View {
        Text("RECOMMENDED")
            .font(.system(size: 10, weight: .bold))
            .foregroundColor(Theme.Colors.success)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(
                Capsule().fill(Theme.Colors.success.opacity(0.15))
            )
    }
    
    private var chevron: some View {
        Image(systemName: "chevron.right")
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(Theme.Colors.textSecondary)
    }
}
