//
//  api.swift
//  twitch-menubar
//
//  Created by anu on 6/2/24.
//

import Foundation

typealias JSONDict = [String: String]

struct UserResponse: Decodable {
  var data: [JSONDict]
}

class TwitchApi {
  static let base_url = URL(string: "https://api.twitch.tv/helix/")!
  var access_token: String
  static let client_id = K.TwitchIdents.client_id
  static let session = URLSession.shared
  
  init(access_token: String) {
    self.access_token = access_token
  }
  
  public func getUser() async throws -> JSONDict {
    print("getUser function called")
    
    var request = URLRequest(url: TwitchApi.base_url.appendingPathComponent("users"))
    request.setValue("Bearer \(access_token)", forHTTPHeaderField: "Authorization")
    request.setValue(TwitchApi.client_id, forHTTPHeaderField: "Client-Id")
    
    do {
      let (data, response) = try await TwitchApi.session.data(for: request)
      print("data received: \(data)")
      
      guard let httpResponse = response as? HTTPURLResponse else {
        print("response is not HTTPURLResponse")
        throw URLError(.badServerResponse)
      }
      
      print("httpResponse status code: \(httpResponse.statusCode)")
      
      if httpResponse.statusCode != 200 {
        print("bad server response, status code: \(httpResponse.statusCode)")
        throw URLError(.badServerResponse)
      }
      
      let userResponse = try JSONDecoder().decode(UserResponse.self, from: data)
      print("decoded user response: \(userResponse)")
      
      guard let userData = userResponse.data.first else {
        print("no user data found")
        throw URLError(.cannotDecodeContentData)
      }
      
      return userData
    } catch {
      print("error: \(error)")
      throw error
    }
  }
}
