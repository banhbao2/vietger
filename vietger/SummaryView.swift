import SwiftUI

struct SummaryView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    let sessionWords: [Word]
    let correctIDs: Set<String>
    let openIDs: Set<String>   // kept for compatibility, but not used for display
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Always compute from the session: OPEN = all − correct
                let correctWords = sessionWords.filter { correctIDs.contains($0.id) }
                let openWords    = sessionWords.filter { !correctIDs.contains($0.id) }

                Text("Session summary")
                    .font(.title2).bold()

                HStack {
                    summaryStat(title: "Correct", value: correctWords.count, color: .green)
                    summaryStat(title: "Open",    value: openWords.count,    color: .orange)
                }

                if !correctWords.isEmpty {
                    Text("✅ Correct").font(.headline)
                    ForEach(correctWords) { w in
                        summaryRow(left: w.german, right: w.vietnamese)
                    }
                }

                if !openWords.isEmpty {
                    Text("🟠 Open").font(.headline)
                    ForEach(openWords) { w in
                        summaryRow(left: w.german, right: w.vietnamese)
                    }
                } else if !sessionWords.isEmpty {
                    // Optional: tiny friendly message if everything was learned
                    Text("🎉 Great job! Everything in this session is learned.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Button {
                    dismiss()   // back to Home
                } label: {
                    Text("Close quiz")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .bold()
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.top, 8)
            }
            .padding()
        }
        .navigationTitle("Summary")
        .navigationBarBackButtonHidden(true)   // hide back arrow
        .toolbar(.hidden, for: .navigationBar) // (optional) hide whole bar
        .interactiveDismissDisabled(true)      // block swipe-back gesture
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
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
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
