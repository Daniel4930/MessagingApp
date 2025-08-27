//
//  ChannelViewModel.swift
//  MessagingApp
//
//  Created by Daniel Le on 8/25/25.
//

import Foundation
import SwiftUI

@MainActor
class ChannelViewModel: ObservableObject {
    @Published var dmChannels: [ChannelInfo] = []
    @Published var serverChannel: [ChannelInfo] = []
    @Published var dmChannelsMapWithFriends: [(friend: UserInfo, channel: ChannelInfo)] = []
    
    private func checkIfDmChannelExists(otherUserChannel: [String]) -> String? {
        dmChannels.first(where: { otherUserChannel.contains($0.id!) })?.id
    }
    
    func sortDmChannelWithFriends(friends: [UserInfo]) {
        // Find and sort conversations with friends
        let currentDmChannelId = dmChannels.map { $0.id }
        
        dmChannelsMapWithFriends = friends.compactMap { friend -> (friend: UserInfo, channel: ChannelInfo)? in
            guard let commonChannelId = friend.channelId.first(where: { currentDmChannelId.contains($0) }) else { return nil }
            guard let targetChannel = dmChannels.first(where: { $0.id == commonChannelId }) else { return nil }
            
            return (friend, targetChannel)
        }
    }
    
    func fetchChannels(for ids: [String]) async {
        let channels: [ChannelInfo] = await FirebaseCloudStoreService.shared.fetchData(collection: FirebaseCloudStoreCollection.channels.rawValue, ids: ids)
        
        for channel in channels {
            if channel.type == ChannelType.dm.rawValue {
                dmChannels.append(channel)
            } else {
                serverChannel.append(channel)
            }
        }
    }
    
    func getDmChannel(currentUser: UserInfo, otherUser: UserInfo) async -> ChannelInfo? {
        if let matchedChannelId = checkIfDmChannelExists(otherUserChannel: otherUser.channelId) {
            // Channel already exists, return it from the local cache.
            return dmChannels.first(where: { $0.id == matchedChannelId })
        } else {
            // Channel does not exist, create a new one.
            let newChannel = ChannelInsert(messageIds: [], type: ChannelType.dm.rawValue)

            // 1. Create the channel document in Firestore.
            guard let documentId = await FirebaseCloudStoreService.shared.addDocument(
                collection: FirebaseCloudStoreCollection.channels.rawValue,
                documentId: nil,
                data: newChannel
            ) else {
                print("Error: Failed to create new channel document in Firestore.")
                return nil
            }

            // 2. Ensure we have the necessary user information.
            guard let otherUserId = otherUser.id,
                  let currentUserId = currentUser.id else {
                print("Error: Missing user information. Cannot update channel lists.")
                // Note: This leaves an orphaned channel document. A more robust implementation
                // would delete the created channel document here.
                return nil
            }

            // 3. Update both users' channel lists concurrently.
            async let otherUserUpdateResult = FirebaseCloudStoreService.shared.updateData(
                collection: FirebaseCloudStoreCollection.users.rawValue,
                documentId: otherUserId,
                newData: ["channelId": otherUser.channelId + [documentId]]
            )

            async let currentUserUpdateResult = FirebaseCloudStoreService.shared.updateData(
                collection: FirebaseCloudStoreCollection.users.rawValue,
                documentId: currentUserId,
                newData: ["channelId": currentUser.channelId + [documentId]]
            )

            let (res1, res2) = await (otherUserUpdateResult, currentUserUpdateResult)

            if case .failure(let error) = res1 {
                print("Failed to update other user's channel list: \(error.localizedDescription)")
            }
            if case .failure(let error) = res2 {
                print("Failed to update current user's channel list: \(error.localizedDescription)")
            }
            
            // 4. Update the local channel object with the new ID and add it to the local cache.
            dmChannels.append(ChannelInfo(id: documentId, messageIds: [], type: ChannelType.dm.rawValue))
            
            return dmChannels.first
        }
    }
}
