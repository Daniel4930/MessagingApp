//
//  ChannelViewModel.swift
//  MessagingApp
//
//  Created by Daniel Le on 8/25/25.
//

import Foundation
import SwiftUI
import FirebaseFirestore

@MainActor
class ChannelViewModel: ObservableObject {
    @Published var channels: [Channel] = []
    
    private var channelListenerTask: Task<Void, Never>? = nil

    deinit {
        channelListenerTask?.cancel()
    }
    
    func formatLastMessageTime(time: Date) -> String {
        let pastDate = Date().addingTimeInterval(time.timeIntervalSinceNow)
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.dateTimeStyle = .numeric
        return formatter.string(for: pastDate)!
    }

    /// Starts a listener to get real-time updates for all channels a user is a member of.
    func listenForChannels(userId: String, friends: [User]) {
        channelListenerTask?.cancel()
        channelListenerTask = Task {
            do {
                let stream = FirebaseCloudStoreService.shared.listenForUserChannels(userId: userId)
                for try await channels in stream {
                    self.channels = channels
                }
            } catch {
                print("Error listening for channels: \(error.localizedDescription)")
            }
        }
    }
    
    func createChannel(memberIds: [String]) async throws -> String {
        let newChannel = ChannelInsert(memberIds: memberIds)
        
        let documentId = try await FirebaseCloudStoreService.shared.addDocument(
            collection: .channels,
            data: newChannel,
            additionalData: nil
        )
        
        return documentId
    }
    
    /// Finds an existing DM channel with another user or creates a new one if it doesn't exist.
    func findOrCreateTempChannel(currentUserId: String, otherUser: User) -> Channel? {
        if let existingChannel = channels.first(where: { $0.memberIds.contains(otherUser.id!) }) {
            return existingChannel
        }
        
        guard let otherUserId = otherUser.id else { return nil }
        
        let temporaryChannel = Channel(
            id: nil,
            memberIds: [currentUserId, otherUserId],
            lastActivity: nil,
            lastMessage: nil
        )
        return temporaryChannel
    }
    
    func updateLastMessage(channelId: String, lastMessage: LastMessage) async throws {
        do {
            let lastMessageData = try Firestore.Encoder().encode(lastMessage)
            let updateData = ["lastMessage": lastMessageData]
            
            try await FirebaseCloudStoreService.shared.updateData(
                collection: .channels,
                documentId: channelId,
                newData: updateData
            )
        } catch {
            throw error
        }
    }
}
