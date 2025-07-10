//
//  DirectMessageView.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/9/25.
//

import SwiftUI

struct DirectMessageView: View {
    static let dateHeaderFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd, yyyy"
        return formatter
    }()
    
    static let messageTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d/yy, hh:mm"
        return formatter
    }()
    
    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(.gray)
                .frame(height: 0.4)
                .ignoresSafeArea(edges: .horizontal)
                .padding(.top, 10)
            ScrollViewReader { proxy in
                let lastId = Message.mockMessage.max(by: { $0.date < $1.date })?.id
                ScrollView {
                    let sortedMessage = sortMessagesByDate(messages: Message.mockMessage)
                    ForEach(sortedMessage, id: \.0) { date, messages in
                        VStack(alignment: .leading) {
                            HStack {
                                Rectangle()
                                    .fill(.gray)
                                    .frame(height: 0.5)
                                Text(DirectMessageView.dateHeaderFormatter.string(from: date))
                                    .foregroundStyle(.gray)
                                    .fontWeight(.bold)
                                    .font(.footnote)
                                    .padding(.horizontal, 8)
                                Rectangle()
                                    .fill(.gray)
                                    .frame(height: 0.5)
                            }
                            .padding(.horizontal, 13)
                            
                            let sortedMessageByHourMinute = sortMessagesByHourMinute(messages: messages)
                            ForEach(sortedMessageByHourMinute, id: \.0) { time, messages in
                                
                                let sortedMessagesByUser = sortMessagesByUser(messages: messages)
                                ForEach(sortedMessagesByUser, id: \.0) { userId, messages in
                                    if let user = searchUser(id: userId) {
                                        HStack(alignment: .top) {
                                            Image(user.icon)
                                                .resizable()
                                                .frame(width: 45, height: 45)
                                                .clipShape(.circle)
                                            VStack(alignment: .leading) {
                                                HStack {
                                                    Text(user.name)
                                                        .font(.title3)
                                                        .bold()
                                                    Text(DirectMessageView.messageTimeFormatter.string(from: time))
                                                        .font(.footnote)
                                                        .foregroundStyle(.gray)
                                                }
                                                ForEach(messages) { message in
                                                    VStack {
                                                        Text(String(data: message.data, encoding: .utf8) ?? "Invalid message")
                                                            .id(message.id)
                                                    }
                                                }
                                            }
                                        }
                                        .padding(.horizontal, 13)
                                        .padding(.bottom)
                                    }
                                }
                            }
                        }
                    }
                }
                .onAppear {
                    if let lastId = lastId {
                        proxy.scrollTo(lastId, anchor: .bottom)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItemGroup(placement: .topBarLeading) {
                DirectMessageNavbar(data: User.mockUser[0])
            }
        }
        .tint(.white)
    }
}

extension DirectMessageView {
    func sortMessagesByDate(messages: [Message]) -> [(Date, [Message])] {
        var result: [Date:[Message]] = [:]
        
        for message in messages {
            let date = Calendar.current.startOfDay(for: message.date)
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
            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: message.date)

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
    
    func searchUser(id: UUID) -> User? {
        return User.mockUser.first { $0.id == id }
    }
    
    func sortMessagesByUser(messages: [Message]) -> [(UUID, [Message])] {
        var result: [(UUID, [Message])] = []
        
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
            
            if prevDate == message.date && prevUserId == message.userId {
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

struct DirectMessageNavbar: View {
    let data: User
    let backButtonWidth: CGFloat = 19
    let iconDimension: (width: CGFloat, height: CGFloat) = (40, 40)
    let statusCircleOffset: (x: CGFloat, y: CGFloat) = (2, 2)
    let outterCircleDimension: (width: CGFloat, height: CGFloat) = (18, 18)
    let innerCircleDimension: (width: CGFloat, height: CGFloat) = (11, 11)
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "arrow.left")
                .resizable()
                .frame(width: backButtonWidth)
                .bold()
        }
        HStack {
            Image(data.icon)
                .resizable()
                .frame(width: iconDimension.width, height: iconDimension.height)
                .clipShape(.circle)
                .overlay(alignment: .bottomTrailing) {
                    Circle()
                        .offset(x: statusCircleOffset.x, y: statusCircleOffset.y)
                        .fill(.black)
                        .frame(width: outterCircleDimension.width, height: outterCircleDimension.height)
                        .overlay {
                            Circle()
                                .offset(x: statusCircleOffset.x, y: statusCircleOffset.y)
                                .fill(.green)
                                .frame(width: innerCircleDimension.width, height: innerCircleDimension.height)
                        }
                }
                .padding(.trailing, 7)
            
            Text(data.name)
                .font(.title3)
                .bold()
            Image(systemName: "chevron.right")
                .resizable()
                .frame(width: 5, height: 10)
                .bold()
        }
    }
}

#Preview {
    DirectMessageView()
}
