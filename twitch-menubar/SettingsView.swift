//
//  SettingsView.swift
//  twitch-menubar
//
//  Created by anu on 6/1/24.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
  
  @Environment(\.modelContext) var modelContext
  @Query var user : [User]
  
  var body: some View {
    let text = user.count == 0 || !user[0].is_setup ? "you are not logged in" : "hello, user"
    
    Text(text)
        .onOpenURL { incomingURL in
          print("app was opened via url: \(incomingURL)")
          handleURL(incomingURL)
        }
   
    }
  
  private func handleURL(_ url: URL) {
    guard url.scheme == "twich-menubar" else {
      return
    }
    guard url.pathComponents.count == 2 else {
      print("invalid url")
      return
    }
   
    // update access token and do data fetching here
    
    
  }
  
}
