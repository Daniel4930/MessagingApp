//
//  AddFriendView.swift
//  MessagingApp
//
//  Created by Daniel Le on 8/30/25.
//

import SwiftUI

struct AddFriendView: View {
    @Binding var showAddFriend: Bool
    @State private var username: String = ""
    @State private var usernameErrorMessage: String = ""
    @EnvironmentObject var navViewModel: CustomNavigationViewModel
    @EnvironmentObject var notificationViewModel: NotificationViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var friendViewModel: FriendViewModel
    @EnvironmentObject var alertMessageViewModel: AlertMessageViewModel
        
    var body: some View {
        VStack {
            ZStack {
                Button {
                    showAddFriend = false
                } label: {
                    Image(systemName: "arrow.left")
                        .resizable()
                        .frame(width: 20, height: 20)
                }
                .tint(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("Add Friends")
                    .bold()
            }
            .padding(.top)
            
            FormTextFieldView(
                formType: .text,
                formTitle: "Who would you like to add as a friend?",
                textFieldTitle: "Enter a username",
                errorMessage: $usernameErrorMessage,
                text: $username
            )
            .padding(.vertical)
            
            Button {
                usernameErrorMessage = ""
                
                if username.isEmpty {
                    usernameErrorMessage = "Username is empty"
                } else if username == userViewModel.user?.userName {
                    usernameErrorMessage = "Can't friend yourself"
                } else if username.contains(" ") {
                    usernameErrorMessage = "Username can't contain spaces"
                }
                
                if usernameErrorMessage.isEmpty {
                    Task {
                        //Check if the username already in the friend list
                        guard !friendViewModel.friends.contains(where: { $0.userName == username }) else {
                            alertMessageViewModel.presentAlert(message: "\(username) is already in the friend list", type: .error)
                            return
                        }
                        
                        guard let currentUser = userViewModel.user else {
                            alertMessageViewModel.presentAlert(message: "Failed to send friend request", type: .error)
                            return
                        }
                        
                        //Fetch recipientId from username
                        guard let user = await FirebaseCloudStoreService.shared.fetchUserByUsername(username: username) else {
                            alertMessageViewModel.presentAlert(message: "User does not exist", type: .error)
                            return
                        }
                        
                        //Check if a friend request has already been sent
                        let friendRequestToUser = try await FirebaseCloudStoreService.shared.fetchFriendRequest(recipientId: user.id!, senderName: currentUser.userName)
                        if let friendRequestToUser = friendRequestToUser, !friendRequestToUser.isEmpty {
                            alertMessageViewModel.presentAlert(message: "A friend request has already been sent to \(username)", type: .error)
                            return
                        }
                        
                        //Check if the user has already sent a friend request to current user
                        let friendRequestToCurrentUser = try await FirebaseCloudStoreService.shared.fetchFriendRequest(recipientId: currentUser.id!, senderName: username)
                        if let friendRequestToCurrentUser = friendRequestToCurrentUser, !friendRequestToCurrentUser.isEmpty {
                            alertMessageViewModel.presentAlert(message: "\(username) has already sent a friend request to you. Please accept it in the notifications tab", type: .info)
                            return
                        }
                        
                        let notification = notificationViewModel.setupNotificationContent(
                            recipientId: user.id,
                            senderName: currentUser.userName,
                            type: NotificationType.friendRequest,
                            channelId: nil,
                            isRead: false
                        )
                        
                        guard let notification = notification else {
                            alertMessageViewModel.presentAlert(message: "Failed to send friend request", type: .error)
                            return
                        }
                        do {
                            try await notificationViewModel.addNotification(notification: notification)
                            
                            alertMessageViewModel.presentAlert(message: "Friend request sent", type: .success)
                            
                        } catch {
                            print(error)
                        }
                    }
                }
            } label: {
                Capsule()
                    .fill(.blue)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .overlay {
                        Text("Send Friend Request")
                            .foregroundStyle(.white)
                    }
            }
            Spacer()
        }
        .padding(.horizontal)
    }
}
