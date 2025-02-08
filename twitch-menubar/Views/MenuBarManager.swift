import SwiftUI
import SwiftData

class MenuBarManager: ObservableObject {
    private var statusItem: NSStatusItem
    private let context: ModelContext
    private var popover: NSPopover

    init(context: ModelContext) {
        self.context = context
        self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        self.popover = NSPopover()
        self.popover.contentViewController = NSHostingController(rootView: LiveChannelsView(context: context))
        self.popover.behavior = .transient 
        self.popover.animates = true

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "play.circle", accessibilityDescription: "Twitch")
            button.action = #selector(togglePopover(_:))
            button.target = self
        }

        fetchIfNeeded()
    }

    @objc private func togglePopover(_ sender: AnyObject?) {
        if popover.isShown {
            popover.performClose(sender)
        } else if let button = statusItem.button {
            showPopover(relativeTo: button)
        }
    }

    private func showPopover(relativeTo button: NSStatusBarButton) {
        guard let buttonWindow = button.window else { return }

        popover.show(
            relativeTo: button.bounds,
            of: button,
            preferredEdge: .minY
        )
    }

    private func fetchIfNeeded() {
        let lastFetchTime = UserDefaults.standard.double(forKey: "lastFetchTime")
        let currentTime = Date().timeIntervalSince1970

        if currentTime - lastFetchTime < 120 {
            print("Skipping fetch, last updated less than 2 minutes ago")
            return
        }

        print("Fetching initial channel data...")
        TwitchAPI().fetchFollowedLiveChannels(context: context) { result in
            switch result {
            case .success:
                UserDefaults.standard.set(currentTime, forKey: "lastFetchTime")
            case .failure(let error):
                print("Failed to fetch channels:", error)
            }
        }
    }
}
