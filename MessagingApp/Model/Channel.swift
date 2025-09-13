//
//  Channel.swift
//  MessagingApp
//
//  Created by Daniel Le on 8/22/25.
//

import FirebaseFirestore

// Represents the nested 'lastMessage' object in your Channel document
struct LastMessage: Codable, Equatable, Hashable {
    let messageId: String
    let senderId: String
    var text: String?
    let timestamp: Timestamp
}

enum ChannelType: String, Codable {
    case dm
    case server
}

struct Channel: Codable, Identifiable, Equatable, Hashable {
    @DocumentID var id: String?
    let memberIds: [String]
    let type: ChannelType
    let lastActivity: Timestamp?
    let lastMessage: LastMessage?

    static func == (lhs: Channel, rhs: Channel) -> Bool {
        lhs.id == rhs.id
    }
}

// Use this struct when creating a new channel document in Firestore
struct ChannelInsert: Codable {
    let memberIds: [String]
    let type: ChannelType
    @ServerTimestamp var lastActivity: Timestamp? = nil
    var lastMessage: LastMessage? = nil
}
