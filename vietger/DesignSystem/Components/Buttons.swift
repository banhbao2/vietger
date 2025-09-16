import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Theme.Typography.headline)
            .foregroundColor(.white)
            .frame(height: 48)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.button)
                    .fill(isEnabled ? Theme.Colors.primary : Theme.Colors.disabled)
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Theme.Typography.headline)
            .foregroundColor(Theme.Colors.primary)
            .frame(height: 48)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.button)
                    .stroke(Theme.Colors.primary, lineWidth: 2)
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
    }
}

struct SuccessButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Theme.Typography.headline)
            .foregroundColor(.white)
            .frame(height: 48)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.button)
                    .fill(Theme.Colors.success)
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
    }
}
