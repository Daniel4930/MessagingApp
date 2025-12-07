//
//  HomeViewModel.swift
//  MessagingApp
//
//  Created by Daniel Le on 10/20/25.
//

import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var selectedChannel: Channel?
    @Published var showFriendList = false
    @Published var channelToFriendMap: [String: User] = [:]
    
    /// Listens for changes in channels and users
    func listenForUpdates(
        userViewModel: UserViewModel,
        channelViewModel: ChannelViewModel,
        friendViewModel: FriendViewModel
    ) {
        guard let currentUser = userViewModel.user, let userId = currentUser.id else { return }
        channelViewModel.listenForChannels(userId: userId, friends: friendViewModel.friends)
        userViewModel.listenForUserChanges(userId: userId, friendViewModel: friendViewModel)
    }
    
    func updateSelectedChannel(with channel: Channel) {
        selectedChannel = channel
    }
    
    func showListFriend() {
        showFriendList.toggle()
    }

    func updateChannelToFriendMap(
        channelViewModel: ChannelViewModel,
        friendViewModel: FriendViewModel,
        userViewModel: UserViewModel
    ) { 
        var map: [String: User] = [:]

        for channel in channelViewModel.channels {
            guard let channelId = channel.id else { continue }
            if let friendId = channel.memberIds.first(where: { $0 != userViewModel.user?.id }),
               let friend = friendViewModel.friends.first(where: { $0.id == friendId }) {
                map[channelId] = friend
            }
        }
        channelToFriendMap = map
    }
}
