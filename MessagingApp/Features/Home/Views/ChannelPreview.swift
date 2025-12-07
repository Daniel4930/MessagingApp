//
//  ChannelPreview.swift
//  MessagingApp
//
//  Created by Daniel Le on 9/13/25.
//

import SwiftUI

struct ChannelPreview: View {
    let friend: User
    let channel: Channel
    
    @EnvironmentObject var channelViewModel: ChannelViewModel
    
    var body: some View {
        HStack {
            UserIconView(urlString: friend.icon)
                .overlay(alignment: .bottomTrailing) {
                    OnlineStatusCircle(status: friend.onlineStatus.rawValue, color: .secondaryBackground)
                }
            
            VStack(alignment: .leading, spacing: 0) {
                receiverChannelInfo
                
                lastMessageView
            }
        }
    }
    
    private var receiverName: String {
        friend.displayName.isEmpty ? friend.userName : friend.displayName
    }
    
    private var lastMessage: LastMessage? {
        channel.lastMessage
    }
    
    private var lastMessageText: String {
        if let lastMessage {
            let sender = lastMessage.senderId == friend.id ? receiverName : "You"
            if let text = lastMessage.text {
                return "\(sender): \(text)"
            } else {
                return ""
            }
        } else {
            return "No messages yet."
        }
    }
    
    var lastMessageView: some View {
        Text(lastMessageText)
            .font(.footnote)
            .lineLimit(1)
    }
    
    var receiverChannelInfo: some View {
        HStack {
            Text(receiverName)
                .font(.subheadline)
                .bold()
            Spacer()
            if let lastMessage {
                Text(channelViewModel.formatLastMessageTime(time: lastMessage.timestamp.dateValue()))
                    .font(.footnote)
            }
        }
    }
}
