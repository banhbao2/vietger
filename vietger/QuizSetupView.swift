import SwiftUI

struct QuizSetupView: View {
    @EnvironmentObject var appState: AppState
    @ObservedObject var vm: QuizViewModel

    // Quick sizes; “All” is handled via vm.useAllWords (selectedSize == -1)
    private let quickSizes: [Int] = [5, 10, 20]

    // Counts (prefer not-learned; fall back to total)
    private var coreAvailableCount: Int {
        appState.unlearnedWords.isEmpty ? appState.allWords.count : appState.unlearnedWords.count
    }
    private var vyvuAvailableCount: Int {
        appState.unlearnedVyvu.isEmpty ? appState.vyvuWords.count : appState.unlearnedVyvu.count
    }

    var body: some View {
        Form {
            // 1) Direction (includes .vyvuStudy)
            Section("Direction") {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(QuizDirection.allCases) { dir in
                        SelectableRow(
                            title: dir.title,
                            subtitle: subtitle(for: dir),
                            isSelected: vm.chosenDirection == dir
                        ) { vm.chosenDirection = dir }
                    }
                }
            }

            // 2) Number of words
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

            // 3) Start
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

    private func subtitle(for dir: QuizDirection) -> String {
        switch dir {
        case .deToVi:
            return "You answer in Vietnamese."
        case .viToDe:
            return "You answer in German."
        case .vyvuStudy:
            return vyvuAvailableCount > 0
                ? "Uses the Vyvu list (\(vyvuAvailableCount) not-learned available)."
                : "Vyvu list is empty. Add words to vyvu_words.json."
        }
    }

    private var infoNote: some View {
        VStack(alignment: .leading, spacing: 4) {
            if vm.chosenDirection == .vyvuStudy {
                Text(vyvuAvailableCount > 0
                     ? "Selected: Vyvu • \(vyvuAvailableCount) not-learned."
                     : "No Vyvu words found. Add entries to vyvu_words.json.")
                .font(.footnote).foregroundStyle(.secondary)
            } else {
                Text("Selected: Core • \(coreAvailableCount) not-learned.")
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
