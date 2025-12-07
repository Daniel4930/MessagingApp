//
//  MessagingBarLayoutView.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/10/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseStorage

struct MessagingBarLayoutView: View {
    @Binding var channel: Channel
    @Binding var sendButtonDisabled: Bool
    @Binding var showFileAndImageSelector: Bool
    @FocusState.Binding var focusedField: Field?
    @ObservedObject var messageComposerViewModel: MessageComposerViewModel
    
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var messageViewModel: MessageViewModel
    @EnvironmentObject var alertViewModel: AlertMessageViewModel
    @EnvironmentObject var channelViewModel: ChannelViewModel
    
    @StateObject private var viewModel = MessagingBarLayoutViewViewModel()
    
    var body: some View {
        mainInputBar
            .overlay(alignment: .top) {
                overlayContent
            }
            .modifier(MessagingBarBackgroundModifier())
            .onChange(of: messageComposerViewModel.editedMessageId) { oldValue, newValue in
                viewModel.handleEditMessageChange(newValue: newValue, focusedField: &focusedField)
            }
    }
}

// MARK: - View Components
extension MessagingBarLayoutView {
    
    private var mainInputBar: some View {
        HStack(spacing: 10) {
            fileSelector
            textEditor
            sendButton
        }
        .padding(.horizontal, 13)
        .padding(.vertical, 10)
    }
    
    private var fileSelector: some View {
        SelectorButtonLayoutView(
            showFileAndImageSelector: $showFileAndImageSelector,
            focusedField: $focusedField
        )
    }
    
    private var textEditor: some View {
        CustomTextEditor(
            messageComposerViewModel: messageComposerViewModel,
            focusedField: $focusedField,
            memberIds: viewModel.memberIds(channel: $channel)
        )
    }
    
    @ViewBuilder
    private var sendButton: some View {
        if viewModel.shouldShowSendButton(messageComposerViewModel: messageComposerViewModel) {
            SendButtonView(action: sendButtonViewAction)
                .disabled(sendButtonDisabled)
        }
    }
    
    private var overlayContent: some View {
        VStack(spacing: 0) {
            mentionSection
            editMessageSection
        }
        .offset(y: viewModel.overlayOffset)
    }
    
    private var mentionSection: some View {
        MentionLayoutAnimationView(
            messageComposerViewModel: messageComposerViewModel,
            currentOffsetOverlay: $viewModel.currentOverlayOffset
        ) {
            MentionLayoutView(users: viewModel.matchedUsers(messageComposerViewModel: messageComposerViewModel), appendNameToText: mentionLayoutViewAction(name:))
                .frame(maxWidth: .infinity)
        }
    }
    
    @ViewBuilder
    private var editMessageSection: some View {
        if viewModel.isEditingMessage(messageComposerViewModel: messageComposerViewModel) {
            DividerView()
            editMessageHeader
        }
    }
    
    private var editMessageHeader: some View {
        HStack {
            Button(action: { viewModel.cancelEdit(messageComposerViewModel: messageComposerViewModel) }) {
                Image(systemName: "x.circle.fill")
            }
            Text("Editing Message")
        }
        .modifier(EditMessageHeaderModifier())
        .overlay {
            editMessageHeightReader
        }
    }
    
    private var editMessageHeightReader: some View {
        GeometryReader { proxy in
            Color.clear
                .onAppear {
                    viewModel.updateEditMessageHeight(proxy.size.height)
                }
                .onDisappear {
                    viewModel.resetEditMessageHeight()
                }
        }
    }
}

// MARK: View actions
extension MessagingBarLayoutView {
    func sendButtonViewAction() {
        Task {
            await viewModel.handleSendMessage(
                messageViewModel: messageViewModel,
                messageComposerViewModel: messageComposerViewModel,
                channelViewModel: channelViewModel,
                userViewModel: userViewModel,
                alertViewModel: alertViewModel,
                sendButtonDisabled: $sendButtonDisabled,
                channel: $channel
            )
        }
    }
    
    func mentionLayoutViewAction(name: String) {
        viewModel.handleMentionSelection(name, messageComposerViewModel: messageComposerViewModel)
    }
}

