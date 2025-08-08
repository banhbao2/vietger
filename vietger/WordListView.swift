import SwiftUI

struct WordListView: View {
    @EnvironmentObject var appState: AppState

    @State private var showResetAlert = false
    @State private var searchText = ""
    @State private var filterSelection: FilterType = .all

    enum FilterType: String, CaseIterable, Identifiable {
        case all = "All"
        case learned = "Learned"
        case notLearned = "Not Learned"
        var id: String { rawValue }
    }

    // Filtered list (by search + learned state)
    private var filteredWords: [Word] {
        appState.allWords.filter { w in
            let matchesSearch =
                searchText.isEmpty ||
                w.german.localizedCaseInsensitiveContains(searchText) ||
                w.vietnamese.localizedCaseInsensitiveContains(searchText)

            let isLearned = appState.learnedIDs.contains(w.id)
            let matchesFilter: Bool = {
                switch filterSelection {
                case .all: return true
                case .learned: return isLearned
                case .notLearned: return !isLearned
                }
            }()

            return matchesSearch && matchesFilter
        }
    }

    // Group by word.category (now provided by the model)
    private var grouped: [(cat: Category, words: [Word])] {
        let groups = Dictionary(grouping: filteredWords, by: { $0.category })
        return Category.ordered
            .compactMap { cat in
                guard let items = groups[cat] else { return nil }
                let sortedItems = items.sorted { $0.german.localizedCompare($1.german) == .orderedAscending }
                return (cat, sortedItems)
            }
    }

    var body: some View {
        List {
            // Reset row
            Section {
                Button(role: .destructive) { showResetAlert = true } label: {
                    HStack {
                        Image(systemName: "arrow.counterclockwise")
                        Text("Reset all progress")
                    }
                }
            }

            // Filter control
            Section {
                Picker("Filter", selection: $filterSelection) {
                    ForEach(FilterType.allCases) { f in
                        Text(f.rawValue).tag(f)
                    }
                }
                .pickerStyle(.segmented)
            }

            // Grouped word sections
            ForEach(grouped, id: \.cat) { section in
                Section(section.cat.title) {
                    ForEach(section.words) { w in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(w.german).bold()
                                Text(w.vietnamese).foregroundStyle(.secondary)
                            }
                            Spacer()
                            if appState.learnedIDs.contains(w.id) {
                                Label("Learned", systemImage: "checkmark.seal.fill")
                                    .labelStyle(.iconOnly)
                                    .foregroundStyle(.green)
                                    .accessibilityLabel("Learned")
                            } else {
                                Label("Not learned", systemImage: "circle")
                                    .labelStyle(.iconOnly)
                                    .foregroundStyle(.secondary)
                                    .accessibilityLabel("Not learned")
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture { appState.toggleLearned(w) }
                        .swipeActions(edge: .trailing) {
                            if appState.learnedIDs.contains(w.id) {
                                Button("Unlearn") { appState.markUnlearned(w) }.tint(.orange)
                            } else {
                                Button("Learned") { appState.markLearned(w) }.tint(.green)
                            }
                        }
                        .contextMenu {
                            if appState.learnedIDs.contains(w.id) {
                                Button("Mark as NOT learned") { appState.markUnlearned(w) }
                            } else {
                                Button("Mark as learned") { appState.markLearned(w) }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Word List")
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .automatic))
        .alert("Reset all progress?", isPresented: $showResetAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) { appState.resetAllProgress() }
        } message: {
            Text("This will mark all words as not learned.")
        }
    }
}

#Preview {
    WordListView().environmentObject(AppState())
}
