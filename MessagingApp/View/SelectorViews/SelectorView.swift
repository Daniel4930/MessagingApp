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
    @Binding var channel: Channel
    @ObservedObject var messageComposerViewModel: MessageComposerViewModel
    @Binding var sendButton: Bool
    @Binding var showFileAndImageSelector: Bool
    @Binding var selectorHeight: CGFloat
    
    @State private var openCamera = false
    @State private var accessStatus: PhotoLibraryAccessStatus?
    @State private var assets: [PHAsset] = []
    @State private var enableHighPriorityGesture = false
    @State private var fetchMoreAssets = false
    
    @EnvironmentObject var messageViewModel: MessageViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    
    static let selectorMaxHeight: CGFloat = UIScreen.main.bounds.height * 0.83
    static let threshold: CGFloat = UIScreen.main.bounds.height * 0.6
    let velocityThreshold: CGFloat = 20
    
    var gesture: some Gesture {
        DragGesture(minimumDistance: 6)
            .onChanged { dragValue in
                onDragChanged(dragValue)
            }
            .onEnded { dragValue in
                onDragEnded(dragValue)
            }
    }
    
    var body: some View {
        VStack {
            VStack(spacing: 0) {
                LineIndicator()
                
                if selectorHeight > SelectorView.threshold {
                    SelectorNavTopBar(
                        height: $selectorHeight,
                        minHeight: minHeight,
                        accessStatus: accessStatus ?? .undetermined,
                        messageComposerViewModel: messageComposerViewModel
                    )
                } else {
                    FilesButtonsView(messageComposerViewModel: messageComposerViewModel)
                }
            }
            .highPriorityGesture(gesture)
            
            ScrollView {
                LazyVStack(alignment: .center) {
                    switch accessStatus {
                    case .fullAccess:
                        PhotosAndVideosGridView(assets: $assets, refreshAssets: refreshLibraryAssets, messageComposerViewModel: messageComposerViewModel)
                            .task {
                                getPhotosAndVideosAssets()
                            }
                        
                    case .limitedAccess:
                        LimitedLibraryAccessMessageView(getAssets: getPhotosAndVideosAssets, refreshAssets: refreshLibraryAssets)
                        
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
            .scrollIndicators(.never)
            .font(.subheadline)
            .padding(.horizontal)
            .highPriorityGesture(gesture, isEnabled: selectorHeight == minHeight)
            .overlay(alignment: .bottom) {
                if selectorHeight != minHeight && !messageComposerViewModel.selectionData.isEmpty {
                    CustomSendButtonView(
                        channel: $channel,
                        messageComposerViewModel: messageComposerViewModel,
                        height: $selectorHeight,
                        sendButtonDisabled: $sendButton,
                        minHeight: minHeight)
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
        .animation(.smooth(duration: 0.3), value: selectorHeight > SelectorView.threshold)
        .foregroundStyle(Color.button)
        .frame(maxWidth: .infinity)
        .frame(height: selectorHeight)
        .background(Color.primaryBackground)
        .gesture(gesture, isEnabled: showFileAndImageSelector)
        .task {
            self.selectorHeight = minHeight
            self.handlePhotoLibraryAccessRequest()
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
        if dragValue.translation.height < 0 && selectorHeight <= SelectorView.selectorMaxHeight {
            if selectorHeight + abs(dragValue.translation.height) <= SelectorView.selectorMaxHeight {
                selectorHeight += abs(dragValue.translation.height)
            }
        } else if dragValue.translation.height > 0 && selectorHeight > minHeight {
            if selectorHeight + dragValue.translation.height > minHeight {
                selectorHeight -= dragValue.translation.height
            }
        }
    }
    
    func onDragEnded(_ dragValue: DragGesture.Value) {
        withAnimation(.smooth(duration: 0.3)) {
            if selectorHeight > SelectorView.threshold || dragValue.velocity.height >= velocityThreshold {
                selectorHeight = SelectorView.selectorMaxHeight
            } else {
                selectorHeight = minHeight
            }
            
            if dragValue.translation.height > 0 && abs(dragValue.velocity.height) >= velocityThreshold {
                selectorHeight = minHeight
            }
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
        }
    }
    
    func refreshLibraryAssets() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let results: PHFetchResult = PHAsset.fetchAssets(with: fetchOptions)
        
        DispatchQueue.main.async {
            assets = []
            if results.count > 0 {
                for i in 0..<results.count {
                    assets.append(results[i])
                }
            }
        }
    }
}

struct CustomSendButtonView: View {
    @Binding var channel: Channel
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
                            try await messageViewModel.sendMessage(
                                sendButtonDisabled: $sendButtonDisabled,
                                channel: $channel,
                                messageComposerViewModel: messageComposerViewModel,
                                channelViewModel: channelViewModel,
                                userViewModel: userViewModel,
                                alertViewModel: alertViewModel
                            )
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
