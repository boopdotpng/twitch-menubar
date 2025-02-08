// livechannelsview.swift
import SwiftUI
import SwiftData

struct LiveChannelsView: View {
    @State private var searchText = ""
    @State private var channels: [FollowedChannel] = []
    @State private var timer: Timer? = nil
    @FocusState private var isSearchFocused: Bool
    var context: ModelContext
    var onEnter: (() -> Void)?

    var body: some View {
        VStack(spacing: 10) {
            Text("currently live")
                .font(.headline)

            TextField("search channels", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
                .focused($isSearchFocused)
                .onSubmit {
                    guard !searchText.isEmpty else { return }
                    let filtered = channels.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
                    let sorted = filtered.sorted { $0.liveSince > $1.liveSince }
                    if let topResult = sorted.first, let url = URL(string: topResult.link) {
                        NSWorkspace.shared.open(url)
                        onEnter?()
                    }
                }

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 4) {
                    ForEach(
                        channels.filter { searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(searchText) }
                            .sorted { $0.liveSince > $1.liveSince },
                        id: \.id
                    ) { channel in
                        HStack {
                            Link(channel.name, destination: URL(string: channel.link)!)
                            Spacer()
                            Text(durationString(from: channel.liveSince))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 4)
                        Divider()
                    }
                }
            }

            HStack {
                Button("settings") {
                    // implement settings action if needed
                }
                Spacer()
                Button("quit") {
                    NSApplication.shared.terminate(nil)
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
        .onAppear {
            isSearchFocused = true
            fetchChannels()
            timer = Timer.scheduledTimer(withTimeInterval: 120, repeats: true) { _ in
                fetchChannels()
            }
        }
        .onDisappear {
            timer?.invalidate()
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("ClearSearchText"))) { _ in
            searchText = ""
        }
    }

    func fetchChannels() {
        TwitchAPI().fetchFollowedLiveChannels(context: context) { result in
            switch result {
            case .success(let fetchedChannels):
                DispatchQueue.main.async {
                    channels = fetchedChannels
                    for channel in channels {
                        if Date().timeIntervalSince(channel.liveSince) < 180 {
                            NotificationManager.shared.sendNotification(for: channel)
                        }
                    }
                }
            case .failure(let error):
                print("failed to fetch channels:", error)
            }
        }
    }

    func durationString(from date: Date) -> String {
        let interval = Int(Date().timeIntervalSince(date))
        let days = interval / 86400
        let hours = (interval % 86400) / 3600
        let minutes = (interval % 3600) / 60

        var components: [String] = ["live for"]
        if days > 0 { components.append("\(days)d") }
        if hours > 0 { components.append("\(hours)h") }
        if minutes > 0 || components.count == 1 { components.append("\(minutes)m") }
        return components.joined(separator: " ")
    }
}
