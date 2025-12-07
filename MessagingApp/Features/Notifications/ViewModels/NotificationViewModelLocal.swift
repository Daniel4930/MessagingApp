//
//  NotificationViewModel.swift
//  MessagingApp
//
//  Created by Daniel Le on 10/20/25.
//

import Foundation
import FirebaseCore

@MainActor
final class NotificationViewModelLocal: ObservableObject {
    let currentUserId: String?
    
    var notificationViewModel: NotificationViewModel?
    var friendViewModel: FriendViewModel?
    var userViewModel: UserViewModel?
    
    init(userId: String?) {
        self.currentUserId = userId
    }
    
    func setupDependencies(notificationVM: NotificationViewModel, friendVM: FriendViewModel, userVM: UserViewModel) {
        notificationViewModel = notificationVM
        friendViewModel = friendVM
        userViewModel = userVM
    }
    
    func onAppear() {
        if let currentUserId {
            notificationViewModel?.setUserId(currentUserId)
        }
    }
    
    func createAttributedString(for senderName: String) -> AttributedString {
        var result = AttributedString(senderName)
        result.font = .headline.bold()
        return result
    }
    
    func formatTimestamp(_ timestamp: Timestamp) -> String {
        return notificationViewModel?.formatNotificationTimestamp(time: timestamp.dateValue()) ?? ""
    }
    
    func acceptFriendRequest(_ notification: NotificationContent) async {
        do {
            guard let currentUserId = validateCurrentUser() else { return }
            guard let sender = try await fetchSender(for: notification.senderName) else { return }
            guard let senderId = validateSender(sender) else { return }
            
            try await updateFriendships(currentUserId: currentUserId, senderId: senderId, sender: sender)
            try await removeNotification(notification)
            
        } catch {
            print("Error accepting friend request: \(error.localizedDescription)")
        }
    }
    
    func declineFriendRequest(_ notification: NotificationContent) async {
        do {
            try await removeNotification(notification)
        } catch {
            print("Error declining friend request: \(error.localizedDescription)")
        }
    }
}

// MARK: - Friend Request Helper Methods
extension NotificationViewModelLocal {
    
    private func validateCurrentUser() -> String? {
        guard let currentUserId = currentUserId else {
            print("Current user's id is nil")
            return nil
        }
        return currentUserId
    }
    
    private func fetchSender(for senderName: String) async throws -> User? {
        let sender = await FirebaseCloudStoreService.shared.fetchUserByUsername(username: senderName)
        guard let sender = sender else {
            print("Sender is nil")
            return nil
        }
        return sender
    }
    
    private func validateSender(_ sender: User) -> String? {
        guard let senderId = sender.id else {
            print("Sender id is nil")
            return nil
        }
        return senderId
    }
    
    private func updateFriendships(currentUserId: String, senderId: String, sender: User) async throws {
        try await updateSenderFriendList(senderId: senderId, sender: sender, currentUserId: currentUserId)
        try await updateCurrentUserFriendList(currentUserId: currentUserId, senderId: senderId)
    }
    
    private func updateSenderFriendList(senderId: String, sender: User, currentUserId: String) async throws {
        var senderFriends = sender.friends
        guard !senderFriends.contains(currentUserId) else { return }
        
        senderFriends.append(currentUserId)
        let senderUpdate: [String: Any] = ["friends": senderFriends]
        
        try await FirebaseCloudStoreService.shared.updateData(
            collection: .users,
            documentId: senderId,
            newData: senderUpdate
        )
    }
    
    private func updateCurrentUserFriendList(currentUserId: String, senderId: String) async throws {
        var currentUserFriends = userViewModel?.user?.friends ?? []
        guard !currentUserFriends.contains(senderId) else { return }
        
        currentUserFriends.append(senderId)
        let currentUserUpdate: [String: Any] = ["friends": currentUserFriends]
        
        try await FirebaseCloudStoreService.shared.updateData(
            collection: .users,
            documentId: currentUserId,
            newData: currentUserUpdate
        )
    }
    
    private func removeNotification(_ notification: NotificationContent) async throws {
        guard let notificationId = notification.id else {
            print("Notification id is nil")
            return
        }
        
        try await FirebaseCloudStoreService.shared.deleteDocument(
            collection: .notifications,
            documentId: notificationId
        )
        
        guard let index = notificationViewModel?.notifications.firstIndex(where: { $0 == notification }) else {
            print("Notification index is nil")
            return
        }
        
        notificationViewModel?.notifications.remove(at: index)
    }
}
