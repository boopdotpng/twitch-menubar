import SwiftUI
import SwiftData

struct ContentView: View {
    let channels: [FollowedChannel]
    
    var isLoggedIn: Bool {
        UserDefaults.standard.string(forKey: "twitch_access_token") != nil
    }
    
    var body: some View {
        VStack(spacing: 10) {
            if !isLoggedIn {
                VStack(spacing: 10) {
                    Text("not logged in")
                        .font(.headline)
                    Text("please log in to see your followed channels")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding()
            } else {
                Text("followed twitch channels")
                    .font(.headline)
                    .padding(.top, 5)
                
                Divider()
                
                if channels.isEmpty {
                    Text("no followed channels found")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.vertical, 10)
                } else {
                    ScrollView {
                        VStack(spacing: 5) {
                            ForEach(channels, id: \.id) { channel in
                                Button(action: { openTwitch(channel.name) }) {
                                    HStack {
                                        if channel.isLive {
                                            Circle()
                                                .fill(Color.red)
                                                .frame(width: 8, height: 8)
                                        }
                                        
                                        Text(channel.name)
                                            .fontWeight(.medium)
                                        
                                        Spacer()
                                        
                                        Text(channel.isLive ? channel.liveSince.formatted(.relative(presentation: .numeric)) : "offline")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.horizontal, 10)
                                }
                                .buttonStyle(.plain)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .contentShape(Rectangle())
                            }
                        }
                        .padding(.vertical, 5)
                    }
                    .frame(height: min(300, CGFloat(channels.count) * 40)) // cap height for small popovers
                }
            }
        }
        .padding()
        .frame(width: 300)
    }
    
    func openTwitch(_ channelName: String) {
        let urlString = "https://twitch.tv/\(channelName)"
        if let url = URL(string: urlString) {
            NSWorkspace.shared.open(url)
        }
    }
}
