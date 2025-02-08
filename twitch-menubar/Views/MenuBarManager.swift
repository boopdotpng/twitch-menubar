// menubarmanager.swift
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
        self.popover.contentViewController = NSHostingController(
            rootView: LiveChannelsView(context: context, onEnter: { self.popover.performClose(nil) })
        )
        self.popover.behavior = .transient
        self.popover.animates = true 

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "play.circle", accessibilityDescription: "twitch")
            button.action = #selector(togglePopover(_:))
            button.target = self
        }
    }

    @objc private func togglePopover(_ sender: AnyObject?) {
        if popover.isShown {
            popover.performClose(sender)
        } else if let button = statusItem.button {
            NotificationCenter.default.post(name: Notification.Name("ClearSearchText"), object: nil)
            popover.show(
                relativeTo: button.bounds,
                of: button,
                preferredEdge: .minY
            )
        }
    }
}
