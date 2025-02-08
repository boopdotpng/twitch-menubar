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
    func fetchUserProfile(completion: @escaping (Result<UserSettings, Error>) -> Void) {
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
                if let user = response.data.first {
                    // create and pass back `UserSettings` with userID
                    let userSettings = UserSettings(
                        displayName: user.displayName,
                        profileImageUrl: user.profileImageURL,
                        userId: user.id
                    )
                    completion(.success(userSettings))
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
    func fetchFollowedChannels(userID: String, completion: @escaping (Result<[FollowedChannel], Error>) -> Void) {
        var urlComponents = URLComponents(string: "\(baseURL)/channels/followed")!
        urlComponents.queryItems = [
            URLQueryItem(name: "user_id", value: userID),
            URLQueryItem(name: "first", value: "100") // fetch max items per page
        ]

        guard let url = urlComponents.url else { return }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue(clientID, forHTTPHeaderField: "Client-ID")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0)))
                return
            }

            // log raw response for debugging
            if let responseString = String(data: data, encoding: .utf8) {
                print("Raw API Response: \(responseString)")
            }

            do {
                let response = try JSONDecoder().decode(FollowedChannelsResponse.self, from: data)
                let channels = response.data.map {
                    FollowedChannel(
                        name: $0.broadcasterName,
                        isLive: false,
                        notifyForChannel: false,
                        liveSince: .now
                    )
                }
                completion(.success(channels))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

extension TwitchAPI {
    func checkIfLive(usernames: [String], completion: @escaping (Result<[String: Bool], Error>) -> Void) {
        let joinedNames = usernames.joined(separator: "&user_login=")
        let url = URL(string: "\(baseURL)/streams?user_login=\(joinedNames)")!
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
                let response = try JSONDecoder().decode(StreamStatusResponse.self, from: data)
                let liveStatuses = usernames.reduce(into: [String: Bool]()) { result, name in
                    result[name] = response.data.contains { $0.userLogin == name }
                }
                completion(.success(liveStatuses))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

extension TwitchAPI {
    func newUserInit(context: ModelContext, completion: @escaping (Result<Void, Error>) -> Void) {
        // reset existing user data
        clearStoredUserData(context: context)

        fetchUserProfile { result in
            switch result {
            case .success(let userSettings):
                context.insert(userSettings)

                // fetch followed channels using the fetched userID
                self.fetchFollowedChannels(userID: userSettings.userId) { result in
                    switch result {
                    case .success(let channels):
                        for channel in channels {
                            let followedChannel = FollowedChannel(
                                name: channel.name,
                                isLive: false,
                                notifyForChannel: true,
                                liveSince: .now
                            )
                            context.insert(followedChannel)
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
}
extension TwitchAPI {
    func clearStoredUserData(context: ModelContext) {
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
        } catch {
            print("failed to clear stored data:", error)
        }
    }
}

struct UserProfileResponse: Codable {
    let data: [UserProfile]

    struct UserProfile: Codable {
        let displayName: String
        let profileImageURL: String
        let id: String

        enum CodingKeys: String, CodingKey {
            case id
            case displayName = "display_name"
            case profileImageURL = "profile_image_url"
        }
    }
}

struct FollowedChannelsResponse: Codable {
    let data: [FollowedChannelResponse]
    let pagination: Pagination?

    struct FollowedChannelResponse: Codable {
        let broadcasterID: String
        let broadcasterLogin: String
        let broadcasterName: String

        enum CodingKeys: String, CodingKey {
            case broadcasterID = "broadcaster_id"
            case broadcasterLogin = "broadcaster_login"
            case broadcasterName = "broadcaster_name"
        }
    }

    struct Pagination: Codable {
        let cursor: String?
    }
}
struct StreamStatusResponse: Codable {
    let data: [Stream]

    struct Stream: Codable {
        let userLogin: String

        enum CodingKeys: String, CodingKey {
            case userLogin = "user_login"
        }
    }
}

