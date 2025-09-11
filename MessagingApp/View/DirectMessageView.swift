//
//  DirectMessageView.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/9/25.
//

import SwiftUI

enum Field {
    case textField
}

struct DirectMessageView: View {
    let channelInfo: Channel
    @State private var showFileAndImageSelector = false
    @State private var showPhotoAndFile = false
    @State private var sendButton = false
    @State private var safeAreaInsetBottom: CGFloat = .zero
    @State private var safeAreaInsetTop: CGFloat = .zero
    @StateObject private var messageComposerViewModel = MessageComposerViewModel()
    @FocusState private var focusedField: Field?
    @EnvironmentObject var keyboardProvider: KeyboardProvider
    @EnvironmentObject var messageViewModel: MessageViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var navViewModel: CustomNavigationViewModel
    
    var selectorViewYOffset: CGFloat {
        showFileAndImageSelector ? 0 : keyboardProvider.height
    }
    
    var bottomPaddingForSelector: CGFloat {
        (keyboardProvider.keyboardWillAppear || showFileAndImageSelector) ? keyboardProvider.height : 0
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 0) {
                NavigationTopBar(channelInfo: channelInfo)
                    .padding([.leading, .vertical])
                
                DividerView()
                
                MessageScrollView(channelInfo: channelInfo, focusedField: $focusedField, messageComposerViewModel: messageComposerViewModel)
                    .onTapGesture {
                        showFileAndImageSelector = false
                        hideKeyboard()
                    }
                
                DividerView()
                
                if !messageComposerViewModel.selectionData.isEmpty {
                    PhotoAndFileHoriScrollView(messageComposerViewModel: messageComposerViewModel, showPhotoAndFile: $showPhotoAndFile)
                }
                
                MessagingBarLayoutView(channel: channelInfo, sendButtonDisbaled: $sendButton, showFileAndImageSelector: $showFileAndImageSelector, focusedField: $focusedField, messageComposerViewModel: messageComposerViewModel)
                    .offset(y: keyboardProvider.keyboardWillAppear || showFileAndImageSelector ? 0 : -safeAreaInsetBottom)
            }
            .padding(.top, safeAreaInsetTop)
            .padding(.bottom, bottomPaddingForSelector)
            
            SelectorView(
                minHeight: keyboardProvider.height - safeAreaInsetBottom,
                channel: channelInfo,
                messageComposerViewModel: messageComposerViewModel,
                sendButton: $sendButton
            )
            .frame(maxWidth: .infinity, alignment: .bottom)
            .padding(.bottom, safeAreaInsetBottom)
            .offset(y: selectorViewYOffset)
        }
        .ignoresSafeArea()
        .background(Color("PrimaryBackgroundColor"))
        .animation(.spring(duration: 0.3, bounce: 0), value: selectorViewYOffset)
        .animation(.spring(duration: 0.3, bounce: 0), value: bottomPaddingForSelector)
        .onAppear {
            navViewModel.duringSwipeAction = {
                showFileAndImageSelector = false
            }
        }
        .onChange(of: focusedField) { oldValue, newValue in
            if newValue == .textField {
                showFileAndImageSelector = false
            }
        }
        .onChange(of: showFileAndImageSelector) { oldValue, newValue in
            if newValue {
                hideKeyboard()
            }
        }
        .customSheetModifier(isPresented: $showPhotoAndFile) {
            UploadedFileInfoView(messageComposerViewModel: messageComposerViewModel)
                .presentationDetents([.fraction(0.6), .fraction(0.945)])
        }
        .sheet(item: $messageComposerViewModel.userProfile) { user in
            ProfileView(user: user)
                .presentationDetents([.fraction(0.95)])
        }
        .task(id: channelInfo.id) {
            guard let id = channelInfo.id else {
                print("Channel id is nil")
                return
            }
            messageViewModel.listenForMessages(channelId: id, userViewModel: userViewModel)
        }
        .onDisappear {
            messageViewModel.stopListening(channelId: channelInfo.id)
            showFileAndImageSelector = false
            keyboardProvider.keyboardWillAppear = false
            navViewModel.duringSwipeAction = nil
        }
        .overlay {
            GeometryReader { proxy in
                Color.clear
                    .onAppear {
                        safeAreaInsetBottom = proxy.safeAreaInsets.bottom
                        safeAreaInsetTop = proxy.safeAreaInsets.top
                    }
            }
        }
    }
}
