//
//  Message.swift
//  MessagingApp
//
//  Created by Daniel Le on 8/16/25.
//

import FirebaseFirestore

struct MessageFile: Codable, Hashable {
    let url: String?
    let data: Data?
    let name: String
    let size: Int
}

struct Message: Codable, Identifiable, Hashable {
    @DocumentID var id: String?
    let senderId: String
    var text: String?
    var photoUrls: [String]
    var videoUrls: [String]
    var files: [MessageFile]
    @ServerTimestamp var date: Timestamp?
    let edited: Bool
    let reaction: String?
    let forwardMessageId: String?
    let replayMessageId: String?
    
    var clientId: String?
    var isPending: Bool = false
    var selectionData: [UploadedFile]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case senderId
        case text
        case photoUrls
        case videoUrls
        case files
        case date
        case edited
        case reaction
        case forwardMessageId
        case replayMessageId
        case clientId
    }
    
    // Implement Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id ?? clientId)
    }

    static func == (lhs: Message, rhs: Message) -> Bool {
        lhs.id == rhs.id && lhs.clientId == rhs.clientId
    }
}
