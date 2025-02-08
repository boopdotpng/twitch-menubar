import Foundation
import SwiftUI

struct ContentView: View {
    let channels: [TwitchChannel] = [
        .init(name: "xQc", url: "https://twitch.tv", liveDuration: "2h 15m", isLive: true, profileImage: nil),
        .init(name: "Shroud", url: "https://twitch.tv", liveDuration: "45m", isLive: true, profileImage: nil),
        .init(name: "Ninja", url: "https://twitch.tv", liveDuration: "Offline", isLive: false, profileImage: nil)
    ]
    
    var body: some View {
            VStack(spacing: 10) {
                Text("Followed Twitch Channels")
                    .font(.headline)

                Divider()

                ScrollView {
                    VStack(spacing: 5) {
                        ForEach(channels, id: \.name) { channel in
                            Button(action: { openTwitch(channel.url) }) {
                                HStack {
                                    Image(systemName: "play.fill")
                                        .foregroundColor(.purple)
                                    Text(channel.name)
                                        .fontWeight(.medium)
                                    Spacer()
                                }
                                .padding(.horizontal)
                            }
                            .buttonStyle(.plain) // removes macOS button styling
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .contentShape(Rectangle()) // makes entire row clickable
                        }
                    }
                    .padding(.vertical, 5)
                }
                .frame(height: 150)

            }
            .padding()
            .frame(width: 300)
        }
    
    func openTwitch(_ url: String) {
        if let twitchURL = URL(string: url) {
            NSWorkspace.shared.open(twitchURL)
        }
    }
}

struct TwitchChannel: Identifiable {
    let name: String
    let url: String
    let id = UUID()
    let liveDuration: String
    let isLive: Bool
    let profileImage: String?
}
