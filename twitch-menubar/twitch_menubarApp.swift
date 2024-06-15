//
//  twitch_menubarApp.swift
//  twitch-menubar
//
//  Created by anu on 5/19/24.
//

import SwiftUI
import SwiftData

@main
struct twitch_menubarApp: App {
  
  let auth_url = K.TwitchIdents.generate_auth_url()
  @Environment(\.openWindow) private var openWindow
  
    var body: some Scene {
      MenuBarExtra("where?", systemImage: "1.circle") {
        Link("login with twitch", destination: URL(string:auth_url)!)
          
        Divider()
        
        Button("preferences") {
          openWindow(id: "preferences")
        }.keyboardShortcut(",")

        Button("quit") {
          NSApplication.shared.terminate(nil)
        }.keyboardShortcut("q")
      }
      
      Window("preferences", id:"preferences"){
        SettingsView()
      }
      .modelContainer(for: User.self)
    }
}
