import SwiftUI

struct QuizSetupView: View {
    @Binding var chosenDirection: QuizDirection?
    @Binding var selectedSize: Int?
    @Binding var customSize: String
    let canStart: Bool
    let onStart: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 6) {
                    Text("Quick Setup").font(.title2).bold()
                    Text("Practice the most commonly used words in daily conversations. Select the direction you want to study and how many words to review.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                }

                // Direction
                VStack(alignment: .leading, spacing: 12) {
                    Text("Direction").font(.headline)
                    ForEach(QuizDirection.allCases) { dir in
                        Button {
                            #if os(iOS)
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            #endif
                            chosenDirection = dir
                        } label: {
                            HStack(spacing: 12) {
                                Text(dir.title).font(.body)
                                Spacer()
                                Image(systemName: chosenDirection == dir ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(chosenDirection == dir ? .accentColor : .secondary)
                            }
                            .padding(14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(.thinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(dir.title)
                    }
                }

                // Size
                VStack(alignment: .leading, spacing: 12) {
                    Text("Number of words").font(.headline)

                    let presets = [5, 10, 25, 50, 100]
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        ForEach(presets, id: \.self) { n in
                            Button {
                                selectedSize = n
                                customSize = ""
                            } label: {
                                Text("\(n)")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .fill(selectedSize == n ? Color.accentColor.opacity(0.2) : Color.gray.opacity(0.12))
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    HStack(spacing: 10) {
                        TextField("Custom", text: $customSize)
                            .keyboardType(.numberPad)
                            .padding(10)
                            .background(Color.gray.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .onChange(of: customSize) { _, newVal in
                                if !newVal.isEmpty { selectedSize = nil }
                            }

                        Button("Clear") { customSize = "" }
                            .buttonStyle(.bordered)
                    }
                }

                Button {
                    onStart()
                } label: {
                    Label("Start quiz", systemImage: "play.fill")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(!canStart)
                .padding(.top, 6)
            }
            .padding()
        }
    }
}
