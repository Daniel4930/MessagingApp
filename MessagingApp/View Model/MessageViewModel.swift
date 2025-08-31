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

enum UploadError: Error {
    case missingData
    case missingFileName
    case missingUserInfo
    case uploadFailed(String)
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
    
    private func sendMessage(channelId: String, message: Message) async {
        do {
            try await FirebaseCloudStoreService.shared.sendMessage(channelId: channelId, message: message)
        } catch {
            print("Failed to send message \(error.localizedDescription)")
        }
    }
    
    func uploadFilesAndSendMessage(senderId: String?, selectionData: [UploadedFile], channel: Channel, finalizedText: String?) async throws {
        guard let senderId = senderId else { throw UploadError.missingUserInfo }
        
        var currentChannel = channel
        
        // If the channel doesn't have an ID, it's a draft. Create it first.
        if currentChannel.id == nil {
            let newChannel = ChannelInsert(
                memberIds: currentChannel.memberIds,
                type: currentChannel.type
            )
            do {
                let documentId = try await FirebaseCloudStoreService.shared.addDocument(collection: .channels, data: newChannel)
                currentChannel.id = documentId
            } catch {
                print("Error creating channel: \(error.localizedDescription)")
                // Handle or rethrow the error as needed
                return
            }
        }
        
        guard let channelId = currentChannel.id else {
            print("Channel ID is still nil after creation attempt.")
            return
        }

        var photoUrls: [String] = []
        var fileUrls: [String] = []
        
        try await withThrowingTaskGroup(of: (url: URL?, fileType: UploadedFile.FileType).self) { group in
            for file in selectionData {
                group.addTask {
                    var fileData: Data?
                    var fileUrl: URL?
                    let fileName: String
                    let storageFolder: FirebaseStorageFolder
                    var downloadUrl: URL?
                    
                    // Extract data and metadata from the UploadedFile struct
                    switch file.fileType {
                    case .photo:
                        guard let photoInfo = file.photoInfo else { throw UploadError.missingData }
                        fileData = photoInfo.image.pngData()
                        fileName = photoInfo.name
                        storageFolder = .images
                    case .video:
                        guard let videoInfo = file.videoInfo else { throw UploadError.missingData }
                        fileUrl = videoInfo.videoFileUrl
                        fileName = videoInfo.name
                        storageFolder = .videos
                    case .file:
                        guard let fileInfo = file.fileInfo else { throw UploadError.missingData }
                        fileData = fileInfo.data
                        fileName = fileInfo.name
                        storageFolder = .files
                    }
                    
                    let storageRef = FirebaseStorageService.shared.createChildReference(
                        folder: storageFolder,
                        fileName: fileName
                    )
                    
                    if let fileUrl {
                        downloadUrl = try await FirebaseStorageService.shared.uploadFile(reference: storageRef, fileUrl: fileUrl)
                    } else if let fileData {
                        downloadUrl = try await FirebaseStorageService.shared.uploadData(reference: storageRef, data: fileData)
                    }
                    return (url: downloadUrl, fileType: file.fileType)
                }
            }
            
            for try await result in group {
                if let url = result.url {
                    switch result.fileType {
                    case .photo:
                        photoUrls.append(url.absoluteString)
                    case .video, .file:
                        fileUrls.append(url.absoluteString)
                    }
                }
            }
        }
        
        guard finalizedText != nil || !photoUrls.isEmpty || !fileUrls.isEmpty else {
            print("Cannot send an empty message")
            return
        }
        
        let message = Message (
            senderId: senderId,
            text: finalizedText,
            photoUrls: photoUrls,
            fileUrls: fileUrls,
            date: Timestamp(),
            edited: false,
            reaction: nil,
            forwardMessageId: nil,
            replayMessageId: nil
        )
        
        await sendMessage(channelId: channelId, message: message)
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
            if let date = message.date {
                let date = Calendar.current.startOfDay(for: date.dateValue())
                result[date, default: []].append(message)
            }
        }
        return result.sorted { $0.key < $1.key }
    }
    
    private func groupMessagesByHourMinute(messages: [Message]) -> [(Date, [Message])] {
        let calendar = Calendar.current
        let groupedByMinute = Dictionary(grouping: messages) { message -> Date in
            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: message.date!.dateValue())
            return calendar.date(from: components)!
        }

        let sortedGroups = groupedByMinute.mapValues { messagesInMinute -> [Message] in
            return messagesInMinute.sorted { $0.date!.dateValue() < $1.date!.dateValue() }
        }

        return sortedGroups.sorted { $0.key < $1.key }
    }
    
    private func groupMessagesByUser(messages: [Message]) -> [(String, [Message])] {
        var result: [(String, [Message])] = []
        guard !messages.isEmpty else { return result }
        
        var currentGroup: [Message] = []
        for message in messages {
            if let lastMessage = currentGroup.last, let date = message.date, let lastMessageDate = lastMessage.date {
                let sameUser = lastMessage.senderId == message.senderId
                let sameMinute = Calendar.current.isDate(lastMessageDate.dateValue(), equalTo: date.dateValue(), toGranularity: .minute)
                
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
