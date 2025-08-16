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
    @ObservedObject var messageComposerViewModel: MessageComposerViewModel
    @Binding var scrollToBottom: Bool
    
    let selectorMaxHeight: CGFloat = UIScreen.main.bounds.height * 0.898
    let threshold: CGFloat = UIScreen.main.bounds.height * 0.6
    
    @State private var selectorHeight: CGFloat = .zero
    @State private var openCamera = false
    @State private var photoLibraryAccessPermissonGranted = false
    @State private var accessStatus: PhotoLibraryAccessStatus?
    @State private var assets: [PHAsset] = []
    @State private var enableHighPriorityGesture = false
    @EnvironmentObject var messageViewModel: MessageViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    
    var gesture: some Gesture {
        DragGesture()
            .onChanged { dragValue in
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
            .onEnded { dragValue in
                if selectorHeight > threshold {
                    selectorHeight = selectorMaxHeight
                } else {
                    selectorHeight = minHeight
                }
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
                PollsAndFilesButtonsView()
                    .highPriorityGesture(gesture)
            }
            
            ScrollView {
                LazyVStack(alignment: .leading) {
                    switch accessStatus {
                    case .fullAccess:
                        PhotosAndVideosGridView(assets: $assets, refreshAssets: getPhotosAndVideosAssets, messageComposerViewModel: messageComposerViewModel)
                            .task {
                                getPhotosAndVideosAssets()
                            }
                        
                    case .limitedAccess:
                        LimitedLibraryAccessMessageView(getAssets: getPhotosAndVideosAssets)
                        
                        PhotosAndVideosGridView(assets: $assets, refreshAssets: getPhotosAndVideosAssets, messageComposerViewModel: messageComposerViewModel)
                        
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
                    CustomSendButtonView(messageComposerViewModel: messageComposerViewModel, scrollToBottom: $scrollToBottom, height: $selectorHeight, minHeight: minHeight)
                }
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
    }
}

extension SelectorView {
    func handlePhotoLibraryAccessRequest() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            switch status {
            case .authorized:
                photoLibraryAccessPermissonGranted = true
                accessStatus = .fullAccess
            case .limited:
                photoLibraryAccessPermissonGranted = true
                accessStatus = .limitedAccess
            case .denied:
                photoLibraryAccessPermissonGranted = false
                accessStatus = .denied
            case .restricted:
                photoLibraryAccessPermissonGranted = false
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
    @ObservedObject var messageComposerViewModel: MessageComposerViewModel
    @Binding var scrollToBottom: Bool
    @Binding var height: CGFloat
    let minHeight: CGFloat
    @EnvironmentObject var messageViewModel: MessageViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    
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
//                        messageViewModel.addMessage (
//                            userId: userViewModel.user!.id!,
//                            text: messageComposerViewModel.finalizeText(),
//                            images: messageComposerViewModel.selectionData == [] ? [] : messageComposerViewModel.getPhotoURL(),
//                            files: messageComposerViewModel.selectionData == [] ? [] : messageComposerViewModel.getFileURL(),
//                            videos: messageComposerViewModel.selectionData == [] ? [] : messageComposerViewModel.getVideoURL(),
//                            location: .dm,
//                            reaction: nil,
//                            replyMessageId: nil,
//                            forwardMessageId: nil,
//                            edited: false
//                        )
                        messageComposerViewModel.uiTextView.text = ""
                        messageComposerViewModel.selectionData = []
                        messageComposerViewModel.showSendButton = false
                        messageComposerViewModel.customTextEditorHeight = MessageComposerViewModel.customTextEditorMinHeight
                        scrollToBottom = true
                        height = minHeight
                    }
                    .padding([.trailing, .vertical], 20)
                }
        }
        .frame(maxWidth: .infinity)
    }
}
