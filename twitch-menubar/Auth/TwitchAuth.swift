//
//  TwitchAuth.swift
//  twitch-menubar
//
//  Created by Anuraag Warudkar on 2/8/25.
//

import Foundation

struct TwitchAuth {
    static let clientID = "7qw2aa2bt6tnbmme4njhb9y5woucfk"
    static let RedirectURI = "http://localhost:8080/callback"
    static let scopes = "user:read:follows user:read:email openid"
    
    static func generateOAuthURL() -> URL {
        let authURL = "https://id.twitch.tv/oauth2/authorize?client_id=\(clientID)&redirect_uri=\(RedirectURI)&response_type=token&scope=\(scopes)"
        return URL(string: authURL)!
    }
}

extension TwitchAuth {
    static func handleOAuthCallback(url: URL) {
        guard let fragment = url.fragment,
              let tokenParam = fragment.split(separator: "&").first(where: { $0.hasPrefix("access_token=") }),
              let token = tokenParam.split(separator: "=").last else { return }
        
        UserDefaults.standard.set(String(token), forKey: "twitch_access_token")
        NotificationCenter.default.post(name: .didCompleteLogin, object: nil);
    }
}

extension Notification.Name {
    static let didCompleteLogin = Notification.Name("didCompleteLogin")
}
