//
//  ProfileOptionsView.swift
//  MessagingApp
//
//  Created by Daniel Le on 10/29/25.
//

import SwiftUI

struct ProfileOptionsView: View {
    let user: User
    @Binding var showOptions: Bool
    
    @EnvironmentObject var alertViewModel: AlertMessageViewModel
    @EnvironmentObject var friendViewModel: FriendViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            ProfileOptionButton(
                title: "Copy Username",
                role: .cancel,
                action: copyButtonAction
            )
            
            removeFriendButton()
        }
        .frame(minWidth: 180)
        .presentationCompactAdaptation(.popover)
    }
}

// MARK: View components
extension ProfileOptionsView {
    func removeFriendButton() -> some View {
        guard let currentUser = userViewModel.user, user.id != currentUser.id, let friendId = user.id else {
            return AnyView(EmptyView())
        }
        
        return AnyView(
            ProfileOptionButton(
                title: "Remove Friend",
                role: .destructive,
                action: { removeFriendButtonAction(
                    currentUser: currentUser,
                    friendId: friendId
                )}
            )
        )
    }
}

// MARK: View actions
extension ProfileOptionsView {
    func copyButtonAction() {
        let pasteboard = UIPasteboard.general
        pasteboard.string = user.userName
        alertViewModel.presentAlert(message: "Username copied", type: .success)
        showOptions = false
    }
    
    func removeFriendButtonAction(currentUser: User, friendId: String) {
        Task {
            await friendViewModel.removeFriend(
                for: currentUser,
                friendId: friendId
            )
        }
    }
}
