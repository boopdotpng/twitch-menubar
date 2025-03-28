//
//  OnboardingWindow.swift
//  twitch-menubar
//
//  Created by Anuraag Warudkar on 2/7/25.
//

import SwiftUI
import SwiftData

struct OnboardingView: View {
    var window: NSWindow?
    @State private var oauthServer = OAuthServer()
    @State private var isLoggedIn = false
    @State private var displayName: String? = nil
    var context: ModelContext

    var body: some View {
        VStack(spacing: 20) {
            Text("welcome to twitch-menubar!")
                .font(.title)

            if !isLoggedIn {
                Button("login with twitch") {
                    oauthServer.onTokenReceived = { token in
                        UserDefaults.standard.set(token, forKey: "twitch_access_token")
                        
                        DispatchQueue.main.async {
                            isLoggedIn = true
                        }
                        TwitchAPI().newUserInit(context: context) {result in
                            
                        }
                    }
                    oauthServer.start()
                    NSWorkspace.shared.open(TwitchAuth.generateOAuthURL())
                }
            } else {
                Text("logged in! check your menu bar.")
            }
        }
        .padding()
        .frame(width: 350, height: 250)
    }
}
struct OnboardingWindow {
    static func show() {
        let container = try! ModelContainer(for: UserSettings.self, FollowedChannel.self)
        let context = ModelContext(container)
        
        let window = NSWindow(
            contentRect: NSRect(x: 0, y:0, width: 400, height: 300),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.center()
        window.isReleasedWhenClosed = false
        window.contentView = NSHostingView(rootView: OnboardingView(window: window, context: context))
        window.makeKeyAndOrderFront(nil)
        
        NSApplication.shared.activate(ignoringOtherApps: false)
        
    }
}

