import SwiftUI

struct SummaryView: View {
    @EnvironmentObject var appState: AppState
    
    let sessionWords: [Word]
    let correctIDs: Set<String>
    let openIDs: Set<String>
    let onClose: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                let correctWords = sessionWords.filter { correctIDs.contains($0.id) }
                let openWords = sessionWords.filter { openIDs.contains($0.id) }
                
                Text("Session summary").font(.title2).bold()
                
                HStack {
                    summaryStat(title: "Correct", value: correctWords.count, color: .green)
                    summaryStat(title: "Open", value: openWords.count, color: .orange)
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
                }
                
                Button {
                    onClose()
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
