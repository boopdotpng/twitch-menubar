//
//  SettingsView.swift
//  twitch-menubar
//
//  Created by Anuraag Warudkar on 2/7/25.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        VStack {
            Text("settings")
                .font(.title)
                .padding()
            
            Toggle("notifications?", isOn: .constant(true))
                .padding()
            
            Button("close settings") {
                NSApp.sendAction(#selector(NSApplication.hide(_:)), to: nil, from: nil)
            }
        }
        .frame(width: 300, height: 200)
        .padding()
    }
}

