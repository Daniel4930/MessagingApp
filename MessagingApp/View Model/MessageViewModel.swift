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
    private var messageListenerTasks: [String: Task<Void, Never>] = [:]
    
    deinit {
        messageListenerTasks.values.forEach { $0.cancel() }
    }
    
    private func sendMessage(channelId: String, message: Message) async {
        do {
            // Send the message
            try await FirebaseCloudStoreService.shared.sendMessage(channelId: channelId, message: message)
        } catch {
            print("Failed to send message or update channel: \(error.localizedDescription)")
        }
    }
    
    func stopListening(channelId: String?) {
        if let channelId {
            messageListenerTasks[channelId]?.cancel()
            messageListenerTasks[channelId] = nil
        }
    }
    
    func listenForMessages(channelId: String) {
        guard messageListenerTasks[channelId] == nil else {
            return
        }
        
        let task = Task {
            do {
                // 1. Initial Fetch
                let (initialMessages, lastDocument) = try await FirebaseCloudStoreService.shared.fetchLastMessages(channelId: channelId, limit: 10)
                
                await MainActor.run {
                    let messageMap = MessageMap(channelId: channelId, messages: initialMessages, documentSnapshot: lastDocument)
                    if let index = self.messages.firstIndex(where: { $0.channelId == channelId }) {
                        self.messages[index] = messageMap
                    } else {
                        self.messages.append(messageMap)
                    }
                }
                
                // 2. Listen for real-time updates
                let oldestMessageDate = initialMessages.first?.date?.dateValue() ?? Date()
                let stream = FirebaseCloudStoreService.shared.listenForMessageUpdates(channelId: channelId, from: oldestMessageDate)
                
                for try await (added, modified, removed) in stream {
                    await MainActor.run {
                        if let index = self.messages.firstIndex(where: { $0.channelId == channelId }) {
                            let existingMessageIds = Set(self.messages[index].messages.map { $0.id })
                            
                            // Add new messages that aren't already present
                            let newMessages = added.filter { !existingMessageIds.contains($0.id) }
                            self.messages[index].messages.append(contentsOf: newMessages)
                            
                            // Update modified messages
                            for message in modified {
                                if let msgIndex = self.messages[index].messages.firstIndex(where: { $0.id == message.id }) {
                                    self.messages[index].messages[msgIndex] = message
                                }
                            }
                            
                            // Remove deleted messages
                            let removedIds = Set(removed.map { $0.id })
                            self.messages[index].messages.removeAll { removedIds.contains($0.id) }
                            
                            // Ensure sorting
                            self.messages[index].messages.sort { ($0.date?.dateValue() ?? .distantPast) < ($1.date?.dateValue() ?? .distantPast) }
                        }
                    }
                }
            } catch {
                if !(error is CancellationError) {
                    print("Error listening for messages on channel \(channelId): \(error.localizedDescription)")
                }
            }
        }
        messageListenerTasks[channelId] = task
    }
    
    func fetchMoreMessages(channelId: String) async {
        guard let index = messages.firstIndex(where: { $0.channelId == channelId }),
              let lastSnapshot = messages[index].documentSnapshot else {
            // No more messages to load or already loading
            return
        }

        do {
            let (olderMessages, newSnapshot) = try await FirebaseCloudStoreService.shared.fetchMoreMessages(channelId: channelId, lastDocumentSnapshot: lastSnapshot)
            
            await MainActor.run {
                self.messages[index].messages.insert(contentsOf: olderMessages, at: 0)
                self.messages[index].documentSnapshot = newSnapshot
            }
        } catch {
            print("Error fetching more messages: \(error.localizedDescription)")
        }
    }
    
    func updateMessageText(channelId: String, messageId: String, text: String) async throws {
        do {
            try await FirebaseCloudStoreService.shared.updateMessageText(channleId: channelId, messageId: messageId, text: text)
        } catch {
            throw error
        }
    }
    
    func deleteMessage(messageId: String, channelId: String) {
        FirebaseCloudStoreService.shared.deleteMessage(messageId: messageId, channelId: channelId)
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
                let documentId = try await FirebaseCloudStoreService.shared.addDocument(collection: .channels, data: newChannel, additionalData: nil)
                currentChannel.id = documentId
                listenForMessages(channelId: documentId)
                
                try await withThrowingTaskGroup(of: Void.self) { group in
                    for memberId in currentChannel.memberIds {
                        group.addTask {
                            try await FirebaseCloudStoreService.shared.updateData(
                                collection: .users,
                                documentId: memberId,
                                newData: ["channelId": FieldValue.arrayUnion([documentId])]
                            )
                        }
                    }
                    try await group.waitForAll()
                }
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

        struct UploadResult {
            let url: URL?
            let fileType: UploadedFile.FileType
            let name: String
            let size: Int
        }

        var photoUrls: [String] = []
        var videoUrls: [String] = []
        var files: [MessageFile] = []
        
        try await withThrowingTaskGroup(of: UploadResult.self) { group in
            for file in selectionData {
                group.addTask {
                    var fileData: Data?
                    let fileName: String
                    var fileSize: Int = 0
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
                        fileData = videoInfo.videoData
                        fileName = videoInfo.name
                        storageFolder = .videos
                    case .file:
                        guard let fileInfo = file.fileInfo else { throw UploadError.missingData }
                        fileData = fileInfo.fileData
                        fileName = fileInfo.name
                        fileSize = fileInfo.size
                        storageFolder = .files
                    }
                    
                    let storageRef = FirebaseStorageService.shared.createChildReference(
                        folder: storageFolder,
                        fileName: fileName
                    )
                    
                    if let fileData {
                        downloadUrl = try await FirebaseStorageService.shared.uploadData(reference: storageRef, data: fileData)
                    }
                    
                    return UploadResult(url: downloadUrl, fileType: file.fileType, name: fileName, size: fileSize)
                }
            }
            
            for try await result in group {
                if let url = result.url {
                    switch result.fileType {
                    case .photo:
                        photoUrls.append(url.absoluteString)
                    case .video:
                        videoUrls.append(url.absoluteString)
                    case .file:
                        let messageFile = MessageFile(url: url.absoluteString, name: result.name, size: result.size)
                        files.append(messageFile)
                    }
                }
            }
        }
        
        guard finalizedText != nil || !photoUrls.isEmpty || !files.isEmpty || !videoUrls.isEmpty else {
            print("Cannot send an empty message")
            return
        }
        
        let message = Message (
            senderId: senderId,
            text: finalizedText,
            photoUrls: photoUrls,
            videoUrls: videoUrls,
            files: files,
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
