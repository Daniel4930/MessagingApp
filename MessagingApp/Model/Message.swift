//
//  Message.swift
//  MessagingApp
//
//  Created by Daniel Le on 8/16/25.
//

import FirebaseFirestore

struct Message: Codable, Identifiable {
    @DocumentID var id: String?
    let senderId: String
    let text: String
    let photoUrls: [String]
    let fileUrls: [String]
    let date: Timestamp // This is your timestamp for ordering
    let edited: Bool
    // channelId is removed, as the message's location in the subcollection defines its channel
    let reaction: String
    let forwardMessageId: String
    let replayMessageId: String
}
