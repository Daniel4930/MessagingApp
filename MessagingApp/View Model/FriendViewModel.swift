
//
//  FriendViewModel.swift
//  MessagingApp
//
//  Created by Daniel Le on 8/25/25.
//

import Foundation

@MainActor
class FriendViewModel: ObservableObject {
    @Published var friends: [User] = []
    
    func fetchFriends(for user: User) async {
        if !user.friends.isEmpty {
            self.friends = await FirebaseCloudStoreService.shared.fetchData(collection: FirebaseCloudStoreCollection.users, ids: user.friends)
        } else {
            self.friends = []
        }
    }
    
    func addFriend(for user: inout User, friendId: String) async {
        guard let userId = user.id, !user.friends.contains(friendId) else { return }
        
        var updatedFriends = user.friends
        updatedFriends.append(friendId)
        
        do {
            try await FirebaseCloudStoreService.shared.updateData(
                collection: FirebaseCloudStoreCollection.users,
                documentId: userId,
                newData: ["friends": updatedFriends]
            )
            user.friends = updatedFriends
            await fetchFriends(for: user)
            
        } catch {
            print("Failed to add friend: \(error.localizedDescription)")
        }
    }
    
    func removeFriend(for user: inout User, friendId: String) async {
        guard let userId = user.id, let index = user.friends.firstIndex(of: friendId) else { return }
        
        var updatedFriends = user.friends
        updatedFriends.remove(at: index)
        
        do {
            try await FirebaseCloudStoreService.shared.updateData(
                collection: FirebaseCloudStoreCollection.users,
                documentId: userId,
                newData: ["friends": updatedFriends]
            )
            
            user.friends = updatedFriends
            self.friends.removeAll { $0.id == friendId }
        } catch {
            print("Failed to remove friend: \(error.localizedDescription)")
        }
    }
}
