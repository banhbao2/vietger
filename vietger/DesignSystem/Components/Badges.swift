import SwiftUI

struct StreakBadge: View {
    let days: Int
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "flame.fill")
                .foregroundColor(Theme.Colors.warning)
            Text("\(days)")
                .font(Theme.Typography.headline)
        }
        .padding(.horizontal, Theme.Spacing.s)
        .padding(.vertical, Theme.Spacing.xs)
        .background(
            Capsule()
                .fill(Theme.Colors.warning.opacity(0.2))
        )
    }
}

struct XPBadge: View {
    let xp: Int
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "star.fill")
                .foregroundColor(Theme.Colors.warning)
                .font(.system(size: 12))
            Text("\(xp) XP")
                .font(Theme.Typography.caption)
        }
        .padding(.horizontal, Theme.Spacing.s)
        .padding(.vertical, Theme.Spacing.xs)
        .background(
            Capsule()
                .fill(Theme.Colors.warning.opacity(0.15))
        )
    }
}
