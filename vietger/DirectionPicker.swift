import SwiftUI

struct DirectionPicker: View {
    @Binding var selected: QuizDirection?
    var onPicked: () -> Void  // parent decides what happens next

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text("Start studying")
                    .font(.title2).bold()
                    .accessibilityAddTraits(.isHeader)

                Text("Choose the direction you want to practice:")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.top)

            // Options
            VStack(spacing: 12) {
                ForEach(QuizDirection.allCases) { dir in
                    Button {
                        #if os(iOS)
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        #endif
                        selected = dir
                        onPicked()
                    } label: {
                        DirectionRow(direction: dir, isSelected: selected == dir)
                    }
                    .buttonStyle(.plain)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(dir.primaryTitle) // Use our safe helper
                    .accessibilityHint("Starts a quiz \(dir.accessibilityHintSuffix)")
                }
            }

            Spacer(minLength: 0)
        }
        .padding()
    }
}

private struct DirectionRow: View {
    let direction: QuizDirection
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 12) {
            Text(direction.iconEmoji)
                .font(.title3)
                .frame(width: 32, height: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(direction.primaryTitle)
                    .font(.headline)
                Text(direction.secondaryTitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.thinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(isSelected ? Color.accentColor.opacity(0.6) : Color.clear, lineWidth: 1)
        )
        .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

// MARK: - QuizDirection helpers (names chosen to avoid colliding with any existing `title`)
private extension QuizDirection {
    var iconEmoji: String {
        switch self {
        case .deToVi: return "🇩🇪"
        case .viToDe: return "🇻🇳"
        }
    }

    var primaryTitle: String {
        switch self {
        case .deToVi: return "German → Vietnamese"
        case .viToDe: return "Vietnamese → German"
        }
    }

    var secondaryTitle: String {
        "Practice the most-used everyday words"
    }

    var accessibilityHintSuffix: String {
        switch self {
        case .deToVi: return "from German to Vietnamese"
        case .viToDe: return "from Vietnamese to German"
        }
    }

    var displayTitle: String { primaryTitle }
}

// ✅ New-style Preview macro with traits
#Preview(traits: .sizeThatFitsLayout) {
    DirectionPicker(selected: .constant(nil), onPicked: {})
        .padding()
}
