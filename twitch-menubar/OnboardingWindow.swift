//
//  OnboardingWindow.swift
//  twitch-menubar
//
//  Created by Anuraag Warudkar on 2/7/25.
//

import SwiftUI

struct OnboardingView: View {
    var window: NSWindow?
    
    var body: some View {
        VStack(spacing: 20) {
            Text("welcome to twitch-menubar!")
                .font(.title)
            Button("get started") {
                UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
                UserDefaults.standard.synchronize()
                window?.close()
            }
        }
        .padding()
        .frame(width: 350, height: 200)
    }
}

struct OnboardingWindow {
    static func show() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y:0, width: 400, height: 300),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.center()
        window.isReleasedWhenClosed = false
        window.contentView = NSHostingView(rootView: OnboardingView(window: window))
        window.makeKeyAndOrderFront(nil)
        
        NSApplication.shared.activate(ignoringOtherApps: false)
        
    }
}

