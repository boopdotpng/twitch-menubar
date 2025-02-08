//
//  twitch_menubarApp.swift
//  twitch-menubar
//
//  Created by Anuraag Warudkar on 2/7/25.
//

import SwiftUI
import SwiftData
import Foundation

class AppDelegate: NSObject, NSApplicationDelegate {
    func application(_ app: NSApplication, open urls: [URL]) {
        guard let url = urls.first else { return }
        TwitchAuth.handleOAuthCallback(url: url)
    }
}

@main
struct TwitchMenubarApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    let container: ModelContainer
    @StateObject private var menuBarManager: MenuBarManager

    init() {
        NSApplication.shared.setActivationPolicy(.accessory)
        
        let localContainer: ModelContainer
        do {
            localContainer = try ModelContainer(for: UserSettings.self, FollowedChannel.self)
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
        self.container = localContainer
        _menuBarManager = StateObject(wrappedValue: MenuBarManager(context: ModelContext(localContainer)))

        let hasSeenOnboarding = UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
        if !hasSeenOnboarding {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                OnboardingWindow.show()
                UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
            }
        }
    }
    var body: some Scene {
        Settings {
            SettingsView()
        }
    }
}
