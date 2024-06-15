//
//  User.swift
//  twitch-menubar
//
//  Created by anu on 6/1/24.
//

import Foundation
import SwiftData

@Model
final class Streamer {
  var name: String;
  var url: String;
  var live: Bool;
  var notifying: Bool;
  
  init(name: String, url: String, live: Bool, notifying: Bool) {
    self.name = name
    self.url = url
    self.live = live
    self.notifying = notifying
  }
}


@Model
final class User {
  var is_setup: Bool;
  var access_token: String;
  var streamers: [Streamer];
  var error: Bool;
  
  init(is_setup: Bool=false, error: Bool = false, access_token: String, streamers: [Streamer] = []) {
    self.is_setup = is_setup
    self.access_token = access_token
    self.streamers = streamers
    self.error = error
    
    fetchData()
  }
  
  private func fetchData() -> Void {
    let api = TwitchApi(access_token: access_token)
    print("fetching data with access token: \(access_token)")
    is_setup = true
    
    Task {
      api.getAllInfo()
    }
  }
  
  
}

