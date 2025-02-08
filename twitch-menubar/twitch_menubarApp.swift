//
//  twitch_menubarApp.swift
//  twitch-menubar
//
//  Created by Anuraag Warudkar on 2/7/25.
//

import SwiftUI
import SwiftData

class AppDelegate: NSObject, NSApplicationDelegate {
    func application(_ app: NSApplication, open urls: [URL]) {
        guard let url = urls.first else { return }
        TwitchAuth.handleOAuthCallback(url: url)
    }
}

@main
struct TwitchMenubarApp: App {
    private let hasSeenOnboarding = UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
    let authServer = OAuthServer()
    
    var body: some Scene {
        
        // TODO: stop this from launching on app launch
        Settings {
            SettingsView()
        }
        
        MenuBarExtra("twitch", systemImage: "play.circle") {
            ContentView()
            
            Divider()
            
            SettingsLink {
                Text("settings")
            }
            .keyboardShortcut(",", modifiers: [.command]);
            
            Button("quit") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q", modifiers: [.command])

        }
        
    }
    
    init() {
        authServer.start()
        NSApplication.shared.setActivationPolicy(.accessory)
        if !hasSeenOnboarding {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                OnboardingWindow.show()
            }
        }
    }
}
