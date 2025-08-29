//
//  MessageViewModel.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/19/25.
//

import Foundation
import FirebaseFirestore

struct MessageMap {
    let channelId: String
    var messages: [Message]
    var documentSnapshot: DocumentSnapshot?
}

@MainActor
class MessageViewModel: ObservableObject {
    @Published var messages: [MessageMap] = []
    private var messageListenerTask: Task<Void, Never>? = nil
    
    deinit {
        messageListenerTask?.cancel()
    }
    
    func listenForMessages(channelId: String) {
        messageListenerTask?.cancel()
        messageListenerTask = Task {
            do {
                let stream = FirebaseCloudStoreService.shared.listenForMessages(channelId: channelId)
                
                for try await newMessagesData in stream {
                    if let index = self.messages.firstIndex(where: { $0.channelId == channelId }) {
                        self.messages[index].messages = newMessagesData.messages
                        self.messages[index].documentSnapshot = newMessagesData.documentSnapshot
                    } else {
                        self.messages.append(MessageMap(channelId: channelId, messages: newMessagesData.messages, documentSnapshot: newMessagesData.documentSnapshot))
                    }
                }
                
            } catch {
                print("Error listening for messages: \(error.localizedDescription)")
            }
        }
    }
    
    func sendMessage(channelId: String, message: Message) async {
        do {
            try await FirebaseCloudStoreService.shared.sendMessage(channelId: channelId, message: message)
        } catch {
            print("Failed to send message \(error.localizedDescription)")
        }
    }

    // MARK: - Message Grouping
    
    typealias MessageGroup = (time: Date, userGroups: [(userId: String, messages: [Message])])
    typealias DayGroup = (date: Date, messageGroups: [MessageGroup])

    func groupedMessages(for channelId: String) -> [DayGroup] {
        guard let messageMap = messages.first(where: { $0.channelId == channelId }) else {
            return []
        }
        
        let groupedByDate = self.groupMessagesByDate(messages: messageMap.messages)
        
        return groupedByDate.map { (date, messagesInDay) -> DayGroup in
            let groupedByHourMinute = self.groupMessagesByHourMinute(messages: messagesInDay)
            
            let messageGroups = groupedByHourMinute.map { (time, messagesInMinute) -> MessageGroup in
                let userGroups = self.groupMessagesByUser(messages: messagesInMinute)
                    .map { (userId, messages) in (userId: userId, messages: messages) }
                return (time: time, userGroups: userGroups)
            }
            return (date: date, messageGroups: messageGroups)
        }
    }

    private func groupMessagesByDate(messages: [Message]) -> [(Date, [Message])] {
        var result: [Date: [Message]] = [:]
        
        for message in messages {
            let date = Calendar.current.startOfDay(for: message.date.dateValue())
            result[date, default: []].append(message)
        }
        return result.sorted { $0.key < $1.key }
    }
    
    private func groupMessagesByHourMinute(messages: [Message]) -> [(Date, [Message])] {
        var result: [Date: [Message]] = [:]
        let calendar = Calendar.current
        
        for message in messages {
            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: message.date.dateValue())
            if let date = calendar.date(from: components) {
                result[date, default: []].append(message)
            }
        }
        return result.sorted { $0.key < $1.key }
    }
    
    private func groupMessagesByUser(messages: [Message]) -> [(String, [Message])] {
        var result: [(String, [Message])] = []
        guard !messages.isEmpty else { return result }
        
        var currentGroup: [Message] = []
        for message in messages {
            if let lastMessage = currentGroup.last {
                let sameUser = lastMessage.senderId == message.senderId
                let sameMinute = Calendar.current.isDate(lastMessage.date.dateValue(), equalTo: message.date.dateValue(), toGranularity: .minute)
                
                if sameUser && sameMinute {
                    currentGroup.append(message)
                } else {
                    result.append((lastMessage.senderId, currentGroup))
                    currentGroup = [message]
                }
            } else {
                currentGroup = [message]
            }
        }
        if let lastMessage = currentGroup.last {
            result.append((lastMessage.senderId, currentGroup))
        }
        return result
    }
}
