//
//  AddFriendView.swift
//  MessagingApp
//
//  Created by Daniel Le on 8/30/25.
//

import SwiftUI

struct AddFriendView: View {
    @EnvironmentObject var notificationViewModel: NotificationViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var friendViewModel: FriendViewModel
    @EnvironmentObject var alertMessageViewModel: AlertMessageViewModel
    
    @StateObject private var viewModel = AddFriendViewModel()
    @Environment(\.dismiss) var dismiss
        
    var body: some View {
        VStack {
            headerView
            
            FormTextFieldView(
                formType: .text,
                formTitle: "Who would you like to add as a friend?",
                textFieldTitle: "Enter a username",
                errorMessage: $viewModel.usernameErrorMessage,
                text: $viewModel.username
            )
            .padding(.vertical)
            
            sendFriendRequestButton
            
            Spacer()
        }
        .toolbar(.hidden, for: .navigationBar)
        .padding(.horizontal)
    }
    
    private var headerView: some View {
        ZStack {
            Button(action: { dismiss() }) {
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
    }
    
    private var sendFriendRequestButton: some View {
        Button(action: sendFriendRequestButtonAction) {
            Capsule()
                .fill(.blue)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .overlay {
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Send Friend Request")
                            .foregroundStyle(.white)
                    }
                }
        }
        .disabled(viewModel.isLoading)
    }
    
    func sendFriendRequestButtonAction() {
        Task {
            await viewModel.sendFriendRequest(
                userViewModel: userViewModel,
                friendViewModel: friendViewModel,
                notificationViewModel: notificationViewModel,
                alertMessageViewModel: alertMessageViewModel
            )
        }
    }
}
