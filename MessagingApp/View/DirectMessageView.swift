//
//  DirectMessageView.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/9/25.
//

import SwiftUI

enum Field {
    case textView
}

struct DirectMessageView: View {
    let channelInfo: Channel
    @State private var scrollToBottom: Bool = false
    @State private var showFileAndImageSelector = false
    @State private var showPhotoAndFile = false
    @State private var sendButton = false
    @StateObject private var messageComposerViewModel = MessageComposerViewModel()
    @FocusState private var focusedField: Field?
    @EnvironmentObject var keyboardProvider: KeyboardProvider
    @EnvironmentObject var messageViewModel: MessageViewModel

    var body: some View {
        GeometryReader { proxy in
            VStack(alignment: .leading, spacing: 0) {
                NavigationTopBar(channelInfo: channelInfo)
                    .padding([.leading, .vertical])
                
                DividerView()
                
                MessageScrollView(channelInfo: channelInfo, scrollToBottom: $scrollToBottom, focusedField: $focusedField)
                    .onTapGesture {
                        showFileAndImageSelector = false
                        hideKeyboard()
                    }
                
                DividerView()
                
                if !messageComposerViewModel.selectionData.isEmpty {
                    PhotoAndFileHoriScrollView(messageComposerViewModel: messageComposerViewModel, showPhotoAndFile: $showPhotoAndFile)
                }
                
                MessagingBarLayoutView(channel: channelInfo, sendButton: $sendButton, showFileAndImageSelector: $showFileAndImageSelector, scrollToBottom: $scrollToBottom, focusedField: $focusedField, messageComposerViewModel: messageComposerViewModel)
            }
            .padding(.bottom, (focusedField != nil || showFileAndImageSelector) ? keyboardProvider.height - proxy.safeAreaInsets.bottom : 0)
            .onChange(of: focusedField) { oldValue, newValue in
                if newValue == .textView {
                    showFileAndImageSelector = false
                }
            }
            .overlay(alignment: .bottom) {
                if showFileAndImageSelector {
                    SelectorView(minHeight: keyboardProvider.height, channel: channelInfo, messageComposerViewModel: messageComposerViewModel, scrollToBottom: $scrollToBottom, sendButton: $sendButton)
                        .offset(y: proxy.safeAreaInsets.bottom)
                        .onAppear {
                            hideKeyboard()
                        }
                }
            }
            .customSheetModifier(isPresented: $showPhotoAndFile) {
                UploadedFileInfoView(messageComposerViewModel: messageComposerViewModel)
                    .presentationDetents([.fraction(0.6), .fraction(0.945)])
            }
            .task(id: channelInfo.id) {
                guard let id = channelInfo.id else {
                    print("Channel id is nil")
                    return
                }
                messageViewModel.listenForMessages(channelId: id)
            }
        }
        .ignoresSafeArea(.keyboard)
        .background(Color("PrimaryBackgroundColor"))
    }
}
