//
//  MessageScrollView.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/19/25.
//

import SwiftUI

struct MessageScrollView: View {
    @Binding var scrollToBottom: Bool
    @FocusState.Binding var focusedField: Field?
    
    @State private var scrollPosition = ScrollPosition()
    @EnvironmentObject var messageViewModel: MessageViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    
    var body: some View {
        let sortedMessage = sortMessagesByDate(messages: messageViewModel.messages)
        
        ScrollView {
            if sortedMessage.isEmpty {
                EmptyMessageView()
                Spacer()
            } else {
                ForEach(sortedMessage, id: \.0) { date, messages in
                    VStack(alignment: .leading) {
                        MessageDateView(date: date)
                            .padding(.horizontal, 13)
                        
                        let sortedMessageByHourMinute = sortMessagesByHourMinute(messages: messages)
                        ForEach(sortedMessageByHourMinute, id: \.0) { time, messages in
                            let sortedMessagesByUser = sortMessagesByUser(messages: messages)
                            ForEach(sortedMessagesByUser, id: \.0) { userId, messages in
                                if let user = /*searchUser(id: userId)*/userViewModel.user {
                                    MessageLayoutView(user: user, messages: messages, time: time)
                                }
                            }
                        }
                    }
                }
            }
        }
        .scrollPosition($scrollPosition)
        .scrollDismissesKeyboard(.immediately)
        .defaultScrollAnchor(.bottom)
        .onScrollPhaseChange { oldPhase, newPhase in
            if newPhase == .interacting {
                focusedField = nil
            }
        }
        .onChange(of: scrollToBottom) { _, newValue in
            if newValue == true {
                withAnimation(.spring(duration: 0.2)) {
                    scrollPosition.scrollTo(edge: .bottom)
                }
                scrollToBottom = false
            }
        }
    }
}

extension MessageScrollView {
    func sortMessagesByDate(messages: [Message]) -> [(Date, [Message])] {
        var result: [Date:[Message]] = [:]
        
        for message in messages {
            let date = Calendar.current.startOfDay(for: message.date.dateValue())
            if result[date] != nil {
                result[date]!.append(message)
            } else {
                result[date] = [message]
            }
        }
        return result.sorted { $0.key < $1.key }
    }
    
    func sortMessagesByHourMinute(messages: [Message]) -> [(Date, [Message])] {
        var result: [Date: [Message]] = [:]
        let calendar = Calendar.current
        
        for message in messages {
            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: message.date.dateValue())
            
            if let date = calendar.date(from: components) {
                if result[date] != nil {
                    result[date]!.append(message)
                } else {
                    result[date] = [message]
                }
            }
        }
        return result.sorted { $0.key < $1.key }
    }
    
    func sortMessagesByUser(messages: [Message]) -> [(String, [Message])] {
        var result: [(String, [Message])] = []
        let calendar = Calendar.current
        
        var tempMessages: [Message] = []
        var prevDate: Date?
        var prevUserId: String?
        for message in messages {
            if prevDate == nil {
                prevDate = message.date.dateValue()
                prevUserId = message.senderId
                tempMessages.append(message)
                continue
            }
            guard let date = prevDate else { continue }
            let messageDate = message.date.dateValue()
            
            let prevDateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
            let messageDateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: message.date.dateValue())
            
            let prev = calendar.date(from: prevDateComponents)
            let current = calendar.date(from: messageDateComponents)
            
            if prev == current && prevUserId == message.senderId {
                tempMessages.append(message)
            } else {
                if let id = prevUserId {
                    result.append((id, tempMessages))
                }
                tempMessages = [message]
                prevDate = messageDate
                prevUserId = message.senderId
            }
        }
        if let id = prevUserId {
            result.append((id, tempMessages))
        }
        
        return result
    }
}


struct EmptyMessageView: View {
    var body: some View {
        HStack(spacing: 0) {
            Text("This is the beginning of your conversion")
                .font(.title2)
                .bold()
                .multilineTextAlignment(.center)
                .padding(.trailing)
            Image(systemName: "message.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
        }
        .frame(maxWidth: .infinity)
        .padding(.top)
    }
}
