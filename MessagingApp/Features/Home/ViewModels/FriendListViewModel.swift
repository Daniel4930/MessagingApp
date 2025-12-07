//
//  FriendListViewModel.swift
//  MessagingApp
//
//  Created by Daniel Le on 10/20/25.
//

import Foundation

@MainActor
final class FriendListViewModel: ObservableObject {
    @Published var nameToSearch: String = ""
    @Published var listItemWidth: CGFloat = .zero
    
    func searchResult(friendViewModel: FriendViewModel) -> [User] {
        let friends = friendViewModel.friends
        
        if nameToSearch.isEmpty {
            return friends
        } else {
            return friends.filter { $0.displayName.localizedStandardContains(nameToSearch) || $0.userName.localizedStandardContains(nameToSearch) }
        }
    }
    
    func createDMChannel(
        with friend: User,
        userViewModel: UserViewModel,
        channelViewModel: ChannelViewModel
    ) -> Channel? {
        guard let currentUserId = userViewModel.user?.id else { return nil }
        
        return channelViewModel.findOrCreateTempChannel(currentUserId: currentUserId, otherUser: friend)
    }
    
    func removeFriend(
        _ friend: User,
        userViewModel: UserViewModel,
        friendViewModel: FriendViewModel
    ) async {
        guard let user = userViewModel.user,
              let friendId = friend.id else { return }
        
        await friendViewModel.removeFriend(for: user, friendId: friendId)
    }
    
    func updateListItemWidth(_ width: CGFloat) {
        listItemWidth = width * 0.1
    }
}
