//
//  DirectMessageView.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/9/25.
//

import SwiftUI

struct DirectMessageView: View {
    @StateObject private var viewModel: DirectMessageViewModel
    @StateObject private var messageComposerViewModel = MessageComposerViewModel()
    @FocusState private var focusedField: Field?
    @State private var showAttachmentSelector = false
    @State private var showAttachment = false
    @State private var sendButton = false
    @State private var selectorHeight: CGFloat = .zero
    @State private var backgroundOpacity: CGFloat = .zero
    
    @EnvironmentObject var keyboardProvider: KeyboardProvider
    @EnvironmentObject var messageViewModel: MessageViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    
    init(channelInfo: Channel) {
        _viewModel = StateObject(wrappedValue: DirectMessageViewModel(channelInfo: channelInfo))
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            mainContent
            selectorView
        }
        .ignoresSafeArea(.keyboard)
        .background(Color("PrimaryBackgroundColor"))
        .modifier(DirectMessageToolbarModifier())
        .modifier(DirectMessageAnimationModifier(
            selectorViewYOffset: selectorViewYOffset,
            bottomPaddingForSelector: bottomPaddingForSelector,
            backgroundOpacity: $backgroundOpacity
        ))
        .customSheetModifier(isPresented: $showAttachment) {
            UploadedFileInfoView(messageComposerViewModel: messageComposerViewModel)
                .presentationDetents([.fraction(0.6), .fraction(0.945)])
        }
        .sheet(item: $messageComposerViewModel.userProfile) { user in
            ProfileView(user: user)
                .presentationDetents([.fraction(0.95)])
        }
        .task(id: viewModel.channelInfo.id) {
            await viewModel.startListeningForMessages(
                messageViewModel: messageViewModel,
                userViewModel: userViewModel
            )
        }
        .onDisappear {
            viewModel.stopListeningForMessages(messageViewModel: messageViewModel, showAttachmentSelector: $showAttachmentSelector)
        }
        .onChange(of: focusedField) { oldValue, newValue in
            handleFocusChange(newValue: newValue)
        }
        .onChange(of: showAttachmentSelector) { oldValue, newValue in
            handleSelectorToggle(newValue: newValue)
        }
        .onChange(of: selectorHeight) { oldValue, newValue in
            updateBackgroundOpacity(newHeight: newValue)
        }
    }
}

// MARK: - Computed Properties
extension DirectMessageView {
    private var selectorViewYOffset: CGFloat {
        if showAttachmentSelector {
            return 0
        }
        return keyboardProvider.height
    }
    
    private var safeAreaInsetBottomOffset: CGFloat {
        if keyboardProvider.keyboardWillAppear || showAttachmentSelector {
            return 0
        }
        return DirectMessageView.safeAreaInsetBottom
    }
    
    private var bottomPaddingForSelector: CGFloat {
        if keyboardProvider.keyboardWillAppear || showAttachmentSelector {
            return keyboardProvider.height
        }
        return 0
    }
    
    private var minHeight: CGFloat {
        keyboardProvider.height - DirectMessageView.safeAreaInsetBottom
    }
    
    static private var safeAreaInsetBottom: CGFloat {
        UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first?.safeAreaInsets.bottom ?? 0
    }
}

// MARK: - UI Update Methods
extension DirectMessageView {
    func handleFocusChange(newValue: Field?) {
        if newValue == .textField {
            showAttachmentSelector = false
        }
    }
    
    func handleSelectorToggle(newValue: Bool) {
        if newValue {
            hideKeyboard()
        }
    }
    
    func updateBackgroundOpacity(newHeight: CGFloat) {
        if newHeight > SelectorView.threshold {
            backgroundOpacity = (newHeight / SelectorView.selectorMaxHeight) * 0.3
        } else {
            backgroundOpacity = .zero
        }
    }
    
    func handleTapGesture() {
        showAttachmentSelector = false
        hideKeyboard()
    }
}

// MARK: - View Components
extension DirectMessageView {
    private var mainContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            navigationTopBar
            DividerView()
            messageScrollView
            DividerView(thickness: 1)
            photoAndFileScrollView
            messagingBar
        }
        .modifier(DirectMessagePaddingModifier(
            bottomPaddingForSelector: bottomPaddingForSelector,
            safeAreaInsetBottom: DirectMessageView.safeAreaInsetBottom,
            keyboardWillAppear: keyboardProvider.keyboardWillAppear,
            showFileAndImageSelector: showAttachmentSelector
        ))
        .modifier(DirectMessageOverlayModifier(
            selectorHeight: selectorHeight,
            backgroundOpacity: backgroundOpacity
        ))
    }
    
    private var navigationTopBar: some View {
        NavigationTopBar(
            channelInfo: viewModel.channelInfo,
            showFileAndImageSelector: $showAttachmentSelector
        )
        .padding([.leading, .vertical])
    }
    
    private var messageScrollView: some View {
        MessageScrollView(
            channelInfo: viewModel.channelInfo,
            focusedField: $focusedField,
            messageComposerViewModel: messageComposerViewModel
        )
        .onTapGesture {
            handleTapGesture()
        }
    }
    
    @ViewBuilder
    private var photoAndFileScrollView: some View {
        if !messageComposerViewModel.selectionData.isEmpty {
            AttachmentHorizontalScrollView(
                messageComposerViewModel: messageComposerViewModel,
                showAttachment: $showAttachment
            )
        }
    }
    
    private var messagingBar: some View {
        MessagingBarLayoutView(
            channel: $viewModel.channelInfo,
            sendButtonDisabled: $sendButton,
            showFileAndImageSelector: $showAttachmentSelector,
            focusedField: $focusedField,
            messageComposerViewModel: messageComposerViewModel
        )
    }
    
    private var selectorView: some View {
        SelectorView(
            minHeight: minHeight,
            channel: $viewModel.channelInfo,
            messageComposerViewModel: messageComposerViewModel,
            sendButton: $sendButton,
            showAttachmentSelector: $showAttachmentSelector,
            selectorHeight: $selectorHeight
        )
        .frame(maxWidth: .infinity, alignment: .bottom)
        .offset(
            y: selectorViewYOffset + safeAreaInsetBottomOffset
        )
    }
}
