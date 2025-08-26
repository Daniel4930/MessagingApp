//
//  ChannelInfo.swift
//  MessagingApp
//
//  Created by Daniel Le on 8/22/25.
//

import FirebaseFirestore

enum ChannelType: String {
    case dm = "dm"
    case server = "server"
}

struct ChannelInfo: Identifiable {
    @DocumentID var id: String?
    let messageIds: [String]
    let type: ChannelType.RawValue
}
