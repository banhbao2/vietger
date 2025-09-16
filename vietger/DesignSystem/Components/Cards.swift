import SwiftUI

struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: Theme.Spacing.s) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(value)
                .font(Theme.Typography.title2)
                .foregroundColor(Theme.Colors.text)
            
            Text(label)
                .font(Theme.Typography.caption2)
                .foregroundColor(Theme.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(Theme.Spacing.m)
        .background(Theme.Colors.card)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card))
        .shadow(color: Theme.Shadow.subtle.color,
               radius: Theme.Shadow.subtle.radius,
               x: 0, y: Theme.Shadow.subtle.y)
    }
}

// Keep ActionCard for non-navigation use cases only
struct ActionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let iconColor: Color
    let isRecommended: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
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
        .buttonStyle(PlainButtonStyle())
    }
}
