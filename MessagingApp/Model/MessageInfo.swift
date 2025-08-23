//
//  MessageInfo.swift
//  MessagingApp
//
//  Created by Daniel Le on 8/16/25.
//

import Foundation

struct MessageInfo {
    let id: String
    let senderId: String
    let text: String
    let date: Date
    let edited: Bool
    let channelId: String
    let reaction: String
    let forwardMessageId: String
    let replayMessageId: String
}
