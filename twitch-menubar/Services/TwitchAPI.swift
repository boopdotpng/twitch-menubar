//
//  TwitchAPI.swift
//  twitch-menubar
//
//  Created by Anuraag Warudkar on 2/7/25.
//
import Foundation
import SwiftData

class TwitchAPI {
    private let baseURL = "https://api.twitch.tv/helix"
    private let clientID = "7qw2aa2bt6tnbmme4njhb9y5woucfk"
    private var accessToken: String {
        UserDefaults.standard.string(forKey: "twitch_access_token") ?? ""
    }
}

extension TwitchAPI {
    func fetchFollowedLiveChannels(context: ModelContext, completion: @escaping (Result<[FollowedChannel], Error>) -> Void) {
        guard let userID = getStoredUserID(context: context) else {
            completion(.failure(NSError(domain: "No stored userId", code: 401)))
            return
        }

        var urlComponents = URLComponents(string: "\(baseURL)/streams/followed")!
        urlComponents.queryItems = [
            URLQueryItem(name: "user_id", value: userID),
            URLQueryItem(name: "first", value: "100")
        ]

        guard let url = urlComponents.url else {
            completion(.failure(NSError(domain: "bad url", code: 0)))
            return
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue(clientID, forHTTPHeaderField: "Client-ID")

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0)))
                return
            }

            // debug log
            if let responseString = String(data: data, encoding: .utf8) {
                print("raw api response: \(responseString)")
            }

            do {
                let response = try JSONDecoder().decode(FollowedStreamsResponse.self, from: data)
                let channels = response.data.map { stream in
                    FollowedChannel(
                        name: stream.userName,
                        liveSince: self.iso8601Date(from: stream.startedAt),
                        link: "https://twitch.tv/\(stream.userLogin)",
                        title: stream.title,
                        gameName: stream.gameName,
                        viewerCount: stream.viewerCount
                    )
                }
                completion(.success(channels))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    func getStoredUserID(context: ModelContext) -> String? {
        let fetchDescriptor = FetchDescriptor<UserSettings>()
        return (try? context.fetch(fetchDescriptor).first?.userId)
    }

    private func iso8601Date(from string: String) -> Date {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: string) ?? Date()
    }
}
extension TwitchAPI {
    func fetchUserID(context: ModelContext, completion: @escaping (Result<String, Error>) -> Void) {
        guard !accessToken.isEmpty else {
            completion(.failure(NSError(domain: "No access token", code: 401)))
            return
        }

        let url = URL(string: "\(baseURL)/users")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue(clientID, forHTTPHeaderField: "Client-ID")

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0)))
                return
            }

            do {
                let response = try JSONDecoder().decode(UserProfileResponse.self, from: data)
                if let userId = response.data.first?.id {
                    let settings = UserSettings(userId: userId)
                    context.insert(settings)
                    try? context.save()
                    completion(.success(userId))
                } else {
                    completion(.failure(NSError(domain: "No user found", code: 404)))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

extension TwitchAPI {
    func newUserInit(context: ModelContext, completion: @escaping (Result<Void, Error>) -> Void) {
        clearStoredData(context: context)

        fetchUserID(context: context) { result in
            switch result {
            case .success(let userId):
                print("Fetched user ID:", userId)
                
                // step 3: fetch followed live channels
                self.fetchFollowedLiveChannels(context: context) { result in
                    switch result {
                    case .success(let channels):
                        for channel in channels {
                            context.insert(channel)
                        }

                        do {
                            try context.save()
                            completion(.success(()))
                        } catch {
                            completion(.failure(error))
                        }
                        
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func clearStoredData(context: ModelContext) {
        do {
            let fetchDescriptor1 = FetchDescriptor<UserSettings>()
            let fetchDescriptor2 = FetchDescriptor<FollowedChannel>()

            let existingUserSettings = try context.fetch(fetchDescriptor1)
            let existingFollowedChannels = try context.fetch(fetchDescriptor2)

            for user in existingUserSettings {
                context.delete(user)
            }
            for channel in existingFollowedChannels {
                context.delete(channel)
            }
            
            try context.save()
            print("Cleared all stored data")
        } catch {
            print("Failed to clear stored data:", error)
        }
    }
}
struct FollowedStreamsResponse: Codable {
    let data: [Stream]
    let pagination: Pagination?
    
    struct Stream: Codable {
        let id: String
        let userID: String
        let userLogin: String
        let userName: String
        let gameName: String
        let title: String
        let viewerCount: Int
        let startedAt: String
        
        enum CodingKeys: String, CodingKey {
            case id
            case userID = "user_id"
            case userLogin = "user_login"
            case userName = "user_name"
            case gameName = "game_name"
            case title
            case viewerCount = "viewer_count"
            case startedAt = "started_at"
        }
    }
    
    struct Pagination: Codable {
        let cursor: String?
    }
}

struct UserProfileResponse: Codable {
    let data: [UserProfile]
    
    struct UserProfile: Codable {
        let id: String
        
        enum CodingKeys: String, CodingKey {
            case id
        }
    }
}
