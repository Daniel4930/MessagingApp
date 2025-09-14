//
//  MessagingBarLayoutView.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/10/25.fdsfsd
//

import SwiftUI
import FirebaseFirestore
import FirebaseStorage

@MainActor
struct MessagingBarLayoutView: View {
    @Binding var channel: Channel
    @Binding var sendButtonDisbaled: Bool
    @Binding var showFileAndImageSelector: Bool
    @FocusState.Binding var focusedField: Field?
    @ObservedObject var messageComposerViewModel: MessageComposerViewModel
    
    @State private var currentOverlayOffset: CGFloat = .zero
    @State private var editMessageHeightView: CGFloat = .zero
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var messageViewModel: MessageViewModel
    @EnvironmentObject var alertViewModel: AlertMessageViewModel
    @EnvironmentObject var channelViewModel: ChannelViewModel
    
    var body: some View {
        HStack(spacing: 10) {
            SelectorButtonLayoutView(showFileAndImageSelector: $showFileAndImageSelector, focusedField: $focusedField)
            
            CustomTextEditor(
                messageComposerViewModel: messageComposerViewModel,
                focusedField: $focusedField,
                memberIds: channel.memberIds
            )
            
            if messageComposerViewModel.showSendButton || !messageComposerViewModel.selectionData.isEmpty {
                SendButtonView {
                    Task {
                        sendButtonDisbaled = true
                        do {
                            if messageComposerViewModel.editMessage,
                                let channelId = channel.id,
                                let messageId = messageComposerViewModel.editedMessageId,
                                let finalizedText = messageComposerViewModel.finalizeText() {
                                try await messageViewModel.updateMessageText(channelId: channelId, messageId: messageId, text: finalizedText)
                                
                                if messageId == channel.lastMessage?.messageId {
                                    let messageMap = messageViewModel.messages.first(where: { $0.channelId == channelId })
                                    guard let currentMessage = messageMap?.messages.first(where: { $0.id == messageId }) else {
                                        print("Failed to get last message in channel")
                                        return
                                    }
                                    
                                    var newCurrentMessage = currentMessage
                                    newCurrentMessage.text = finalizedText
                                    guard let lastMessage = LastMessage(from: newCurrentMessage) else {
                                        print("Failed to create last message data")
                                        return
                                    }
                                    
                                    try await channelViewModel.updateLastMessage(channelId: channelId, lastMessage: lastMessage)
                                }
                            } else {
                                try await messageViewModel.uploadFilesAndSendMessage(
                                    senderId: userViewModel.user?.id,
                                    selectionData: messageComposerViewModel.selectionData,
                                    channel: $channel,
                                    finalizedText: messageComposerViewModel.finalizeText(),
                                    userViewModel: userViewModel,
                                    channelViewModel: channelViewModel
                                )
                                messageComposerViewModel.scrollToBottom = true
                            }
                            
                            messageComposerViewModel.resetInputs()
                            
                        } catch {
                            print("Error sending message: \(error.localizedDescription)")
                            alertViewModel.presentAlert(message: "Failed to send message", type: .error)
                        }
                        sendButtonDisbaled = false
                    }
                }
                .disabled(sendButtonDisbaled)
            }
        }
        .padding(.horizontal, 13)
        .padding(.vertical, 10)
        .overlay(alignment: .top) {
            VStack(spacing: 0) {
                MentionLayoutViewAnimation(messageComposerViewModel: messageComposerViewModel, currentOffsetOverlay: $currentOverlayOffset) {
                    MentionLayoutView(users: messageComposerViewModel.mathchUsers) { name in
                        let uiTextView = messageComposerViewModel.uiTextEditor
                        
                        uiTextView.text.removeLast(uiTextView.text.distance(from: uiTextView.text.lastIndex(of: "@")!, to: uiTextView.text.endIndex))
                        uiTextView.text.append("@" + name + " ")
                        messageComposerViewModel.uiTextEditor = uiTextView
                        messageComposerViewModel.showMention = false
                        
                        if let delegate = uiTextView.delegate as? CustomUITextView.Coordinator {
                            delegate.textViewDidChange(uiTextView)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                
                if messageComposerViewModel.editMessage {
                    DividerView()
                    HStack {
                        Button {
                            messageComposerViewModel.editMessage = false
                            messageComposerViewModel.uiTextEditor.text = ""
                            messageComposerViewModel.editedMessageId = nil
                        } label: {
                            Image(systemName: "x.circle.fill")
                        }
                        Text("Editing Message")
                    }
                    .tint(.button)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading)
                    .padding(.vertical, 10)
                    .background(.secondaryBackground)
                    .overlay {
                        GeometryReader { proxy in
                            Color.clear
                                .onAppear {
                                    editMessageHeightView = proxy.size.height
                                }
                                .onDisappear {
                                    editMessageHeightView = 0
                                }
                        }
                    }
                }
            }
            .offset(y: -currentOverlayOffset - editMessageHeightView)
        }
        .background(Color("PrimaryBackgroundColor"))
        .onChange(of: messageComposerViewModel.editMessage) { oldValue, newValue in
            if newValue {
                focusedField = .textField
            }
        }
    }
}
