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
    
//    /// Maps the dmChannels to their corresponding friend objects.
//    private func sortDmChannelWithFriends(currentUserId: String, friends: [User]) {
//        dmChannelsMapWithFriends = channels.compactMap { channel -> FriendChannelMap? in
//            // Find the other member's ID in the channel
//            guard let friendId = channel.memberIds.first(where: { $0 != currentUserId }) else {
//                return nil
//            }
//            // Find the corresponding friend object from the provided list
//            guard let friend = friends.first(where: { $0.id == friendId }) else {
//                return nil
//            }
//            return FriendChannelMap(friend: friend, channel: channel)
//        }
//    }

    /// Starts a listener to get real-time updates for all channels a user is a member of.
    func listenForChannels(userId: String, friends: [User]) {
        channelListenerTask?.cancel()
        channelListenerTask = Task {
            do {
                let stream = FirebaseCloudStoreService.shared.listenForUserChannels(userId: userId)
                for try await channels in stream {
                    self.channels = channels
                    
//                    // After channels are updated, re-sort the DM/friend mapping
//                    self.sortDmChannelWithFriends(currentUserId: userId, friends: friends)
                }
            } catch {
                print("Error listening for channels: \(error.localizedDescription)")
            }
        }
    }
    
    /// Finds an existing DM channel with another user or creates a new one if it doesn't exist.
    func findOrCreateDmChannel(currentUserId: String, otherUser: User) -> Channel? {
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
