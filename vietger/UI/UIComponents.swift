import SwiftUI

// MARK: - Button Styles
struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .buttonBase(
                background: isEnabled ? Theme.Colors.primary : Theme.Colors.disabled,
                foreground: .white,
                isPressed: configuration.isPressed
            )
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .buttonBase(
                background: .clear,
                foreground: isEnabled ? Theme.Colors.primary : Theme.Colors.disabled,
                border: isEnabled ? Theme.Colors.primary : Theme.Colors.disabled,
                isPressed: configuration.isPressed
            )
    }
}

struct SuccessButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .buttonBase(
                background: Theme.Colors.success,
                foreground: .white,
                isPressed: configuration.isPressed
            )
    }
}

// MARK: - Cards
struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: Theme.Spacing.s) {
            Image(systemName: icon)
                .font(.system(size: Theme.Constants.iconSize))
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
        .cardStyle()
    }
}

// MARK: - Progress Views
struct ProgressRing: View {
    let progress: Double
    let size: CGFloat
    let color: Color
    
    init(progress: Double, size: CGFloat = 120, color: Color = Theme.Colors.primary) {
        self.progress = progress
        self.size = size
        self.color = color
    }
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Theme.Colors.disabled, lineWidth: 4)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(color, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .rotationEffect(.degrees(-90))
            
            Text("\(Int(progress * 100))%")
                .font(Theme.Typography.caption)
        }
        .frame(width: size, height: size)
    }
}

struct LinearProgress: View {
    let progress: Double
    let color: Color
    
    init(progress: Double, color: Color = Theme.Colors.primary) {
        self.progress = progress
        self.color = color
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Theme.Colors.disabled.opacity(0.3))
                
                RoundedRectangle(cornerRadius: 6)
                    .fill(color)
                    .frame(width: geometry.size.width * progress)
            }
        }
        .frame(height: 6)
    }
}

// MARK: - Badges
struct StreakBadge: View {
    let days: Int
    
    var body: some View {
        BadgeView(
            icon: "flame.fill",
            text: "\(days)",
            color: Theme.Colors.warning
        )
    }
}

struct XPBadge: View {
    let xp: Int
    
    var body: some View {
        BadgeView(
            icon: "star.fill",
            text: "\(xp) XP",
            color: Theme.Colors.warning,
            iconSize: 12
        )
    }
}

private struct BadgeView: View {
    let icon: String
    let text: String
    let color: Color
    let iconSize: CGFloat
    
    init(icon: String, text: String, color: Color, iconSize: CGFloat = 16) {
        self.icon = icon
        self.text = text
        self.color = color
        self.iconSize = iconSize
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: iconSize))
            Text(text)
                .font(iconSize == 12 ? Theme.Typography.caption : Theme.Typography.headline)
        }
        .padding(.horizontal, Theme.Spacing.s)
        .padding(.vertical, Theme.Spacing.xs)
        .background(Capsule().fill(color.opacity(0.2)))
    }
}

// MARK: - View Extensions
extension View {
    func cardStyle(padding: CGFloat = Theme.Spacing.m) -> some View {
        self
            .padding(padding)
            .background(Theme.Colors.card)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card))
            .shadow(
                color: Theme.Shadow.card.color,
                radius: Theme.Shadow.card.radius,
                x: 0,
                y: Theme.Shadow.card.y
            )
    }
    
    func buttonBase(
        background: Color,
        foreground: Color,
        border: Color? = nil,
        isPressed: Bool = false
    ) -> some View {
        self
            .font(Theme.Typography.headline)
            .foregroundColor(foreground)
            .frame(maxWidth: .infinity)
            .frame(height: Theme.Constants.buttonHeight)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.button)
                    .fill(background)
                    .overlay(
                        border.map { color in
                            RoundedRectangle(cornerRadius: Theme.Radius.button)
                                .stroke(color, lineWidth: 2)
                        }
                    )
            )
            .scaleEffect(isPressed ? 0.96 : 1)
            .contentShape(RoundedRectangle(cornerRadius: Theme.Radius.button))
    }
    
    func shake(times: CGFloat) -> some View {
        modifier(ShakeEffect(animatableData: times))
    }
}

// MARK: - Effects
struct ShakeEffect: GeometryEffect {
    var animatableData: CGFloat
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(
            translationX: 10 * sin(animatableData * .pi * 3),
            y: 0
        ))
    }
}
