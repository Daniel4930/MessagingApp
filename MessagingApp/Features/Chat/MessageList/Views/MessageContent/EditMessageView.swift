//
//  EditMessageView.swift
//  MessagingApp
//
//  Created by Daniel Le on 9/6/25.
//

import SwiftUI

struct EditMessageView: View {
    let message: Message
    @ObservedObject var messageComposerViewModel: MessageComposerViewModel
    @EnvironmentObject var messageViewModel: MessageViewModel
    @EnvironmentObject var alertViewModel: AlertMessageViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        List {
            Section {
                editMessageButton
                copyTextButton
            }
            
            deleteMessageSection
        }
        .tint(.white)
    }
}

// MARK: View components
extension EditMessageView {
    @ViewBuilder var editMessageButton: some View {
        if message.senderId == userViewModel.user?.id {
            Button("Edit Message", systemImage: "pencil") {
                messageComposerViewModel.editedMessageId = message.id
                messageComposerViewModel.uiTextEditor.text = message.text ?? ""
                dismiss()
            }
        }
    }
    
    @ViewBuilder var deleteMessageSection: some View {
        if message.senderId == userViewModel.user?.id {
            Section {
                deleteMessageButton
            }
        }
    }
    
    var copyTextButton: some View {
        Button("Copy Text", systemImage: "square.and.arrow.down.on.square.fill") {
            let pasteboard = UIPasteboard.general
            pasteboard.string = message.text
            alertViewModel.presentAlert(message: "Text copied", type: .success)
            dismiss()
        }
    }
    
    var deleteMessageButton: some View {
        Button(action: deleteMessage) {
            Label("Delete Message", systemImage: "trash.fill")
                .foregroundStyle(.red)
        }
    }
}

// MARK: View actions
extension EditMessageView {
    func deleteMessage() {
        guard let messageId = message.id else {
            alertViewModel.presentAlert(message: "Failed to delete message", type: .error)
            print("Failed to get message id")
            return
        }
        guard let messageMap = messageViewModel.messages.first(where: { $0.messages.contains(message) }) else {
            alertViewModel.presentAlert(message: "Failed to delete message", type: .error)
            print("Can't find a message map that contains the current message")
            return
        }
        let channelId = messageMap.channelId
        
        messageViewModel.deleteMessage(messageId: messageId, channelId: channelId)
        dismiss()
    }
}
