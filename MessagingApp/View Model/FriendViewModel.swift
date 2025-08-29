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
    
    // Cache for users who are not friends
    @Published var fetchedUsers: [String: User] = [:]
    
    func fetchFriends(for user: User) async {
        if !user.friends.isEmpty {
            self.friends = await FirebaseCloudStoreService.shared.fetchData(collection: FirebaseCloudStoreCollection.users, ids: user.friends)
        } else {
            self.friends = []
        }
    }
    
    /// Synchronously gets a user from local data if available (current user, friends, or cache).
    func getUser(withId id: String, currentUser: User?) -> User? {
        if let user = currentUser, user.id == id {
            return user
        }
        if let friend = friends.first(where: { $0.id == id }) {
            return friend
        }
        return fetchedUsers[id]
    }
    
    /// Fetches a user from the server if they aren't available locally and adds them to the cache.
    func fetchUserIfNeeded(withId id: String) async {
        // Avoid re-fetching if user is already in the cache
        guard fetchedUsers[id] == nil else { return }
        
        let users: [User] = await FirebaseCloudStoreService.shared.fetchData(collection: .users, ids: [id])
        if let user = users.first {
            fetchedUsers[id] = user
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
    
    func getFriendDmChannel(memberIds: [String]) -> User? {
        friends.first(where: { user in
            if let id = user.id {
                return memberIds.contains(id)
            } else {
                print("Id is nil")
            }
            return false
        })
    }
}