//
//  CustomTextEditorViewModel.swift
//  MessagingApp
//
//  Created by Daniel Le on 10/29/25.
//

import Foundation

@MainActor
final class CustomTextEditorViewModel: ObservableObject {
    @Published var cachedChannelMembers: [User] = []
    @Published var lastMemberIds: [String] = []
    
    func updateCachedMembers(memberIds: [String], friendViewModel: FriendViewModel) {
        if memberIds != lastMemberIds {
            lastMemberIds = memberIds
            cachedChannelMembers = friendViewModel.friends.filter({ memberIds.contains($0.id!) })
        }
    }
    
    func searchUser(users: [User], messageComposerViewModel: MessageComposerViewModel) -> [User] {
        guard let message = messageComposerViewModel.uiTextEditor.text else { return [] }

        //message = "@"
        guard let commandIndex = message.lastIndex(of: "@") else { return [] }

        if message.count == 1 {
            return users
        }

        if commandIndex != message.startIndex {
            guard let spaceIndex = message.lastIndex(of: " ") else { return [] }
            //message = "text@ " && message = "text @ "
            guard message.distance(from: spaceIndex, to: commandIndex) == 1 else { return [] }

            //message = "text @"
            if message[commandIndex] == message.last {
                return users
            }
        }

        //message = "text @name"
        let nameToSearch = String(message[commandIndex...]).dropFirst().lowercased()

        // Optimized filtering with pre-lowercased comparison
        return users.filter { user in
            user.userName.lowercased().contains(nameToSearch) || user.displayName.lowercased().contains(nameToSearch)
        }
    }
}
