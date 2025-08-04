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
    @State private var selectedPhotosAndFiles: [(image: UIImage?, file: Data?)] = []
    @State private var showPhotoAndFile = false
    @FocusState private var focusedField: Field?
    
    @EnvironmentObject var keyboardProvider: KeyboardProvider

    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 0) {
                
                DividerView()
                
                MessageScrollView(scrollToBottom: $scrollToBottom, focusedField: $focusedField)
                
                DividerView()
                
                if !selectedPhotosAndFiles.isEmpty {
                    PhotoAndFileHoriScrollView(selectedPhotosAndFiles: $selectedPhotosAndFiles, showPhotoAndFile: $showPhotoAndFile)
                }
                
                MessagingBarLayoutView(showFileAndImageSelector: $showFileAndImageSelector, scrollToBottom: $scrollToBottom, focusedField: $focusedField)
            }
            .padding(.bottom, (focusedField != nil || showFileAndImageSelector) ? keyboardProvider.height - proxy.safeAreaInsets.bottom : 0)
            .onChange(of: focusedField) { oldValue, newValue in
                if newValue == .textView {
                    showFileAndImageSelector = false
                }
            }
            .overlay(alignment: .bottom) {
                if showFileAndImageSelector {
                    withAnimation(.spring) {
                        SelectorView(minHeight: keyboardProvider.height, selectedPhotosAndFiles: $selectedPhotosAndFiles)
                            .offset(y: proxy.safeAreaInsets.bottom)
                            .onAppear {
                                hideKeyboard()
                            }
                    }
                }
            }
            .customSheetModifier(isPresented: $showPhotoAndFile) {
                PhotoAndFileInfoView()
                    .presentationDetents([.fraction(0.6), .fraction(0.945)])
            }
        }
        .ignoresSafeArea(.keyboard)
        .background(Color("PrimaryBackgroundColor"))
        .navigationBarBackButtonHidden(true)
        .onTapGesture {
            showFileAndImageSelector = false
            hideKeyboard()
        }
        .toolbar {
            NavigationTopBar()
        }
    }
}
