//
//  MessagingBarLayoutView.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/10/25.fdsfsd
//

import SwiftUI

struct MessagingBarLayoutView: View {
    @Binding var showFileAndImageSelector: Bool
    @Binding var scrollToBottom: Bool
    @FocusState.Binding var focusedField: Field?
    @ObservedObject var messageComposerViewModel: MessageComposerViewModel
    
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var messageViewModel: MessageViewModel
    
    var body: some View {
        HStack(spacing: 10) {
            SelectorButtonLayoutView(showFileAndImageSelector: $showFileAndImageSelector, focusedField: $focusedField)
            
            CustomTextEditor(
                messageComposerViewModel: messageComposerViewModel,
                focusedField: $focusedField,
                scrollToBottom: $scrollToBottom
            )
            
            if messageComposerViewModel.showSendButton || !messageComposerViewModel.selectionData.isEmpty {
                SendButtonView {
                    messageViewModel.addMessage (
                        userId: userViewModel.user!.id!,
                        text: messageComposerViewModel.finalizeText(),
                        images: messageComposerViewModel.selectionData == [] ? [] : messageComposerViewModel.convertUImageToImageData(),
                        files: nil,
                        location: .dm,
                        reaction: nil,
                        replyMessageId: nil,
                        forwardMessageId: nil,
                        edited: false
                    )
                    messageComposerViewModel.uiTextView.text = ""
                    messageComposerViewModel.selectionData = []
                    messageComposerViewModel.showSendButton = false
                    messageComposerViewModel.customTextEditorHeight = MessageComposerViewModel.customTextEditorMinHeight
                    scrollToBottom = true
                }
            }
        }
        .padding(.horizontal, 13)
        .padding(.vertical, 10)
        .overlay(alignment: .top) {
            MentionLayoutViewAnimation(messageComposerViewModel: messageComposerViewModel) {
                MentionLayoutView(users: messageComposerViewModel.mathchUsers) { name in
                    let uiTextView = messageComposerViewModel.uiTextView
                    
                    uiTextView.text.removeLast(uiTextView.text.distance(from: uiTextView.text.lastIndex(of: "@")!, to: uiTextView.text.endIndex))
                    uiTextView.text.append("@" + name + " ")
                    messageComposerViewModel.uiTextView = uiTextView
                    messageComposerViewModel.showMention = false
                    
                    if let delegate = uiTextView.delegate as? CustomUITextView.Coordinator {
                        delegate.textViewDidChange(uiTextView)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .background(Color("PrimaryBackgroundColor"))
    }
}
