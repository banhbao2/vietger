import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(colors: [Color(hex: "#6C63FF"), Color(hex: "#8E7CFF")],
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
                    .ignoresSafeArea()

                ScrollView {
                    // App Name (fancy logo style)
                    Text("Vyvu")
                        .font(.custom("SnellRoundhand-Bold", size: 42)) // Use your own font name if added to project
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 2)
                        .kerning(2) // slight spacing between letters
                        .padding(.top, 20)

                    VStack(alignment: .leading, spacing: 28) {

                        // Greeting section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("👋 Xin chào bạn")
                                .font(.title3)
                                .foregroundColor(.white.opacity(0.85))
                            Text("Ready to learn some German?")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)

                        // Stats row
                        HStack(spacing: 12) {
                            statCard(title: "Total", value: appState.allWords.count, color: .white)
                            statCard(title: "Learned", value: appState.learnedIDs.count, color: Color(hex: "#00FF7F"))
                            statCard(title: "Remaining", value: appState.allWords.count - appState.learnedIDs.count, color: .red)
                        }
                        .padding(.horizontal)

                        // Action cards
                        VStack(spacing: 20) {
                            NavigationLink(destination: QuizView().environmentObject(appState)) {
                                actionCard(
                                    title: "Start Quiz",
                                    subtitle: "Test your skills",
                                    systemImage: "play.circle.fill",
                                    color: .white
                                )
                            }

                            NavigationLink(destination: WordListView().environmentObject(appState)) {
                                actionCard(
                                    title: "Word List",
                                    subtitle: "Browse and manage vocabulary",
                                    systemImage: "list.bullet",
                                    color: .white
                                )
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)

                        Spacer(minLength: 40)
                    }
                    // Footer note
                    Text("Made by Nghia")
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.7))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom, 10)

                }
            }
        }
    }

    // MARK: - Stat Card
    private func statCard(title: String, value: Int, color: Color) -> some View {
        VStack {
            Text("\(value)")
                .font(.title2)
                .bold()
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.85))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
    }

    // MARK: - Action Card Component
    private func actionCard(title: String, subtitle: String, systemImage: String, color: Color) -> some View {
        HStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 56, height: 56)
                Image(systemName: systemImage)
                    .font(.system(size: 28))
                    .foregroundColor(color)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(color)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(color.opacity(0.8))
            }
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(color.opacity(0.5))
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Hex Color Extension
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >> 8) & 0xFF) / 255
        let b = Double(rgb & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

#Preview {
    ContentView().environmentObject(AppState())
}
