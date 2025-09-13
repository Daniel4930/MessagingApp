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
                let nameToShow = friend.displayName.isEmpty ? friend.userName : friend.displayName
                
                HStack {
                    Text(nameToShow)
                        .font(.subheadline)
                        .bold()
                    Spacer()
                    if let latestMessage = channel.lastMessage {
                        Text(channelViewModel.formatLastMessageTime(time: latestMessage.timestamp.dateValue()))
                            .font(.footnote)
                    }
                }
                
                if let latestMessage = channel.lastMessage {
                    let sender = latestMessage.senderId == friend.id ? nameToShow : "You"
                    if let text = latestMessage.text {
                        Text("\(sender): \(text)")
                            .font(.footnote)
                            .lineLimit(1)
                    }
                } else {
                    Text("No messages yet.")
                        .font(.footnote)
                }
            }
        }
    }
}
