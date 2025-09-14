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
                if message.senderId == userViewModel.user?.id {
                    Button("Edit Message", systemImage: "pencil") {
                        messageComposerViewModel.editedMessageId = message.id
                        messageComposerViewModel.uiTextEditor.text = message.text ?? ""
                        dismiss()
                    }
                }
                
                Button("Reply", systemImage: "arrow.turn.up.left") {
                    
                }
                
                Button("Forward", systemImage: "arrow.turn.up.right") {
                    
                }
                
                Button("Copy Text", systemImage: "square.and.arrow.down.on.square.fill") {
                    let pasteboard = UIPasteboard.general
                    pasteboard.string = message.text
                    alertViewModel.presentAlert(message: "Text copied", type: .success)
                    dismiss()
                }
            }
            
            if message.senderId == userViewModel.user?.id {
                Section {
                    Button {
                        guard let messageId = message.id else {
                            print("Failed to get message id")
                            return
                        }
                        guard let messageMap = messageViewModel.messages.first(where: { $0.messages.contains(message) }) else {
                            print("Can't find a message map that contains the current message")
                            return
                        }
                        let channelId = messageMap.channelId
                        
                        messageViewModel.deleteMessage(messageId: messageId, channelId: channelId)
                        dismiss()
                    } label: {
                        Label("Delete Message", systemImage: "trash.fill")
                            .foregroundStyle(.red)
                    }
                }
            }
        }
        .tint(.white)
    }
}
