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
    @State private var channelInfo: Channel
    let popView: () -> Void
    
    @State private var showFileAndImageSelector = false
    @State private var showPhotoAndFile = false
    @State private var sendButton = false
    @State private var safeAreaInsetBottom: CGFloat = UIApplication.shared.connectedScenes
        .compactMap { ($0 as? UIWindowScene)?.keyWindow }
        .first?.safeAreaInsets.bottom ?? 0
    @State private var selectorHeight: CGFloat = .zero
    @State private var backgroundOpacity: CGFloat = .zero

    @StateObject private var messageComposerViewModel = MessageComposerViewModel()
    @FocusState private var focusedField: Field?
    @EnvironmentObject var keyboardProvider: KeyboardProvider
    @EnvironmentObject var messageViewModel: MessageViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    
    init(channelInfo: Channel, popView: @escaping () -> Void) {
        self.channelInfo = channelInfo
        self.popView = popView
    }
    
    var selectorViewYOffset: CGFloat {
        showFileAndImageSelector ? 0 : keyboardProvider.height
    }
    
    var bottomPaddingForSelector: CGFloat {
        (keyboardProvider.keyboardWillAppear || showFileAndImageSelector) ? keyboardProvider.height : 0
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 0) {
                NavigationTopBar(
                    channelInfo: channelInfo,
                    showFileAndImageSelector: $showFileAndImageSelector
                )
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
                    channel: $channelInfo,
                    sendButtonDisabled: $sendButton,
                    showFileAndImageSelector: $showFileAndImageSelector,
                    focusedField: $focusedField,
                    messageComposerViewModel: messageComposerViewModel
                )
            }
            .padding(.bottom, bottomPaddingForSelector -
                     (keyboardProvider.keyboardWillAppear || showFileAndImageSelector ? safeAreaInsetBottom : 0)
            )
            .overlay {
                if selectorHeight > SelectorView.threshold {
                    Color.black
                        .opacity(backgroundOpacity)
                        .ignoresSafeArea()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            
            SelectorView(
                minHeight: keyboardProvider.height - safeAreaInsetBottom,
                channel: $channelInfo,
                messageComposerViewModel: messageComposerViewModel,
                sendButton: $sendButton,
                showFileAndImageSelector: $showFileAndImageSelector,
                selectorHeight: $selectorHeight
            )
            .frame(maxWidth: .infinity, alignment: .bottom)
            .offset(
                y: selectorViewYOffset + (keyboardProvider.keyboardWillAppear || showFileAndImageSelector ? 0 : safeAreaInsetBottom)
            )
        }
        .ignoresSafeArea(.keyboard)
        .background(Color("PrimaryBackgroundColor"))
        .toolbar(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    focusedField = nil
                }
            }
        }
        .animation(.spring(duration: 0.3), value: selectorViewYOffset)
        .animation(.spring(duration: 0.3), value: bottomPaddingForSelector)
        .animation(.spring(duration: 0.3), value: backgroundOpacity)
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
            ProfileView(user: user, popView: popView)
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
        }
    }
}
