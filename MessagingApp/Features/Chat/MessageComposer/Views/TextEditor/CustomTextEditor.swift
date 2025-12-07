//
//  MessageInputBars.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/21/25.
//
import SwiftUI

struct CustomTextEditor: View {
    @ObservedObject var messageComposerViewModel: MessageComposerViewModel
    @FocusState.Binding var focusedField: Field?
    let memberIds: [String]
    
    @StateObject var viewModel = CustomTextEditorViewModel()

    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var friendViewModel: FriendViewModel

    let horizontalPaddingSpace: CGFloat = 10

    var body: some View {
        ZStack(alignment: .leading) {
            CustomUITextView(
                messageComposerViewModel: messageComposerViewModel,
                memberIds: memberIds,
                onMessageChange: uiTextViewAction
            )
            .modifier(CustomUITextViewModifier(messageComposerViewModel: messageComposerViewModel, focusedField: $focusedField))
            
            placeHolder()
        }
        .background(Color("SecondaryBackgroundColor"))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .onChange(of: memberIds) { _, _ in
            viewModel.updateCachedMembers(memberIds: memberIds, friendViewModel: friendViewModel)
        }
        .onChange(of: friendViewModel.friends) { _, _ in
            viewModel.updateCachedMembers(memberIds: memberIds, friendViewModel: friendViewModel)
        }
        .onAppear {
            viewModel.updateCachedMembers(memberIds: memberIds, friendViewModel: friendViewModel)
        }
    }
}

// MARK: View components
extension CustomTextEditor {
    func placeHolder() -> some View {
        guard let friend = friendViewModel.friends.first else {
            return AnyView(EmptyView())
        }
        let displayName = friend.displayName

        return AnyView(
            Text("Message @\(displayName.isEmpty ? friend.userName : displayName)")
                .padding(.horizontal)
                .foregroundStyle(.gray)
                .opacity(messageComposerViewModel.uiTextEditor.text.isEmpty ? 1 : 0)
        )
    }
}

// MARK: View actions
extension CustomTextEditor {
    func uiTextViewAction() {
        messageComposerViewModel.showSendButton = !messageComposerViewModel.uiTextEditor.text.isEmpty

        if let user = userViewModel.user {
            var users = Array(arrayLiteral: user)
            users.append(contentsOf: viewModel.cachedChannelMembers)
            let matched = viewModel.searchUser(users: users, messageComposerViewModel: messageComposerViewModel)
            messageComposerViewModel.mathchUsers = matched
            messageComposerViewModel.showMention = !matched.isEmpty
        }
    }
}
