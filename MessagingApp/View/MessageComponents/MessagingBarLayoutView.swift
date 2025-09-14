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
    @Binding var sendButtonDisabled: Bool
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
                        try await messageViewModel.sendMessage(
                            sendButtonDisabled: $sendButtonDisabled,
                            channel: $channel,
                            messageComposerViewModel: messageComposerViewModel,
                            channelViewModel: channelViewModel,
                            userViewModel: userViewModel,
                            alertViewModel: alertViewModel
                        )
                    }
                }
                .disabled(sendButtonDisabled)
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
                
                if messageComposerViewModel.editedMessageId != nil {
                    DividerView()
                    HStack {
                        Button {
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
        .onChange(of: messageComposerViewModel.editedMessageId) { oldValue, newValue in
            if newValue != nil {
                focusedField = .textField
            }
        }
    }
}
