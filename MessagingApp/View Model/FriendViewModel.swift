//
//  FriendViewModel.swift
//  MessagingApp
//
//  Created by Daniel Le on 8/25/25.
//

import Foundation
import FirebaseFirestore

@MainActor
class FriendViewModel: ObservableObject {
    @Published var friends: [User] = []
    private var friendListenerTasks: [String: Task<Void, Never>] = [:]
    
    deinit {
        friendListenerTasks.values.forEach { $0.cancel() }
    }
    
    func stopListening(friendId: String?) {
        if let friendId {
            friendListenerTasks[friendId]?.cancel()
            friendListenerTasks[friendId] = nil
        }
    }
    
    func listenForFriend(friendId: String) {
        guard friendListenerTasks[friendId] == nil else {
            return
        }
        
        let task = Task {
            do {
                let stream = FirebaseCloudStoreService.shared.listenForFriendUpdates(friendId: friendId)
                
                for try await friend in stream {
                    if self.friends.contains(where: { $0.id == friend.id }), let index = self.friends.firstIndex(where: { $0.id == friend.id }) {
                        self.friends[index] = friend
                    }
                }
            } catch {
                print("Error listening for updates of friend \(friendId): \(error.localizedDescription)")
            }
        }
        
        friendListenerTasks[friendId] = task
    }
    
    func fetchFriends(for user: User) async {
        if !user.friends.isEmpty {
            self.friends = await FirebaseCloudStoreService.shared.fetchData(collection: FirebaseCloudStoreCollection.users, ids: user.friends)
            for friend in friends {
                if let id = friend.id {
                    listenForFriend(friendId: id)
                }
            }
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
        return nil
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
    
    func removeFriend(for user: User, friendId: String) async {
        guard let userId = user.id else { return }
        
        do {
            try await FirebaseCloudStoreService.shared.updateData(
                collection: FirebaseCloudStoreCollection.users,
                documentId: userId,
                newData: ["friends": FieldValue.arrayRemove([friendId])]
            )
            
            try await FirebaseCloudStoreService.shared.updateData(
                collection: FirebaseCloudStoreCollection.users,
                documentId: friendId,
                newData: ["friends" : FieldValue.arrayRemove([userId])]
            )
            
            self.friends.removeAll { $0.id == friendId }
            stopListening(friendId: friendId)
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
