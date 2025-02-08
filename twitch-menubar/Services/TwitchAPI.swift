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
    func fetchUserProfile(completion: @escaping (Result<(String, String), Error>) -> Void) {
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
                    completion(.success((user.displayName, user.profileImageURL)))
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
            let url = URL(string: "\(baseURL)/users/follows?from_id=\(userID)")!
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
                    let response = try JSONDecoder().decode(FollowedChannelsResponse.self, from: data)
                    let channels = response.data.map {
                        FollowedChannel(name: $0.toName, isLive: false, notifyForChannel: false, liveSince: .now)
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
        fetchUserProfile { result in
            switch result {
            case .success(let (displayName, profileImageUrl)):
                let userSettings = UserSettings(displayName: displayName, profileImageUrl: profileImageUrl)
                context.insert(userSettings)

                // fetch followed channels
                self.fetchFollowedChannels(userID: displayName) { result in
                    switch result {
                    case .success(let channels):
                        for channel in channels {
                            let followedChannel = FollowedChannel(name: channel.name, isLive: false, notifyForChannel: true, liveSince: .now)
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

struct UserProfileResponse: Codable {
    let data: [UserProfile]

    struct UserProfile: Codable {
        let displayName: String
        let profileImageURL: String

        enum CodingKeys: String, CodingKey {
            case displayName = "display_name"
            case profileImageURL = "profile_image_url"
        }
    }
}

struct FollowedChannelsResponse: Codable {
    let data: [FollowedChannelResponse]

    struct FollowedChannelResponse: Codable {
        let toName: String

        enum CodingKeys: String, CodingKey {
            case toName = "to_name"
        }
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

