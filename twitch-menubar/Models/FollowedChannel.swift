//
//  FollowedChannel.swift
//  twitch-menubar
//
//  created by anuraag warudkar on 2/7/25.
//

import Foundation
import SwiftData

@Model
class FollowedChannel {
    @Attribute(.unique) var id: UUID = UUID()
    var name: String
    var isLive: Bool = true
    var notifyForChannel: Bool = true
    var liveSince: Date
    var link: String
    // extras: optional details for display/search
    var title: String?
    var gameName: String?
    var viewerCount: Int?
    
    init(id: UUID = UUID(),
         name: String,
         liveSince: Date,
         link: String,
         title: String? = nil,
         gameName: String? = nil,
         viewerCount: Int? = nil) {
        self.id = id
        self.name = name
        self.liveSince = liveSince
        self.link = link
        self.title = title
        self.gameName = gameName
        self.viewerCount = viewerCount
    }
}
