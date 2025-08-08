//
//  vietgerApp.swift
//  vietger
//
//  Created by Nghia on 08.08.2025.
//

import SwiftUI

@main
struct vietgerApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
        }
    }
}

