//
//  UserSettings.swift
//  twitch-menubar
//
//  Created by Anuraag Warudkar on 2/7/25.
//
import SwiftData
import Foundation

@Model
class UserSettings {
    @Attribute(.unique) var id: UUID = UUID()
    var notificationsEnabled: Bool // global toggle
    var displayName: String = ""
    var profileImageUrl: String = ""
    var userId: String = ""
    
    
    init(id: UUID = UUID(), notificationsEnabled: Bool = true, displayName: String = "", profileImageUrl: String = "", userId: String) {
        self.id = id
        self.notificationsEnabled = notificationsEnabled
        self.displayName = displayName
        self.profileImageUrl = profileImageUrl
        self.userId = userId
    }
}
