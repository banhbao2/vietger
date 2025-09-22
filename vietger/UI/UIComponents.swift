import SwiftUI

// MARK: - Button Styles
struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Theme.Typography.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)  // Full width
            .frame(height: 48)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.button)
                    .fill(isEnabled ? Theme.Colors.primary : Theme.Colors.disabled)
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .contentShape(RoundedRectangle(cornerRadius: Theme.Radius.button))  // Fix hitbox
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Theme.Typography.headline)
            .foregroundColor(isEnabled ? Theme.Colors.primary : Theme.Colors.disabled)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.button)
                    .stroke(isEnabled ? Theme.Colors.primary : Theme.Colors.disabled, lineWidth: 2)
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .contentShape(RoundedRectangle(cornerRadius: Theme.Radius.button))  // Fix hitbox
    }
}

struct SuccessButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Theme.Typography.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.button)
                    .fill(Theme.Colors.success)
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .contentShape(RoundedRectangle(cornerRadius: Theme.Radius.button))  // Fix hitbox
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
        .cardStyle()
    }
}

// MARK: - Progress Views
struct ProgressRing: View {
    let progress: Double
    let size: CGFloat
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Theme.Colors.disabled, lineWidth: 4)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Theme.Colors.primary,
                       style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .rotationEffect(.degrees(-90))
            
            Text("\(Int(progress * 100))%")
                .font(Theme.Typography.caption)
        }
        .frame(width: size, height: size)
    }
}

struct LinearProgress: View {
    let progress: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Theme.Colors.disabled.opacity(0.3))
                    .frame(height: 6)
                
                RoundedRectangle(cornerRadius: 6)
                    .fill(Theme.Colors.primary)
                    .frame(width: geometry.size.width * progress, height: 6)
            }
        }
        .frame(height: 6)
    }
}

// MARK: - Badges
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

// MARK: - Extensions
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex.replacingOccurrences(of: "#", with: ""))
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        
        self.init(
            red: Double((rgb >> 16) & 0xFF) / 255,
            green: Double((rgb >> 8) & 0xFF) / 255,
            blue: Double(rgb & 0xFF) / 255
        )
    }
}

extension View {
    func cardStyle(padding: CGFloat = Theme.Spacing.m) -> some View {
        self
            .padding(padding)
            .background(Theme.Colors.card)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card))
            .shadow(color: Theme.Shadow.card.color,
                   radius: Theme.Shadow.card.radius,
                   x: 0, y: Theme.Shadow.card.y)
    }
    
    func shake(times: CGFloat) -> some View {
        modifier(ShakeEffect(animatableData: times))
    }
}

struct ShakeEffect: GeometryEffect {
    var animatableData: CGFloat
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(
            translationX: 10 * sin(animatableData * .pi * 3),
            y: 0
        ))
    }
}
