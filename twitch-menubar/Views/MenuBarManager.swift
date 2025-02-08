import SwiftUI
import SwiftData

class MenuBarManager: ObservableObject {
    private var statusItem: NSStatusItem
    private var popover: NSPopover
    private let context: ModelContext
    private var channels: [FollowedChannel] = [] // store channels

    init(context: ModelContext) {
        self.context = context

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        popover = NSPopover()
        popover.behavior = .transient // closes when clicking outside

        loadChannels() // fetch channels

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "play.circle", accessibilityDescription: "Twitch")
            button.action = #selector(togglePopover(_:))
            button.target = self
        }
    }

    private func loadChannels() {
        do {
            let fetchDescriptor = FetchDescriptor<FollowedChannel>()
            self.channels = try context.fetch(fetchDescriptor)
        } catch {
            print("failed to load channels:", error)
        }
    }

    @objc private func togglePopover(_ sender: AnyObject?) {
        if popover.isShown {
            popover.performClose(sender)
        } else if let button = statusItem.button {
            loadChannels() // refresh channels before showing popover
            popover.contentViewController = NSHostingController(rootView: ContentView(channels: channels))
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minX)
        }
    }
}
