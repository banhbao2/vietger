import SwiftUI

struct WordRow: View {
    let word: Word
    let isLearned: Bool
    let onToggle: () -> Void
    
    @State private var isExpanded = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: Theme.Spacing.m) {
                Button(action: onToggle) {
                    Image(systemName: isLearned ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 24))
                        .foregroundColor(isLearned ? Theme.Colors.success : Theme.Colors.disabled)
                }
                
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    Text(word.german)
                        .font(Theme.Typography.headline)
                    Text(word.vietnamese)
                        .font(Theme.Typography.body)
                        .foregroundColor(Theme.Colors.textSecondary)
                }
                
                Spacer()
                
                Button {
                    withAnimation {
                        isExpanded.toggle()
                    }
                } label: {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Theme.Colors.textSecondary)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
            }
            .padding(Theme.Spacing.m)
            
            if isExpanded {
                WordRowExpanded(word: word)
            }
        }
        .background(Theme.Colors.card)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.card)
                .stroke(isLearned ? Theme.Colors.success.opacity(0.3) : Color.clear, lineWidth: 1)
        )
    }
}

struct WordRowExpanded: View {
    let word: Word
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.s) {
            Divider()
            
            HStack {
                Label("Category", systemImage: "folder")
                    .font(Theme.Typography.caption)
                Spacer()
                Text(word.category.title)
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            
            if !word.germanAlt.isEmpty {
                HStack(alignment: .top) {
                    Label("Alt German", systemImage: "text.bubble")
                        .font(Theme.Typography.caption)
                    Spacer()
                    Text(word.germanAlt.joined(separator: ", "))
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.Colors.textSecondary)
                        .multilineTextAlignment(.trailing)
                }
            }
            
            if !word.vietnameseAlt.isEmpty {
                HStack(alignment: .top) {
                    Label("Alt Vietnamese", systemImage: "text.bubble")
                        .font(Theme.Typography.caption)
                    Spacer()
                    Text(word.vietnameseAlt.joined(separator: ", "))
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.Colors.textSecondary)
                        .multilineTextAlignment(.trailing)
                }
            }
        }
        .padding(Theme.Spacing.m)
    }
}
