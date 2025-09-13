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
    @State private var selectorHeight: CGFloat = .zero
    @State private var backgroundOpacity: CGFloat = .zero

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
                
                MessageScrollView(
                    channelInfo: channelInfo,
                    focusedField: $focusedField,
                    messageComposerViewModel: messageComposerViewModel
                )
                .onTapGesture {
                    showFileAndImageSelector = false
                    hideKeyboard()
                }
                
                DividerView(thickness: 1)
                
                if !messageComposerViewModel.selectionData.isEmpty {
                    PhotoAndFileHoriScrollView(
                        messageComposerViewModel: messageComposerViewModel,
                        showPhotoAndFile: $showPhotoAndFile
                    )
                }
                
                MessagingBarLayoutView(
                    channel: channelInfo,
                    sendButtonDisbaled: $sendButton,
                    showFileAndImageSelector: $showFileAndImageSelector,
                    focusedField: $focusedField,
                    messageComposerViewModel: messageComposerViewModel
                )
            }
            .padding(.bottom, bottomPaddingForSelector)
            .padding(.bottom, keyboardProvider.keyboardWillAppear || showFileAndImageSelector ? 0 : safeAreaInsetBottom)
            .overlay {
                if selectorHeight > SelectorView.threshold {
                    Color.black
                        .opacity(backgroundOpacity)
                        .ignoresSafeArea()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            
            SelectorView(
                minHeight: keyboardProvider.height,
                channel: channelInfo,
                messageComposerViewModel: messageComposerViewModel,
                sendButton: $sendButton,
                showFileAndImageSelector: $showFileAndImageSelector,
                selectorHeight: $selectorHeight
            )
            .frame(maxWidth: .infinity, alignment: .bottom)
            .offset(y: selectorViewYOffset)
        }
        .ignoresSafeArea(.keyboard)
        .ignoresSafeArea(edges: Edge.Set([.bottom]))
        .background(Color("PrimaryBackgroundColor"))
        .animation(.spring(duration: 0.3), value: selectorViewYOffset)
        .animation(.spring(duration: 0.3), value: bottomPaddingForSelector)
        .animation(.spring(duration: 0.3), value: backgroundOpacity)
        .onAppear {
            navViewModel.duringSwipeAction = {
                showFileAndImageSelector = false
                focusedField = nil
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
            } else {
                focusedField = .textField
            }
        }
        .onChange(of: selectorHeight) { oldValue, newValue in
            if newValue > SelectorView.threshold {
                backgroundOpacity = (newValue / SelectorView.selectorMaxHeight) * 0.3
            } else {
                backgroundOpacity = .zero
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
                    }
            }
        }
    }
}
