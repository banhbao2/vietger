import SwiftUI

// START SCREEN
struct ContentView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationStack {
            ZStack {
                // Original blue gradient colors (restored)
                ZStack {
                    LinearGradient(
                        colors: [
                            Color(hex: "#84C4E6"), // top blue
                            Color(hex: "#4FA3D2")  // bottom blue
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                }

                VStack(alignment: .leading, spacing: 28) {
                    // App title / logo (unchanged)
                    Text("Vyvu")
                        .font(.custom("SnellRoundhand-Bold", size: 42))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 2)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 8)

                    // Greeting section (unchanged)
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

                    // 🚫 Removed the stats row (Total / Learned / Remaining)

                    // Action cards (unchanged)
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

                    Spacer()

                    // Footer (unchanged)
                    Text("Made by Nghia")
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.85))
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 8)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding(.vertical, 16)
            }
        }
    }

    // MARK: - Action Card Component (unchanged)
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
                .font(.headline)
                .foregroundColor(color.opacity(0.8))
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Hex Color Helper (unchanged)
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
