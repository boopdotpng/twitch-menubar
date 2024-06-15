//
//  api.swift
//  twitch-menubar
//
//  Created by anu on 6/2/24.
//

import Foundation

struct UserInfo: Codable {
  let id: String
  let login: String
  let displayName: String
  let type: String
  let broadcasterType: String
  let description: String
  let profileImageUrl: String
  let offlineImageUrl: String
  let viewCount: Int
  let email: String
  let createdAt: String
  
  enum CodingKeys: String, CodingKey {
    case id, login, type, description, email
    case displayName = "display_name"
    case broadcasterType = "broadcaster_type"
    case profileImageUrl = "profile_image_url"
    case offlineImageUrl = "offline_image_url"
    case viewCount = "view_count"
    case createdAt = "created_at"
  }
}
// define api structure
struct ApiResponse: Codable {
  let data: [UserInfo]
}

class TwitchApi {
  static let base_url = URL(string: "https://api.twitch.tv/helix/")!
  var access_token: String
  static let client_id = K.TwitchIdents.client_id
  static let session = URLSession.shared
  
  init(access_token: String) {
    self.access_token = access_token
  }
  
  func getAllInfo() {
    getUser()
    
    // more functions coming
  }
  
  func getUser() {
    guard let url = URL(string: "users", relativeTo: TwitchApi.base_url) else {return}
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue("Bearer \(access_token)", forHTTPHeaderField: "Authorization")
    request.setValue(TwitchApi.client_id, forHTTPHeaderField: "Client-Id")
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
      guard let data = data, error == nil else {
        print("error: \(error?.localizedDescription ?? "unknown error")")
        return
      }
      
      // print the raw json response
      if let jsonString = String(data: data, encoding: .utf8) {
        print("Raw JSON response: \(jsonString)")
      }
      
      do {
        let apiResponse = try JSONDecoder().decode(ApiResponse.self, from: data)
        for user in apiResponse.data {
          print("User: \(user.displayName)")
        }
      } catch {
        print("error decoding response: \(error.localizedDescription)")
      }
    }
    task.resume()
  }
  
}
