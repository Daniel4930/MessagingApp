//
//  SelectorView.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/15/25.
//

import SwiftUI
import PhotosUI
import Photos

enum PhotoLibraryAccessStatus {
    case fullAccess
    case limitedAccess
    case restricted
    case denied
    case undetermined
}

struct SelectorView: View {
    let minHeight: CGFloat
    let channel: Channel
    @ObservedObject var messageComposerViewModel: MessageComposerViewModel
    @Binding var sendButton: Bool
    
    @State private var selectorHeight: CGFloat = .zero
    @State private var openCamera = false
    @State private var accessStatus: PhotoLibraryAccessStatus?
    @State private var assets: [PHAsset] = []
    @State private var lastCreationDate: Date?
    @State private var enableHighPriorityGesture = false
    @State private var fetchMoreAssets = false
    
    @EnvironmentObject var messageViewModel: MessageViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    
    let selectorMaxHeight: CGFloat = UIScreen.main.bounds.height * 0.898
    let threshold: CGFloat = UIScreen.main.bounds.height * 0.6
    let fetchLimit = 20
    
    var gesture: some Gesture {
        DragGesture()
            .onChanged { dragValue in
                onDragChanged(dragValue)
            }
            .onEnded { dragValue in
                onDragEnded(dragValue)
            }
    }
    
    var body: some View {
        VStack {            
            LineIndicator()
            
            if selectorHeight >= threshold {
                SelectorNavTopBar(
                    height: $selectorHeight,
                    minHeight: minHeight,
                    accessStatus: accessStatus ?? .undetermined,
                    messageComposerViewModel: messageComposerViewModel
                )
                    .highPriorityGesture(gesture)
            } else {
                FilesButtonsView(messageComposerViewModel: messageComposerViewModel)
                    .highPriorityGesture(gesture)
            }
            
            ScrollView {
                LazyVStack(alignment: .center) {
                    switch accessStatus {
                    case .fullAccess:
                        PhotosAndVideosGridView(assets: $assets, refreshAssets: refreshLibraryAssets, messageComposerViewModel: messageComposerViewModel)
                            .task {
                                getPhotosAndVideosAssets()
                            }
                        
                    case .limitedAccess:
                        LimitedLibraryAccessMessageView(getAssets: getPhotosAndVideosAssets)
                        
                        PhotosAndVideosGridView(assets: $assets, refreshAssets: refreshLibraryAssets, messageComposerViewModel: messageComposerViewModel)
                        
                        BrowsePhotosAndVideosView(
                            accessStatus: accessStatus ?? .undetermined,
                            messageComposerViewModel: messageComposerViewModel,
                            height: $selectorHeight,
                            minHeight: minHeight
                        )
                        
                    case .restricted, .denied, .undetermined, nil:
                        NoPhotoLibraryMessageView()
                    }
                }
            }
            .font(.subheadline)
            .padding(.horizontal)
            .highPriorityGesture(gesture, isEnabled: selectorHeight == minHeight)
            .overlay(alignment: .bottom) {
                if selectorHeight != minHeight && !messageComposerViewModel.selectionData.isEmpty {
                    CustomSendButtonView(channel: channel, messageComposerViewModel: messageComposerViewModel, height: $selectorHeight, sendButtonDisabled: $sendButton, minHeight: minHeight)
                }
            }
            .onScrollGeometryChange(for: Bool.self) { geometry in
                let contentHeight = geometry.contentSize.height
                let scrollViewHeight = geometry.containerSize.height
                let contentOffset = geometry.contentOffset.y
                
                if contentHeight > scrollViewHeight {
                    return contentOffset > (contentHeight - scrollViewHeight)
                } else {
                    return false
                }
            } action: { oldValue, newValue in
                fetchMoreAssets = newValue
            }

        }
        .foregroundStyle(Color.button)
        .frame(maxWidth: .infinity)
        .frame(height: selectorHeight)
        .background(Color.primaryBackground)
        .gesture(gesture)
        .onAppear {
            selectorHeight = minHeight
            handlePhotoLibraryAccessRequest()
        }
        .onChange(of: minHeight) { _, newValue in
            selectorHeight = newValue
        }
        .onChange(of: fetchMoreAssets) { oldValue, newValue in
            if newValue {
                getPhotosAndVideosAssets()
            }
        }
    }
}

extension SelectorView {
    func onDragChanged(_ dragValue: DragGesture.Value) {
        if dragValue.translation.height < 0 && selectorHeight <= selectorMaxHeight {
            if selectorHeight + abs(dragValue.translation.height) <= selectorMaxHeight {
                selectorHeight += abs(dragValue.translation.height)
            }
        }
        if dragValue.translation.height > 0 && selectorHeight > minHeight {
            if selectorHeight + dragValue.translation.height > minHeight {
                selectorHeight -= dragValue.translation.height
            }
        }
    }
    
    func onDragEnded(_ dragValue: DragGesture.Value) {
        if selectorHeight > threshold {
            selectorHeight = selectorMaxHeight
        } else {
            selectorHeight = minHeight
        }
    }
    
    func handlePhotoLibraryAccessRequest() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            switch status {
            case .authorized:
                accessStatus = .fullAccess
            case .limited:
                accessStatus = .limitedAccess
            case .denied:
                accessStatus = .denied
            case .restricted:
                accessStatus = .restricted
            case .notDetermined:
                break
            @unknown default:
                fatalError("Unknown authorization status.")
            }
        }
    }
    
    func getPhotosAndVideosAssets() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.fetchLimit = fetchLimit
        if let lastCreationDate {
            fetchOptions.predicate = NSPredicate(format: "creationDate < %@", lastCreationDate as NSDate)
        }
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let results: PHFetchResult = PHAsset.fetchAssets(with: fetchOptions)
        
        DispatchQueue.main.async {
            if results.count > 0 {
                for i in 0..<results.count {
                    let asset = results[i]
                    if !assets.contains(where: { $0.localIdentifier == asset.localIdentifier }) {
                        assets.append(asset)
                    }
                }
            }
            lastCreationDate = results.lastObject?.creationDate
        }
    }
    
    func refreshLibraryAssets() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.fetchLimit = assets.count
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let results: PHFetchResult = PHAsset.fetchAssets(with: fetchOptions)
        
        DispatchQueue.main.async {
            assets = []
            if results.count > 0 {
                for i in 0..<results.count {
                    assets.append(results[i])
                }
            }
            lastCreationDate = results.lastObject?.creationDate
        }
    }
}

struct CustomSendButtonView: View {
    let channel: Channel
    @ObservedObject var messageComposerViewModel: MessageComposerViewModel
    @Binding var height: CGFloat
    @Binding var sendButtonDisabled: Bool
    let minHeight: CGFloat
    @EnvironmentObject var messageViewModel: MessageViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var alertViewModel: AlertMessageViewModel
    @EnvironmentObject var channelViewModel: ChannelViewModel
    
    var body: some View {
        ZStack {
            LinearGradient(stops: [
                .init(color: Color.black.opacity(0.0), location: 0.8),
                .init(color: Color.black.opacity(0.6), location: 0.9),
                .init(color: Color.black.opacity(0.9), location: 1.0)
            ], startPoint: .topLeading, endPoint: .bottomTrailing)
            .allowsHitTesting(false)
                .overlay(alignment: .bottomTrailing) {
                    SendButtonView {
                        Task {
                            sendButtonDisabled = true
                            do {
                                if messageComposerViewModel.editMessage,
                                    let channelId = channel.id,
                                    let messageId = messageComposerViewModel.editedMessageId,
                                    let finalizedText = messageComposerViewModel.finalizeText() {
                                    try await messageViewModel.updateMessageText(channelId: channelId, messageId: messageId, text: finalizedText)
                                    
                                    if messageId == channel.lastMessage?.messageId {
                                        let messageMap = messageViewModel.messages.first(where: { $0.channelId == channelId })
                                        guard let currentMessage = messageMap?.messages.first(where: { $0.id == messageId }) else {
                                            print("Failed to get last message in channel")
                                            return
                                        }
                                        
                                        var newCurrentMessage = currentMessage
                                        newCurrentMessage.text = finalizedText
                                        guard let lastMessage = LastMessage(from: newCurrentMessage) else {
                                            print("Failed to create last message data")
                                            return
                                        }
                                        
                                        try await channelViewModel.updateLastMessage(channelId: channelId, lastMessage: lastMessage)
                                    }
                                } else {
                                    try await messageViewModel.uploadFilesAndSendMessage(
                                        senderId: userViewModel.user?.id,
                                        selectionData: messageComposerViewModel.selectionData,
                                        channel: channel,
                                        finalizedText: messageComposerViewModel.finalizeText(),
                                        userViewModel: userViewModel
                                    )
                                    messageComposerViewModel.scrollToBottom = true
                                }
                                
                                messageComposerViewModel.resetInputs()
                            } catch {
                                print("Error sending message: \(error.localizedDescription)")
                                alertViewModel.presentAlert(message: "Failed to send message", type: .error)
                            }
                            sendButtonDisabled = false
                        }
                        height = minHeight
                    }
                    .padding([.trailing, .vertical], 20)
                    .disabled(sendButtonDisabled)
                }
        }
        .frame(maxWidth: .infinity)
    }
}
