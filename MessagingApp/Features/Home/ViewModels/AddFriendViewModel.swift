//
//  AddFriendViewModel.swift
//  MessagingApp
//
//  Created by Daniel Le on 10/20/25.
//

import SwiftUI

@MainActor
final class AddFriendViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var usernameErrorMessage: String = ""
    @Published var isLoading: Bool = false
    
    func sendFriendRequest(
        userViewModel: UserViewModel,
        friendViewModel: FriendViewModel,
        notificationViewModel: NotificationViewModel,
        alertMessageViewModel: AlertMessageViewModel
    ) async {
        usernameErrorMessage = ""
        
        guard validateUsername(userViewModel: userViewModel) else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await performFriendRequestFlow(
                userViewModel: userViewModel,
                friendViewModel: friendViewModel,
                notificationViewModel: notificationViewModel,
                alertMessageViewModel: alertMessageViewModel
            )
        } catch {
            handleFriendRequestError(error, alertMessageViewModel: alertMessageViewModel)
        }
    }
    
    // MARK: - Private Helper Methods
    
    private func performFriendRequestFlow(
        userViewModel: UserViewModel,
        friendViewModel: FriendViewModel,
        notificationViewModel: NotificationViewModel,
        alertMessageViewModel: AlertMessageViewModel
    ) async throws {
        guard let currentUser = userViewModel.user else {
            showAlert(
                message: "Failed to send friend request",
                type: .error,
                alertMessageViewModel: alertMessageViewModel)
            return
        }
        
        // Check if user is already a friend
        try await checkIfAlreadyFriend(friendViewModel: friendViewModel, alertMessageViewModel: alertMessageViewModel)
        
        // Fetch the target user
        let targetUser = try await fetchTargetUser(alertMessageViewModel: alertMessageViewModel)
        
        // Check existing friend requests
        try await checkExistingFriendRequests(currentUser: currentUser, targetUser: targetUser, alertMessageViewModel: alertMessageViewModel)
        
        // Send the friend request
        try await sendNotification(
            to: targetUser,
            from: currentUser,
            notificationViewModel: notificationViewModel,
            alertMessageViewModel: alertMessageViewModel
        )
        
        handleSuccessfulRequest(alertMessageViewModel: alertMessageViewModel)
    }
    
    private func checkIfAlreadyFriend(friendViewModel: FriendViewModel, alertMessageViewModel: AlertMessageViewModel) async throws {
        guard !friendViewModel.friends.contains(where: { $0.userName == username }) else {
            showAlert(
                message: "\(username) is already in the friend list",
                type: .error,
                alertMessageViewModel: alertMessageViewModel
            )
            throw FriendRequestError.alreadyFriend
        }
    }
    
    private func fetchTargetUser(alertMessageViewModel: AlertMessageViewModel) async throws -> User {
        guard let user = await FirebaseCloudStoreService.shared.fetchUserByUsername(username: username) else {
            showAlert(
                message: "User does not exist",
                type: .error,
                alertMessageViewModel: alertMessageViewModel
            )
            throw FriendRequestError.userNotFound
        }
        return user
    }
    
    private func checkExistingFriendRequests(
        currentUser: User,
        targetUser: User,
        alertMessageViewModel: AlertMessageViewModel
    ) async throws {
        // Check if current user already sent a request to target user
        let friendRequestToUser = try await FirebaseCloudStoreService.shared.fetchFriendRequest(
            recipientId: targetUser.id!,
            senderName: currentUser.userName
        )
        
        if let friendRequestToUser = friendRequestToUser, !friendRequestToUser.isEmpty {
            showAlert(
                message: "A friend request has already been sent to \(username)",
                type: .error,
                alertMessageViewModel: alertMessageViewModel
            )
            throw FriendRequestError.requestAlreadySent
        }
        
        // Check if target user already sent a request to current user
        let friendRequestToCurrentUser = try await FirebaseCloudStoreService.shared.fetchFriendRequest(
            recipientId: currentUser.id!,
            senderName: username
        )
        
        if let friendRequestToCurrentUser = friendRequestToCurrentUser, !friendRequestToCurrentUser.isEmpty {
            showAlert(
                message: "\(username) has already sent a friend request to you. Please accept it in the notifications tab",
                type: .info,
                alertMessageViewModel: alertMessageViewModel
            )
            throw FriendRequestError.requestAlreadyReceived
        }
    }
    
    private func sendNotification(
        to targetUser: User,
        from currentUser: User,
        notificationViewModel: NotificationViewModel,
        alertMessageViewModel: AlertMessageViewModel
    ) async throws {
        
        let notification = notificationViewModel.setupNotificationContent(
            recipientId: targetUser.id,
            senderName: currentUser.userName,
            type: NotificationType.friendRequest,
            channelId: nil,
            isRead: false
        )
        
        guard let notification = notification else {
            showAlert(
                message: "Failed to send friend request",
                type: .error,
                alertMessageViewModel: alertMessageViewModel
            )
            throw FriendRequestError.notificationCreationFailed
        }
        
        try await notificationViewModel.addNotification(notification: notification)
    }
    
    private func handleSuccessfulRequest(alertMessageViewModel: AlertMessageViewModel) {
        showAlert(
            message: "Friend request sent",
            type: .success,
            alertMessageViewModel: alertMessageViewModel
        )
        username = "" // Clear username after successful request
    }
    
    private func handleFriendRequestError(_ error: Error, alertMessageViewModel: AlertMessageViewModel) {        
        showAlert(
            message: "Failed to send friend request",
            type: .error,
            alertMessageViewModel: alertMessageViewModel
        )
        print("Friend request error: \(error)")
    }
    
    private func showAlert(
        message: String,
        type: AlertType,
        alertMessageViewModel: AlertMessageViewModel
    ) {
        alertMessageViewModel.presentAlert(message: message, type: type)
    }
    
    private func validateUsername(userViewModel: UserViewModel) -> Bool {
        if username.isEmpty {
            usernameErrorMessage = "Username is empty"
            return false
        } else if username == userViewModel.user?.userName {
            usernameErrorMessage = "Can't friend yourself"
            return false
        } else if username.contains(" ") {
            usernameErrorMessage = "Username can't contain spaces"
            return false
        }
        
        return true
    }
}

// MARK: - Friend Request Error Types

private enum FriendRequestError: Error {
    case alreadyFriend
    case userNotFound
    case requestAlreadySent
    case requestAlreadyReceived
    case notificationCreationFailed
}
