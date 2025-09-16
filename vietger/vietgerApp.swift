import SwiftUI

@main
struct VyvuApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var appEnvironment = AppEnvironment()
    
    init() {
        UIConfiguration.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(appState)
                .environmentObject(appEnvironment)
                .preferredColorScheme(.light)
        }
    }
}

// MARK: - UI Configuration
enum UIConfiguration {
    static func configure() {
        configureNavigationBar()
        configureUIElements()
    }
    
    private static func configureNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        appearance.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 18, weight: .semibold)
        ]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    private static func configureUIElements() {
        UITextField.appearance().tintColor = UIColor(Theme.Colors.primary)
        UISwitch.appearance().onTintColor = UIColor(Theme.Colors.primary)
    }
}
