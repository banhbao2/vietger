import SwiftUI

struct WordListView: View {
    @EnvironmentObject var appState: AppState

    // Deck selector
    enum DeckChoice: String, CaseIterable, Identifiable {
        case core = "Most common"
        case vyvu = "Vyvu"
        var id: String { rawValue }
        var title: String {
            self == .core ? "Most common used words" : "Studying for Vyvu"
        }
    }
    @State private var deck: DeckChoice = .core

    // Filter segmented
    enum Filter: String, CaseIterable, Identifiable {
        case all = "All"
        case learned = "Learned"
        case notLearned = "Not Learned"
        var id: String { rawValue }
    }
    @State private var filter: Filter = .all

    @State private var showResetAlert = false

    var body: some View {
        List {
            // Deck picker
            Section {
                Picker("Word list", selection: $deck) {
                    Text(DeckChoice.core.title).tag(DeckChoice.core)
                    Text(DeckChoice.vyvu.title).tag(DeckChoice.vyvu)
                }
                .pickerStyle(.segmented)
            }

            // Reset progress
            Section {
                Button(role: .destructive) {
                    showResetAlert = true
                } label: {
                    Label("Reset all progress", systemImage: "arrow.counterclockwise")
                        .fontWeight(.semibold)
                }
            }

            // Filter segmented
            Section {
                SegmentedFilter(filter: $filter)
            }

            // Word list
            if groupedWords.isEmpty {
                Section { Text("No words found.") }
            } else {
                ForEach(groupedWords.keys.sorted(), id: \.self) { header in
                    Section(header: Text(header.uppercased())
                        .font(.caption)
                        .foregroundStyle(.secondary)) {
                        ForEach(groupedWords[header] ?? []) { w in
                            row(for: w)
                                .swipeActions(edge: .trailing) {
                                    if appState.isLearned(w, forVyvu: deck == .vyvu) {
                                        Button("Unlearn", role: .destructive) {
                                            appState.markUnlearned(w, forVyvu: deck == .vyvu)
                                        }
                                    } else {
                                        Button("Learned") {
                                            appState.markLearned(w, forVyvu: deck == .vyvu)
                                        }
                                        .tint(.green)
                                    }
                                }
                        }
                    }
                }
            }
        }
        .navigationTitle("Word List")
        .alert("Reset all progress?", isPresented: $showResetAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                appState.resetLearned(forVyvu: deck == .vyvu)
            }
        } message: {
            Text(deck == .core
                 ? "This will mark all 'Most common used words' as not learned."
                 : "This will mark all 'Vyvu' words as not learned.")
        }
    }

    // MARK: - Data helpers

    private var sourceWords: [Word] {
        deck == .core ? appState.allWords : appState.vyvuWords
    }

    private var filteredWords: [Word] {
        switch filter {
        case .all:
            return sourceWords
        case .learned:
            return sourceWords.filter { appState.isLearned($0, forVyvu: deck == .vyvu) }
        case .notLearned:
            return sourceWords.filter { !appState.isLearned($0, forVyvu: deck == .vyvu) }
        }
    }

    private var groupedWords: [String: [Word]] {
        let groups = Dictionary(grouping: filteredWords, by: { categoryKey(for: $0) })
        return groups.isEmpty ? ["All words": filteredWords] : groups
    }

    /// Safely extract a category name if available in Word.
    private func categoryKey(for w: Word) -> String {
        for child in Mirror(reflecting: w).children {
            if child.label == "category", let s = child.value as? String,
               !s.trimmingCharacters(in: .whitespaces).isEmpty {
                return s
            }
        }
        return "All words"
    }

    // MARK: - Row

    private func row(for w: Word) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(w.german).font(.headline)
                Text(w.vietnamese).font(.subheadline).foregroundStyle(.secondary)
            }
            Spacer()
            if appState.isLearned(w, forVyvu: deck == .vyvu) {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundStyle(.green)
            } else {
                Image(systemName: "circle")
                    .foregroundStyle(.secondary)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if appState.isLearned(w, forVyvu: deck == .vyvu) {
                appState.markUnlearned(w, forVyvu: deck == .vyvu)
            } else {
                appState.markLearned(w, forVyvu: deck == .vyvu)
            }
        }
    }
}

// MARK: - Small segmented control (All / Learned / Not Learned)
private struct SegmentedFilter: View {
    @Binding var filter: WordListView.Filter

    var body: some View {
        HStack(spacing: 0) {
            segment(.all)
            divider
            segment(.learned)
            divider
            segment(.notLearned)
        }
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
    }

    private func segment(_ kind: WordListView.Filter) -> some View {
        Button {
            filter = kind
        } label: {
            Text(kind.rawValue)
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(filter == kind ? Color.gray.opacity(0.15) : .clear)
                        .padding(2)
                )
        }
        .buttonStyle(.plain)
    }

    private var divider: some View {
        Rectangle()
            .fill(Color.secondary.opacity(0.25))
            .frame(width: 1, height: 20)
            .padding(.vertical, 6)
    }
}
