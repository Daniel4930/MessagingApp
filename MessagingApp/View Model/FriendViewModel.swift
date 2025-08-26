
//
//  FriendViewModel.swift
//  MessagingApp
//
//  Created by Daniel Le on 8/25/25.
//

import Foundation

@MainActor
class FriendViewModel: ObservableObject {
    @Published var friends: [UserInfo] = []
    
    func fetchFriends(for user: UserInfo) async {
        if !user.friends.isEmpty {
            self.friends = await FirebaseCloudStoreService.shared.fetchFriends(ids: user.friends)
        } else {
            self.friends = []
        }
    }
    
    func addFriend(for user: inout UserInfo, friendId: String) async {
        guard let userId = user.id, !user.friends.contains(friendId) else { return }
        
        var updatedFriends = user.friends
        updatedFriends.append(friendId)
        
        let result = await FirebaseCloudStoreService.shared.updateData(
            collection: FirebaseCloudStoreCollection.users.rawValue,
            documentId: userId,
            newData: ["friends": updatedFriends]
        )
        
        switch result {
        case .success:
            user.friends = updatedFriends
            await fetchFriends(for: user)
        case .failure(let error):
            print("Failed to add friend: \(error.localizedDescription)")
        }
    }
    
    func removeFriend(for user: inout UserInfo, friendId: String) async {
        guard let userId = user.id, let index = user.friends.firstIndex(of: friendId) else { return }
        
        var updatedFriends = user.friends
        updatedFriends.remove(at: index)
        
        let result = await FirebaseCloudStoreService.shared.updateData(
            collection: FirebaseCloudStoreCollection.users.rawValue,
            documentId: userId,
            newData: ["friends": updatedFriends]
        )
        
        switch result {
        case .success:
            user.friends = updatedFriends
            self.friends.removeAll { $0.id == friendId }
        case .failure(let error):
            print("Failed to remove friend: \(error.localizedDescription)")
        }
    }
}
