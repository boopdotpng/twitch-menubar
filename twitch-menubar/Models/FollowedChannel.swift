//
//  FollowedChannel.swift
//  twitch-menubar
//
//  Created by Anuraag Warudkar on 2/7/25.
//

import Foundation
import SwiftData

@Model
class FollowedChannel {
    @Attribute(.unique) var id: UUID = UUID()
    var name: String
    var isLive: Bool = false
    var notifyForChannel: Bool = true
    var liveSince: Date // how long have they been live
    
    init(id: UUID = UUID(), name: String, isLive: Bool, notifyForChannel: Bool, liveSince: Date) {
        self.id = id
        self.name = name
        self.isLive = isLive
        self.notifyForChannel = notifyForChannel
        self.liveSince = liveSince
    }
}
