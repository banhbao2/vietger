import SwiftUI

enum Theme {
    enum Colors {
        static let primary = Color(hex: "#4A90E2")
        static let success = Color(hex: "#4CAF50")
        static let warning = Color(hex: "#FFD54F")
        static let danger = Color(hex: "#F44336")
        
        static let text = Color(hex: "#212121")
        static let textSecondary = Color(hex: "#757575")
        static let background = Color(hex: "#F5F5F5")
        static let card = Color.white
        static let disabled = Color(hex: "#E0E0E0")
        
        static let primaryGradient = LinearGradient(
            colors: [Color(hex: "#A7D8F0"), Color(hex: "#E3F2FD")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    enum Spacing {
        static let xs: CGFloat = 4
        static let s: CGFloat = 8
        static let m: CGFloat = 16
        static let l: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }
    
    enum Radius {
        static let button: CGFloat = 12
        static let card: CGFloat = 16
        static let small: CGFloat = 8
    }
    
    enum Shadow {
        static let card = (color: Color.black.opacity(0.08), radius: CGFloat(6), y: CGFloat(2))
        static let button = (color: Color.black.opacity(0.15), radius: CGFloat(4), y: CGFloat(2))
        static let subtle = (color: Color.black.opacity(0.05), radius: CGFloat(2), y: CGFloat(1))
    }
    
    enum Typography {
        static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
        static let title = Font.system(size: 28, weight: .bold, design: .rounded)
        static let title2 = Font.system(size: 22, weight: .semibold, design: .rounded)
        static let headline = Font.system(size: 17, weight: .semibold)
        static let body = Font.system(size: 16)
        static let callout = Font.system(size: 15)
        static let caption = Font.system(size: 14)
        static let caption2 = Font.system(size: 12)
    }
}
