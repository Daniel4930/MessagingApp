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
    let text: String?
    let photoUrls: [String]
    let fileUrls: [String]
    @ServerTimestamp var date: Timestamp?
    let edited: Bool
    let reaction: String?
    let forwardMessageId: String?
    let replayMessageId: String?
}
