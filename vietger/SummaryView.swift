import SwiftUI

struct SummaryView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    let sessionWords: [Word]
    let correctIDs: Set<String>

    @State private var selectedTab: Tab = .open

    enum Tab { case correct, open }

    var body: some View {
        VStack(spacing: 16) {
            // MARK: - Progress bar
            let progress = sessionWords.isEmpty ? 0 :
                Double(correctIDs.count) / Double(sessionWords.count)

            ProgressView(value: progress)
                .progressViewStyle(.linear)
                .tint(.blue)
                .padding(.horizontal)

            // Always compute from session
            let correctWords = sessionWords.filter { correctIDs.contains($0.id) }
            let openWords    = sessionWords.filter { !correctIDs.contains($0.id) }

            Text("Session Summary")
                .font(.title2).bold()

            // Stats cards
            HStack {
                summaryStat(title: "Correct", value: correctWords.count, color: .green)
                    .onTapGesture { selectedTab = .correct }
                summaryStat(title: "Open", value: openWords.count, color: .orange)
                    .onTapGesture { selectedTab = .open }
            }

            // MARK: - Word lists
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    if selectedTab == .correct {
                        if correctWords.isEmpty {
                            Text("No correct words yet.")
                                .foregroundStyle(.secondary)
                        } else {
                            Text("✅ Correct").font(.headline)
                            ForEach(correctWords) { w in
                                summaryRow(left: w.german, right: w.vietnamese)
                            }
                        }
                    } else {
                        if openWords.isEmpty {
                            // Congratulations if everything is learned
                            Text("🎉 Great job! Everything in this session is learned.")
                                .font(.headline)
                                .foregroundStyle(.green)
                                .padding(.top)
                        } else {
                            Text("🟠 To Review").font(.headline)
                            ForEach(openWords) { w in
                                summaryRow(left: w.german, right: w.vietnamese)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }

            // MARK: - Always visible Close button
            Button {
                dismiss()
            } label: {
                Text("Close quiz")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .bold()
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(.horizontal)
            .padding(.bottom, 12)
        }
        .navigationTitle("Summary")
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .interactiveDismissDisabled(true)
    }
}

// MARK: - Local UI helpers
private extension SummaryView {
    func summaryStat(title: String, value: Int, color: Color) -> some View {
        VStack {
            Text("\(value)").font(.title2).bold().foregroundStyle(color)
            Text(title).font(.caption)
        }
        .frame(maxWidth: .infinity).padding()
        .background(selectedTabBackground(title: title))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    func selectedTabBackground(title: String) -> some ShapeStyle {
        if (title == "Correct" && selectedTab == .correct) ||
           (title == "Open" && selectedTab == .open) {
            return Color.blue.opacity(0.15)
        } else {
            return Color(.systemBackground).opacity(0.5)
        }
    }

    func summaryRow(left: String, right: String) -> some View {
        HStack {
            Text(left).bold()
            Spacer()
            Text(right).foregroundStyle(.secondary)
        }
        .padding(10)
        .background(Color.gray.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
