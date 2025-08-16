//
//  MessageInfo.swift
//  MessagingApp
//
//  Created by Daniel Le on 8/16/25.
//

import Foundation

struct MessageInfo {
    let id: UUID
    let userId: UUID
    let text: String
    let date: Date
    let edited: Bool
    let location: String
    let reaction: String
    let forwardMessageId: UUID
    let replayMessageId: UUID
}
