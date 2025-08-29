//
//  Channel.swift
//  MessagingApp
//
//  Created by Daniel Le on 8/22/25.
//

import FirebaseFirestore

// Represents the nested 'lastMessage' object in your Channel document
struct LastMessage: Codable, Equatable {
    let senderId: String
    let text: String?
    let timestamp: Timestamp
}

enum ChannelType: String, Codable {
    case dm = "dm"
    case server = "server"
}

struct Channel: Codable, Identifiable, Equatable {
    @DocumentID var id: String?
    let memberIds: [String]
    let type: ChannelType.RawValue
    let lastActivity: Timestamp?
    let lastMessage: LastMessage?

    static func == (lhs: Channel, rhs: Channel) -> Bool {
        lhs.id == rhs.id
    }
}

// Use this struct when creating a new channel document in Firestore
struct ChannelInsert: Codable {
    let memberIds: [String]
    let type: ChannelType.RawValue
    @ServerTimestamp var lastActivity: Timestamp? = nil
    var lastMessage: LastMessage? = nil
}
