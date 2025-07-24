//
//  MessageScrollView.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/19/25.
//

import SwiftUI

struct MessageScrollView: View {
    @Binding var scrollToBottom: Bool
    
    @State private var height: CGFloat = .zero
    @EnvironmentObject var messageViewModel: MessageViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            DividerView(padding: (Edge.Set.top, CGFloat(10)))
            ScrollViewReader { proxy in
                ScrollView {
                    let sortedMessage = sortMessagesByDate(messages: messageViewModel.messages)
                    ForEach(sortedMessage, id: \.0) { date, messages in
                        VStack(alignment: .leading) {
                            DirectMessageDate(date: date)
                                .padding(.horizontal, 13)
                            
                            let sortedMessageByHourMinute = sortMessagesByHourMinute(messages: messages)
                            ForEach(sortedMessageByHourMinute, id: \.0) { time, messages in
                                let sortedMessagesByUser = sortMessagesByUser(messages: messages)
                                ForEach(sortedMessagesByUser, id: \.0) { userId, messages in
                                    if let user = searchUser(id: userId) {
                                        MessageLayoutView(user: user, messages: messages, time: time)
                                    }
                                }
                            }
                        }
                    }
                    Color.clear
                        .frame(height: 1)
                        .id("BOTTOM")
                }
                .onChange(of: scrollToBottom) { _, newValue in
                    if newValue {
                        withAnimation(.default) {
                            proxy.scrollTo("BOTTOM", anchor: .bottom)
                            scrollToBottom = false
                        }
                    }
                }
                .scrollDismissesKeyboard(.immediately)
                .defaultScrollAnchor(.bottom)
            }
            DividerView()
        }
    }
}

extension MessageScrollView {
    func sortMessagesByDate(messages: [Message]) -> [(Date, [Message])] {
        var result: [Date:[Message]] = [:]
        
        for message in messages {
            if let messageDate = message.date {
                let date = Calendar.current.startOfDay(for: messageDate)
                if result[date] != nil {
                    result[date]!.append(message)
                } else {
                    result[date] = [message]
                }
            }
        }
        return result.sorted { $0.key < $1.key }
    }
    
    func sortMessagesByHourMinute(messages: [Message]) -> [(Date, [Message])] {
        var result: [Date: [Message]] = [:]
        let calendar = Calendar.current
        
        for message in messages {
            if let messageDate = message.date {
                let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: messageDate)
                
                if let date = calendar.date(from: components) {
                    if result[date] != nil {
                        result[date]!.append(message)
                    } else {
                        result[date] = [message]
                    }
                }
            }
        }
        return result.sorted { $0.key < $1.key }
    }
    
    func searchUser(id: UUID) -> User? {
        return userViewModel.fetchUserById(id: id)
    }
    
    func sortMessagesByUser(messages: [Message]) -> [(UUID, [Message])] {
        var result: [(UUID, [Message])] = []
        let calendar = Calendar.current
        
        var tempMessages: [Message] = []
        var prevDate: Date?
        var prevUserId: UUID?
        for message in messages {
            if prevDate == nil {
                prevDate = message.date
                prevUserId = message.userId
                tempMessages.append(message)
                continue
            }
            guard let date = prevDate, let messageDate = message.date else { continue }
            
            let prevDateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
            let messageDateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: messageDate)
            
            let prev = calendar.date(from: prevDateComponents)
            let current = calendar.date(from: messageDateComponents)
            
            if prev == current && prevUserId == message.userId {
                tempMessages.append(message)
            } else {
                if let id = prevUserId {
                    result.append((id, tempMessages))
                }
                tempMessages = [message]
                prevDate = message.date
                prevUserId = message.userId
            }
        }
        if let id = prevUserId {
            result.append((id, tempMessages))
        }
        
        return result
    }
}
