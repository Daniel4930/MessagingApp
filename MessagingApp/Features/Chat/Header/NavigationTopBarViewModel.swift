//
//  NavigationTopBarViewModel.swift
//  MessagingApp
//
//  Created by Daniel Le on 10/27/25.
//

import Foundation

@MainActor
final class NavigationTopBarViewModel: ObservableObject {
    let channelInfo: Channel
    
    init(channelInfo: Channel) {
        self.channelInfo = channelInfo
    }
    
    func getFriendInfo(friendViewModel: FriendViewModel) -> User? {
        return friendViewModel.getFriendDmChannel(memberIds: channelInfo.memberIds)
    }
    
    func getDisplayName(for friend: User) -> String {
        friend.displayName.isEmpty ? friend.userName : friend.displayName
    }
    
    func hasMemberIds() -> Bool {
        !channelInfo.memberIds.isEmpty
    }
}
