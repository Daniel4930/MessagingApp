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
    @State private var scrollToBottom: Bool = false
    @State private var showFileAndImageSelector = false
    @State private var showPhotoAndFile = false
    @StateObject private var messageComposerViewModel = MessageComposerViewModel()
    @FocusState private var focusedField: Field?
    
    @EnvironmentObject var keyboardProvider: KeyboardProvider

    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 0) {
                
                DividerView()
                
                MessageScrollView(scrollToBottom: $scrollToBottom, focusedField: $focusedField)
                    .onTapGesture {
                        showFileAndImageSelector = false
                        hideKeyboard()
                    }
                
                DividerView()
                
                if !messageComposerViewModel.selectionData.isEmpty {
                    PhotoAndFileHoriScrollView(uploadDataViewModel: messageComposerViewModel, showPhotoAndFile: $showPhotoAndFile)
                }
                
                MessagingBarLayoutView(showFileAndImageSelector: $showFileAndImageSelector, scrollToBottom: $scrollToBottom, focusedField: $focusedField, messageComposerViewModel: messageComposerViewModel)
            }
            .padding(.bottom, (focusedField != nil || showFileAndImageSelector) ? keyboardProvider.height - proxy.safeAreaInsets.bottom : 0)
            .onChange(of: focusedField) { oldValue, newValue in
                if newValue == .textView {
                    showFileAndImageSelector = false
                }
            }
            .overlay(alignment: .bottom) {
                if showFileAndImageSelector {
                    SelectorView(minHeight: keyboardProvider.height, messageComposerViewModel: messageComposerViewModel, scrollToBottom: $scrollToBottom)
                        .offset(y: proxy.safeAreaInsets.bottom)
                        .onAppear {
                            hideKeyboard()
                        }
                }
            }
            .customSheetModifier(isPresented: $showPhotoAndFile) {
                UploadedDataInfoView(uploadDataViewModel: messageComposerViewModel)
                    .presentationDetents([.fraction(0.6), .fraction(0.945)])
            }
        }
        .ignoresSafeArea(.keyboard)
        .background(Color("PrimaryBackgroundColor"))
        .navigationBarBackButtonHidden(true)
        .toolbar {
            NavigationTopBar()
        }
    }
}
