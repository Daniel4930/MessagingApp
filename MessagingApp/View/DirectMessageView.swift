//
//  DirectMessageView.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/9/25.
//

import SwiftUI

struct DirectMessageView: View {
    @State var message: String = ""
    @State var updateScrolling: Bool = false
    
    let iconDimension: (width: CGFloat, height: CGFloat) = (45, 45)
    static let messageTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d/yy, hh:mm a"
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
                ScrollView {
                    let sortedMessage = sortMessagesByDate(messages: Message.mockMessage)
                    ForEach(sortedMessage, id: \.0) { date, messages in
                        VStack(alignment: .leading) {
                            DirectMessageDate(date: date)
                                .padding(.horizontal, 13)
                            
                            let sortedMessageByHourMinute = sortMessagesByHourMinute(messages: messages)
                            ForEach(sortedMessageByHourMinute, id: \.0) { time, messages in
                                
                                let sortedMessagesByUser = sortMessagesByUser(messages: messages)
                                ForEach(sortedMessagesByUser, id: \.0) { userId, messages in
                                    if let user = searchUser(id: userId) {
                                        HStack(alignment: .top) {
                                            Image(user.icon)
                                                .resizable()
                                                .frame(width: iconDimension.width, height: iconDimension.height)
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
                                                    MessageView(message: message, updateScrolling: $updateScrolling)
                                                }
                                            }
                                        }
                                        .padding(.horizontal, 13)
                                        .padding(.bottom, sortedMessagesByUser.last?.0 == userId ? 0 : 16)
                                    }
                                }
                            }
                        }
                    }
                    Color.clear
                        .frame(height: 1)
                        .id("BOTTOM")
                }
                .onAppear {
                    proxy.scrollTo("BOTTOM", anchor: .bottom)
                }
                .onChange(of: updateScrolling) { _ in
                    proxy.scrollTo("BOTTOM", anchor: .bottom)
                    updateScrolling = false
                }
            }
            Rectangle()
                .fill(.gray)
                .frame(height: 0.5)
                .ignoresSafeArea(edges: .horizontal)
            
            DirectMessageNavBar(message: $message, updateScrolling: $updateScrolling)
                .padding(.horizontal, 13)
                .padding(.top, 10)
                .padding(.bottom, 23)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            DirectMessageTopBar(data: User.mockUser[0])
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

struct DirectMessageDate: View {
    let date: Date
    let dividerLineThickness: CGFloat = 0.5
    
    static let dateHeaderFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd, yyyy"
        return formatter
    }()
    
    var body: some View {
        HStack {
            Rectangle()
                .fill(.gray)
                .frame(height: dividerLineThickness)
            Text(DirectMessageDate.dateHeaderFormatter.string(from: date))
                .foregroundStyle(.gray)
                .fontWeight(.bold)
                .font(.footnote)
                .padding(.horizontal, 8)
            Rectangle()
                .fill(.gray)
                .frame(height: dividerLineThickness)
        }
    }
}
