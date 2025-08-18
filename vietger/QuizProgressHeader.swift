import SwiftUI

struct QuizProgressHeader: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let progress: Double   // 0…1 for completed items
    let currentIndex: Int  // zero-based
    let total: Int
    let correctCount: Int

    private var oneBasedIndex: Int { min(currentIndex + 1, max(total, 1)) }

    var body: some View {
        VStack(spacing: 8) {
            ProgressView(value: progress)
                .progressViewStyle(.linear)
                .animation(reduceMotion ? nil : .easeOut(duration: 0.25), value: progress)
                .accessibilityLabel("Progress")
                .accessibilityValue("\(currentIndex) of \(total) completed")

            HStack {
                Text("Word \(oneBasedIndex) / \(total)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                if total > 0 {
                    let score = Int((Double(correctCount) / Double(total)) * 100)
                    Text("\(score)% correct")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .accessibilityHidden(true)
                }
            }
        }
        .padding(.horizontal)
    }
}
