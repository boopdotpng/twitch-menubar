import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    private var notifiedChannels: [String: Date] = [:]

    private init() {
        requestAuthorization()
    }

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification authorization error:", error)
            }
            print("Notification permission granted: \(granted)")
        }
    }

    func sendNotification(for channel: FollowedChannel) {
        if let last = notifiedChannels[channel.name],
           Date().timeIntervalSince(last) < 180 {
            return
        }
        notifiedChannels[channel.name] = Date()

        let content = UNMutableNotificationContent()
        content.title = "\(channel.name) is live!"
        content.body = "twitch stream started \(durationString(from: channel.liveSince)) ago"
        content.sound = .default

        let request = UNNotificationRequest(identifier: channel.name, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to send notification:", error)
            }
        }
    }

    private func durationString(from date: Date) -> String {
        let interval = Int(Date().timeIntervalSince(date))
        let minutes = (interval % 3600) / 60
        let hours = (interval % 86400) / 3600
        let days = interval / 86400

        var parts: [String] = []
        if days > 0 { parts.append("\(days)d") }
        if hours > 0 { parts.append("\(hours)h") }
        if minutes > 0 || parts.isEmpty { parts.append("\(minutes)m") }
        return parts.joined(separator: " ")
    }
}
