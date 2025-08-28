//
//  ChannelViewModel.swift
//  MessagingApp
//
//  Created by Daniel Le on 8/25/25.
//

import Foundation
import SwiftUI

// A new struct to replace the tuple, making it Equatable and Identifiable.
struct FriendChannelMap: Equatable, Identifiable {
    var id: String { channel.id! }
    let friend: User
    let channel: Channel
}

@MainActor
class ChannelViewModel: ObservableObject {
    @Published var dmChannels: [Channel] = []
    @Published var serverChannels: [Channel] = []
    @Published var dmChannelsMapWithFriends: [FriendChannelMap] = []
    
    private var channelListenerTask: Task<Void, Never>? = nil

    deinit {
        channelListenerTask?.cancel()
    }

    /// Starts a listener to get real-time updates for all channels a user is a member of.
    func listenForChannels(userId: String, friends: [User]) {
        channelListenerTask?.cancel()
        channelListenerTask = Task {
            do {
                let stream = FirebaseCloudStoreService.shared.listenForUserChannels(userId: userId)
                for try await channels in stream {
                    // Partition the channels into DMs and Servers
                    self.dmChannels = channels.filter { $0.type == ChannelType.dm.rawValue }
                    self.serverChannels = channels.filter { $0.type != ChannelType.dm.rawValue }
                    
                    // After channels are updated, re-sort the DM/friend mapping
                    self.sortDmChannelWithFriends(currentUserId: userId, friends: friends)
                }
            } catch {
                print("Error listening for channels: \(error.localizedDescription)")
            }
        }
    }
    
    /// Maps the dmChannels to their corresponding friend objects.
    private func sortDmChannelWithFriends(currentUserId: String, friends: [User]) {
        dmChannelsMapWithFriends = dmChannels.compactMap { channel -> FriendChannelMap? in
            // Find the other member's ID in the channel
            guard let friendId = channel.memberIds.first(where: { $0 != currentUserId }) else {
                return nil
            }
            // Find the corresponding friend object from the provided list
            guard let friend = friends.first(where: { $0.id == friendId }) else {
                return nil
            }
            return FriendChannelMap(friend: friend, channel: channel)
        }
    }
    
    /// Finds an existing DM channel with another user or creates a new one if it doesn't exist.
    func findOrCreateDmChannel(currentUserId: String, otherUser: User) async -> Channel? {
        // First, check if a DM channel already exists locally in our fetched channels.
        if let existingChannel = dmChannels.first(where: { $0.memberIds.contains(otherUser.id!) }) {
            return existingChannel
        }
        
        // If not, create a new one.
        guard let otherUserId = otherUser.id else { return nil }
        
        let newChannel = ChannelInsert(
            memberIds: [currentUserId, otherUserId],
            type: ChannelType.dm.rawValue
        )
        
        do {
            let documentId = try await FirebaseCloudStoreService.shared.addDocument(
                collection: .channels,
                data: newChannel
            )
            
            // The active listener will pick up the new channel automatically.
            // For immediate UI updates, we can return a temporary local copy of the channel.
            var temporaryChannel = Channel(id: nil, memberIds: newChannel.memberIds, type: newChannel.type, lastActivity: nil, lastMessage: nil)
            temporaryChannel.id = documentId
            return temporaryChannel
        } catch {
            print("Error creating DM channel: \(error.localizedDescription)")
            return nil
        }
    }
}
