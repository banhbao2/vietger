import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var environment: AppEnvironment
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Colors.primaryGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: Theme.Spacing.l) {
                        headerSection
                        welcomeCard
                        progressOverview
                        actionSection
                        dailyTip
                    }
                    .padding(.horizontal, Theme.Spacing.m)
                    .padding(.bottom, Theme.Spacing.xxl)
                }
            }
            .onAppear {
                viewModel.loadStats(from: appState)
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: Theme.Spacing.m) {
            Text("Vyvu")
                .font(.system(size: 42, weight: .bold, design: .serif))
                .foregroundColor(.white)
                .shadow(radius: 4)
            
            HStack(spacing: Theme.Spacing.m) {
                StreakBadge(days: viewModel.streak)
                XPBadge(xp: viewModel.totalXP)
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
    
    private var progressOverview: some View {
        HStack(spacing: Theme.Spacing.m) {
            StatCard(
                icon: "checkmark.circle.fill",
                value: "\(viewModel.learnedWords)",
                label: "Learned",
                color: Theme.Colors.success
            )
            
            StatCard(
                icon: "book.fill",
                value: "\(viewModel.unlearnedWords)",
                label: "To Learn",
                color: Theme.Colors.primary
            )
        }
    }
    
    private var actionSection: some View {
        VStack(spacing: Theme.Spacing.m) {
            NavigationLink(destination: QuizView()) {
                NavigationActionCard(
                    title: "Start Quiz",
                    subtitle: "Test your knowledge",
                    icon: "play.circle.fill",
                    iconColor: Theme.Colors.success,
                    isRecommended: true
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            NavigationLink(destination: WordListView()) {
                NavigationActionCard(
                    title: "Word List",
                    subtitle: "Browse vocabulary",
                    icon: "list.bullet.rectangle",
                    iconColor: Theme.Colors.primary,
                    isRecommended: false
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    private var dailyTip: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.s) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(Theme.Colors.warning)
                Text("Daily Tip")
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            
            Text(viewModel.dailyTip)
                .font(Theme.Typography.body)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Theme.Spacing.m)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.card)
                .fill(Theme.Colors.warning.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.Radius.card)
                        .stroke(Theme.Colors.warning.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// New NavigationActionCard without Button wrapper
struct NavigationActionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let iconColor: Color
    let isRecommended: Bool
    
    var body: some View {
        HStack(spacing: Theme.Spacing.m) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 56, height: 56)
                
                Image(systemName: icon)
                    .font(.system(size: 26))
                    .foregroundColor(iconColor)
            }
            
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                HStack(spacing: Theme.Spacing.s) {
                    Text(title)
                        .font(Theme.Typography.headline)
                        .foregroundColor(Theme.Colors.text)
                    
                    if isRecommended {
                        Text("RECOMMENDED")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Theme.Colors.success)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(Theme.Colors.success.opacity(0.15))
                            )
                    }
                }
                
                Text(subtitle)
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Theme.Colors.textSecondary)
        }
        .padding(Theme.Spacing.m)
        .background(Theme.Colors.card)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card))
        .shadow(color: Theme.Shadow.card.color,
               radius: Theme.Shadow.card.radius,
               x: 0, y: Theme.Shadow.card.y)
    }
}
