//
//  MessageViewModel.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/19/25.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage
import SwiftUI

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
    @Published var uploadProgress: [String: StorageUploadTask] = [:]
    private var messageListenerTasks: [String: Task<Void, Never>] = [:]
    
    deinit {
        messageListenerTasks.values.forEach { $0.cancel() }
    }
    
    private func uploadMessage(channelId: String, message: Message) async {
        do {
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
    
    func listenForMessages(channelId: String, userViewModel: UserViewModel) {
        guard messageListenerTasks[channelId] == nil else {
            return
        }
        
        let task = Task {
            do {
                // 1. Initial Fetch
                let (initialMessages, oldestDocument) = try await FirebaseCloudStoreService.shared.fetchLastMessages(channelId: channelId, limit: 20)
                
                await MainActor.run {
                    let messageMap = MessageMap(
                        channelId: channelId,
                        messages: initialMessages,
                        documentSnapshot: oldestDocument
                    )
                    if let index = self.messages.firstIndex(where: { $0.channelId == channelId }) {
                        self.messages[index] = messageMap
                    } else {
                        self.messages.append(messageMap)
                    }
                }
                
                // 2. Listen for real-time updates, fall back to current date for temporary channel
                let oldestMessageDate = initialMessages.first?.date?.dateValue() ?? Date()
                
                let stream = FirebaseCloudStoreService.shared.listenForMessageUpdates(
                    channelId: channelId,
                    from: oldestMessageDate
                )
                
                for try await (added, modified, removed) in stream {
                    await MainActor.run {
                        if let index = self.messages.firstIndex(where: { $0.channelId == channelId }) {
                            for message in added {
                                if let clientId = message.clientId, let pendingIndex = self.messages[index].messages.firstIndex(where: { $0.clientId == clientId }) {
                                    self.messages[index].messages[pendingIndex].id = message.id
                                    self.messages[index].messages[pendingIndex].date = message.date
                                    self.messages[index].messages[pendingIndex].isPending = false
                                } else {
                                    self.messages[index].messages.append(message)
                                }
                            }
                            
                            // Update modified messages
                            for message in modified {
                                if let msgIndex = self.messages[index].messages.firstIndex(where: { $0.id == message.id }) {
                                    self.messages[index].messages[msgIndex] = message
                                }
                            }
                            
                            // Remove deleted messages
                            if !removed.isEmpty {
                                let removedIds = Set(removed.map { $0.id })
                                self.messages[index].messages.removeAll { removedIds.contains($0.id ?? "") }
                            }
                            
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
        // Optimistically remove the message from the local array for a responsive UI.
        if let index = messages.firstIndex(where: { $0.channelId == channelId }) {
            messages[index].messages.removeAll { $0.id == messageId }
        }
        
        // Trigger the backend deletion.
        FirebaseCloudStoreService.shared.deleteMessage(messageId: messageId, channelId: channelId)
    }
    
    func removeAttachmentFromUploadTask(attachmentIdentifier: String) {
        let _ = uploadProgress.removeValue(forKey: attachmentIdentifier)
    }
    
    private func uploadFilesAndSendMessage(
        senderId: String?,
        selectionData: [UploadedFile],
        channel: Binding<Channel>,
        finalizedText: String?,
        userViewModel: UserViewModel,
        channelViewModel: ChannelViewModel
    ) async throws {
        
        guard let senderId = senderId else { throw UploadError.missingUserInfo }
        
        let clientId = UUID().uuidString
        let pendingMessage = Message(
            senderId: senderId,
            text: finalizedText,
            photoUrls: [],
            videoUrls: [],
            files: [],
            date: Timestamp(date: Date()),
            edited: false,
            reaction: nil,
            forwardMessageId: nil,
            replayMessageId: nil,
            clientId: clientId,
            isPending: true,
            selectionData: selectionData
        )
        
        var currentChannel = channel.wrappedValue
        
        if currentChannel.id == nil {
            let newChannel = ChannelInsert(memberIds: currentChannel.memberIds, type: currentChannel.type)
            do {
                let documentId = try await FirebaseCloudStoreService.shared.addDocument(
                    collection: .channels,
                    data: newChannel,
                    additionalData: nil
                )
                currentChannel.id = documentId
                listenForMessages(channelId: documentId, userViewModel: userViewModel)
                if let newChannelWithListener = channelViewModel.dmChannels.first(where: { $0.id == documentId }) {
                    channel.wrappedValue = newChannelWithListener
                }
                
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
                if let index = messages.firstIndex(where: { $0.channelId == currentChannel.id }) {
                    messages[index].messages.removeAll { $0.clientId == clientId }
                }
                return
            }
        }
        
        if let index = messages.firstIndex(where: { $0.channelId == currentChannel.id }) {
            messages[index].messages.append(pendingMessage)
        } else {
            messages.append(MessageMap(channelId: currentChannel.id!, messages: [pendingMessage]))
        }
        
        guard let channelId = currentChannel.id else {
            print("Channel ID is still nil after creation attempt.")
            return
        }

        var photoUrls: [String] = []
        var videoUrls: [String] = []
        var files: [MessageFile] = []
        
        let dispatchGroup = DispatchGroup()
        
        for file in selectionData {
            dispatchGroup.enter()
            var fileData: Data?
            let fileName: String
            var fileSize: Int = 0
            let storageFolder: FirebaseStorageFolder
            
            switch file.fileType {
            case .photo:
                guard let photoInfo = file.photoInfo else { continue }
                fileData = photoInfo.image.pngData()
                fileName = photoInfo.name
                storageFolder = .images
            case .video:
                guard let videoInfo = file.videoInfo else { continue }
                fileData = videoInfo.videoData
                fileName = videoInfo.name
                storageFolder = .videos
            case .file:
                guard let fileInfo = file.fileInfo else { continue }
                fileData = fileInfo.fileData
                fileName = fileInfo.name
                fileSize = fileInfo.size
                storageFolder = .files
            }
            
            let storageRef = FirebaseStorageService.shared.createChildReference(folder: storageFolder, fileName: fileName)
            
            if let fileData = fileData {
                let uploadTask = FirebaseStorageService.shared.uploadDataToBucket(reference: storageRef, data: fileData) { result in
                    switch result {
                    case .success(let url):
                        switch file.fileType {
                        case .photo:
                            photoUrls.append(url.absoluteString)
                        case .video:
                            videoUrls.append(url.absoluteString)
                        case .file:
                            let messageFile = MessageFile(url: url.absoluteString, data: nil, name: fileName, size: fileSize)
                            files.append(messageFile)
                        }
                    case .failure(let error):
                        print("Failed to upload file: \(error)")
                    }
                    dispatchGroup.leave()
                }
                
                self.uploadProgress[file.identifier] = uploadTask
            } else {
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            Task {
                guard finalizedText != nil || !photoUrls.isEmpty || !files.isEmpty || !videoUrls.isEmpty else {
                    print("Cannot send an empty message")
                    if let index = self.messages.firstIndex(where: { $0.channelId == channelId }) {
                        self.messages[index].messages.removeAll { $0.clientId == clientId }
                    }
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
                    replayMessageId: nil,
                    clientId: clientId
                )
                
                await self.uploadMessage(channelId: channelId, message: message)
            }
        }
    }
    
    func sendMessage(
        sendButtonDisabled: Binding<Bool>,
        channel: Binding<Channel>,
        messageComposerViewModel: MessageComposerViewModel,
        channelViewModel: ChannelViewModel,
        userViewModel: UserViewModel,
        alertViewModel: AlertMessageViewModel
    ) async throws {
        sendButtonDisabled.wrappedValue = true
        do {
            if let channelId = channel.wrappedValue.id,
               let editMessageId = messageComposerViewModel.editedMessageId,
               let finalizedText = messageComposerViewModel.finalizeText() {
                try await updateMessageText(
                    channelId: channelId,
                    messageId: editMessageId,
                    text: finalizedText
                )
                
                if editMessageId == channel.wrappedValue.lastMessage?.messageId {
                    let messageMap = messages.first(where: { $0.channelId == channelId })
                    guard let currentMessage = messageMap?.messages.first(where: { $0.id == editMessageId }) else {
                        print("Failed to get last message in channel")
                        return
                    }
                    
                    var newCurrentMessage = currentMessage
                    newCurrentMessage.text = finalizedText
                    guard let lastMessage = LastMessage(from: newCurrentMessage) else {
                        print("Failed to create last message data")
                        return
                    }
                    
                    try await channelViewModel.updateLastMessage(channelId: channelId, lastMessage: lastMessage)
                }
            } else {
                try await uploadFilesAndSendMessage(
                    senderId: userViewModel.user?.id,
                    selectionData: messageComposerViewModel.selectionData,
                    channel: channel,
                    finalizedText: messageComposerViewModel.finalizeText(),
                    userViewModel: userViewModel,
                    channelViewModel: channelViewModel
                )
                messageComposerViewModel.scrollToBottom = true
            }
            
            messageComposerViewModel.resetInputs()
        } catch {
            print("Error sending message: \(error.localizedDescription)")
            alertViewModel.presentAlert(message: "Failed to send message", type: .error)
        }
        sendButtonDisabled.wrappedValue = false
    }

    // MARK: - Message Grouping
    
    typealias MessageGroup = (time: Date, userGroups: [(userId: String, messages: [Message])])
    typealias DayGroup = (date: Date, messageGroups: [MessageGroup])

    func groupedMessages(for channelId: String) -> [DayGroup] {
        guard let messageMap = messages.first(where: { $0.channelId == channelId }) else {
            return []
        }
        
        return groupedMessages(messages: messageMap.messages)
    }
    
    func groupedMessages(messages: [Message]) -> [DayGroup] {
        let groupedByDate = self.groupMessagesByDate(messages: messages)
        
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
