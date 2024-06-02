//
//  Constants .swift
//  twitch-menubar
//
//  Created by anu on 6/1/24.
//

import Foundation

public extension String {
  func urlEncode() -> String? {
    let allowedCharacters = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~=&")
    return addingPercentEncoding(withAllowedCharacters: allowedCharacters)
  }
}


struct K {
  struct TwitchIdents {
    static let base_url = "https://id.twitch.tv/oauth2/authorize?"
    static let scopes = ["user:read:follows"].joined(separator: "&") // maybe we need more in the future
    static let client_id = "7qw2aa2bt6tnbmme4njhb9y5woucfk"
    static let redirect_uri = "http://localhost:3000/twitch-redirect"
    static let state = generate_state()
    
    static func generate_state(length len: Int = 32) -> String {
      // random state generation to prevent csrf attacks
      let possible_chars = "abcdefghijklmnopqrstuvwxyz0123456789"
      return String((0..<len).compactMap { _ in possible_chars.randomElement()})
    }
    
    static func generate_auth_url() -> String {
      base_url + "response_type=token&client_id=\(client_id)&redirect_uri=\(redirect_uri)&scope=\(scopes)&state=\(state)"
        .urlEncode()!
    }
  }
}
