import SwiftUI

// MARK: - Color Extensions
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex.replacingOccurrences(of: "#", with: ""))
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        
        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >> 8) & 0xFF) / 255
        let b = Double(rgb & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - View Extensions
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

// MARK: - Shake Effect
struct ShakeEffect: GeometryEffect {
    var animatableData: CGFloat
    private let amount: CGFloat = 10
    private let shakesPerUnit = 3
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(
            translationX: amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
            y: 0
        ))
    }
}
