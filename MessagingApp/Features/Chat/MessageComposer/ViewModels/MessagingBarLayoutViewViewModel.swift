//
//  MessagingBarLayoutViewViewModel.swift
//  MessagingApp
//
//  Created by Daniel Le on 10/27/25.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseStorage

@MainActor
final class MessagingBarLayoutViewViewModel: ObservableObject {
    @Published var currentOverlayOffset: CGFloat = .zero
    @Published var editMessageHeightView: CGFloat = .zero
    
    var overlayOffset: CGFloat {
        return -currentOverlayOffset - editMessageHeightView
    }
    
    // MARK: - Actions
    
    func memberIds(channel: Binding<Channel>) -> [String] {
        return channel.wrappedValue.memberIds
    }
    
    func shouldShowSendButton(messageComposerViewModel: MessageComposerViewModel) -> Bool {
        return messageComposerViewModel.showSendButton || !messageComposerViewModel.selectionData.isEmpty
    }
    
    func isEditingMessage(messageComposerViewModel: MessageComposerViewModel) -> Bool {
        return messageComposerViewModel.editedMessageId != nil
    }
    
    func matchedUsers(messageComposerViewModel: MessageComposerViewModel) -> [User] {
        return messageComposerViewModel.mathchUsers
    }
    
    func handleSendMessage(
        messageViewModel: MessageViewModel,
        messageComposerViewModel: MessageComposerViewModel,
        channelViewModel: ChannelViewModel,
        userViewModel: UserViewModel,
        alertViewModel: AlertMessageViewModel,
        sendButtonDisabled: Binding<Bool>,
        channel: Binding<Channel>
    ) async {
        do {
            try await messageViewModel.sendMessage(
                sendButtonDisabled: sendButtonDisabled,
                channel: channel,
                messageComposerViewModel: messageComposerViewModel,
                channelViewModel: channelViewModel,
                userViewModel: userViewModel,
                alertViewModel: alertViewModel
            )
        } catch {
            print("Failed to send message: \(error)")
        }
    }
    
    func handleMentionSelection(
        _ name: String,
        messageComposerViewModel: MessageComposerViewModel
    ) {
        let uiTextView = messageComposerViewModel.uiTextEditor
        
        // Find the last @ symbol and remove everything after it
        if let lastAtIndex = uiTextView.text.lastIndex(of: "@") {
            let distanceToEnd = uiTextView.text.distance(from: lastAtIndex, to: uiTextView.text.endIndex)
            uiTextView.text.removeLast(distanceToEnd)
        }
        
        // Append the selected name with @ prefix and space
        uiTextView.text.append("@\(name) ")
        messageComposerViewModel.uiTextEditor = uiTextView
        messageComposerViewModel.showMention = false
        
        // Notify the delegate of the change
        if let delegate = uiTextView.delegate as? CustomUITextView.Coordinator {
            delegate.textViewDidChange(uiTextView)
        }
    }
    
    func cancelEdit(messageComposerViewModel: MessageComposerViewModel) {
        messageComposerViewModel.uiTextEditor.text = ""
        messageComposerViewModel.editedMessageId = nil
    }
    
    func handleEditMessageChange(newValue: String?, focusedField: inout Field?) {
        if newValue != nil {
            focusedField = .textField
        }
    }
    
    func updateEditMessageHeight(_ height: CGFloat) {
        editMessageHeightView = height
    }
    
    func resetEditMessageHeight() {
        editMessageHeightView = 0
    }
}
