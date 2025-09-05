import SwiftUI

struct QuizSetupView: View {
    @EnvironmentObject var appState: AppState
    @ObservedObject var vm: QuizViewModel

    private let quickSizes: [Int] = [5, 10, 20]

    private var coreAvailableCount: Int {
        appState.unlearnedWords.isEmpty ? appState.allWords.count : appState.unlearnedWords.count
    }
    private var vyvuCount: Int {
        WordsSource.loadVyvuFromBundle()?.count ?? 0
    }

    var body: some View {
        Form {
            // 1) Choose deck
            Section("Deck") {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(QuizDeck.allCases) { deck in
                        SelectableRow(
                            title: deck.title,
                            subtitle: deckSubtitle(for: deck),
                            isSelected: vm.chosenDeck == deck
                        ) { vm.chosenDeck = deck }
                    }
                }
            }

            // 2) Direction
            Section("Direction") {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(QuizDirection.allCases) { dir in
                        SelectableRow(
                            title: dir.title,
                            subtitle: dirSubtitle(for: dir),
                            isSelected: vm.chosenDirection == dir
                        ) { vm.chosenDirection = dir }
                    }
                }
            }

            // 3) Number of words
            Section("Number of words") {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(quickSizes, id: \.self) { n in
                            PillButton(text: "\(n)", isSelected: vm.selectedSize == n) {
                                vm.selectedSize = n
                                vm.customSize = ""
                            }
                        }
                        PillButton(text: "All", isSelected: vm.useAllWords) {
                            vm.selectedSize = -1
                            vm.customSize = ""
                        }
                    }
                    .padding(.vertical, 4)
                }

                HStack {
                    TextField("Custom size (number)", text: $vm.customSize)
                        .keyboardType(.numberPad)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                    if !vm.customSize.isEmpty {
                        Button {
                            vm.customSize = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }

                infoNote
            }

            // Start
            Section {
                Button {
                    vm.startSession()
                } label: {
                    HStack { Spacer(); Text("Start Quiz").font(.headline); Spacer() }
                }
                .buttonStyle(.borderedProminent)
                .disabled(!vm.canStart)
            }
        }
        .navigationTitle("Quick setup")
        .onAppear { vm.configure(appState: appState) }
    }

    // MARK: - Helpers

    private func deckSubtitle(for deck: QuizDeck) -> String? {
        switch deck {
        case .core:
            return "Use common words. Available now: \(coreAvailableCount) not-learned."
        case .vyvu:
            return vyvuCount > 0
                ? "Uses Vyvu deck (\(vyvuCount) words)."
                : "Vyvu deck is empty. Add words to vyvu_words.json."
        }
    }

    private func dirSubtitle(for dir: QuizDirection) -> String? {
        switch dir {
        case .deToVi: return "You answer in Vietnamese."
        case .viToDe: return "You answer in German."
        }
    }

    private var infoNote: some View {
        VStack(alignment: .leading, spacing: 4) {
            if vm.chosenDeck == .vyvu {
                Text(vyvuCount > 0
                     ? "Selected deck: Vyvu (\(vyvuCount) words)."
                     : "No Vyvu words found. Add entries to vyvu_words.json.")
                    .font(.footnote).foregroundStyle(.secondary)
            } else {
                Text("Selected deck: Core • Available now: \(coreAvailableCount) not-learned word\(coreAvailableCount == 1 ? "" : "s").")
                    .font(.footnote).foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Small reusable pill button

private struct PillButton: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.callout).bold()
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    Capsule(style: .continuous)
                        .fill(isSelected ? Color.accentColor.opacity(0.18) : Color.gray.opacity(0.12))
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Selectable row component

private struct SelectableRow: View {
    let title: String
    let subtitle: String?
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                    .imageScale(.large)
                    .foregroundStyle(isSelected ? Color.accentColor : .secondary)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(.body).fontWeight(.semibold)
                    if let subtitle, !subtitle.isEmpty {
                        Text(subtitle).font(.footnote).foregroundStyle(.secondary)
                    }
                }
                Spacer(minLength: 0)
            }
            .contentShape(Rectangle())
            .padding(.vertical, 6)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    let app = AppState()
    let vm = QuizViewModel()
    return NavigationStack {
        QuizSetupView(vm: vm)
            .environmentObject(app)
    }
}
