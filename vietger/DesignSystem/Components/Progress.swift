import SwiftUI

struct ProgressRing: View {
    let progress: Double
    let size: CGFloat
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Theme.Colors.disabled, lineWidth: 4)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    Theme.Colors.primary,
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
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
