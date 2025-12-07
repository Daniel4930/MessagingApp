//
//  SelectorView.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/15/25.
//

import SwiftUI
import PhotosUI
import Photos

struct SelectorView: View {
    let minHeight: CGFloat
    @Binding var channel: Channel
    @ObservedObject var messageComposerViewModel: MessageComposerViewModel
    @Binding var sendButton: Bool
    @Binding var showAttachmentSelector: Bool
    @Binding var selectorHeight: CGFloat
    
    @State private var openCamera = false
    @State private var enableHighPriorityGesture = false
    @State private var fetchMoreAssets = false
    
    @EnvironmentObject var messageViewModel: MessageViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    
    @StateObject var viewModel = SelectorViewModel()
    
    static let selectorMaxHeight: CGFloat = UIScreen.main.bounds.height * 0.83
    static let threshold: CGFloat = UIScreen.main.bounds.height * 0.6
    static let velocityThreshold: CGFloat = 20
    
    var body: some View {
        VStack {
            VStack(spacing: 0) {
                LineIndicator()
                
                header()
            }
            .highPriorityGesture(gesture)
            
            assetsScrollView
        }
        .modifier(SelectorViewModifier(
            animationTrigger: animationTrigger,
            selectorHeight: $selectorHeight
        ))
        .gesture(gesture, isEnabled: showAttachmentSelector)
        .task { taskAction() }
        .onChange(of: minHeight) { _, newValue in
            onChangeOfMinHeight(newValue: newValue)
        }
        .onChange(of: fetchMoreAssets) { oldValue, newValue in
            onChangeOfFetchMoreAssets(newValue: newValue)
        }
    }
}

// MARK: View computed properties
extension SelectorView {
    private var animationTrigger: Bool {
        selectorHeight > SelectorView.threshold
    }
}

// MARK: View components
extension SelectorView {
    var assetsScrollView: some View {
        ScrollView {
            photoLibraryView
        }
        .modifier(PhotoLibraryViewModifier())
        .highPriorityGesture(gesture, isEnabled: selectorHeight == minHeight)
        .overlay(alignment: .bottom) {
            overlayView()
        }
        .onScrollGeometryChange(for: Bool.self) { geometry in
            evaluateScrollGeometryChange(geometry: geometry)
        } action: { oldValue, newValue in
            fetchMoreAssets = newValue
        }
    }
    
    var gesture: some Gesture {
        DragGesture(minimumDistance: 6)
            .onChanged { dragValue in
                onDragChanged(dragValue)
            }
            .onEnded { dragValue in
                onDragEnded(dragValue)
            }
    }
    
    func overlayView() -> some View {
        if selectorHeight != minHeight && !messageComposerViewModel.selectionData.isEmpty {
            return AnyView(SendAttachmentsButtonView(
                channel: $channel,
                messageComposerViewModel: messageComposerViewModel,
                height: $selectorHeight,
                sendButtonDisabled: $sendButton,
                minHeight: minHeight)
            )
        }
        return AnyView(EmptyView())
    }
    
    var photoLibraryView: some View {
        LazyVStack(alignment: .center) {
            switch viewModel.accessStatus {
            case .fullAccess:
                fullAccessView
            case .limitedAccess:
                limitedAccessView
            case .restricted, .denied, .undetermined, nil:
                NoPhotoLibraryMessageView()
            }
        }
    }
    
    var fullAccessView: some View {
        PhotosAndVideosGridView(
            assets: $viewModel.assets,
            refreshAssets: viewModel.refreshLibraryAssets,
            messageComposerViewModel: messageComposerViewModel
        )
        .task { viewModel.getPhotosAndVideosAssets() }
    }
    
    var limitedAccessView: some View {
        Group {
            LimitedLibraryAccessMessageView(
                getAssets: viewModel.getPhotosAndVideosAssets,
                refreshAssets: viewModel.refreshLibraryAssets
            )
            
            PhotosAndVideosGridView(
                assets: $viewModel.assets,
                refreshAssets: viewModel.refreshLibraryAssets,
                messageComposerViewModel: messageComposerViewModel
            )
            
            BrowsePhotosAndVideosView(
                accessStatus: viewModel.accessStatus ?? .undetermined,
                messageComposerViewModel: messageComposerViewModel,
                height: $selectorHeight,
                minHeight: minHeight
            )
        }
    }
    
    func header() -> some View {
        if selectorHeight > SelectorView.threshold {
            return AnyView(
                SelectorNavTopBar(
                    height: $selectorHeight,
                    minHeight: minHeight,
                    accessStatus: viewModel.accessStatus ?? .undetermined,
                    messageComposerViewModel: messageComposerViewModel
                )
            )
        }
        return AnyView(FilesButtonView(messageComposerViewModel: messageComposerViewModel))
    }
}

// MARK: View actions
extension SelectorView {
    func evaluateScrollGeometryChange(geometry: ScrollGeometry) -> Bool {
        let contentHeight = geometry.contentSize.height
        let scrollViewHeight = geometry.containerSize.height
        let contentOffset = geometry.contentOffset.y
        
        if contentHeight > scrollViewHeight {
            return contentOffset > (contentHeight - scrollViewHeight)
        } else {
            return false
        }
    }
    
    func taskAction() {
        self.selectorHeight = minHeight
        viewModel.handlePhotoLibraryAccessRequest()
    }
    
    func onChangeOfMinHeight(newValue: CGFloat) {
        selectorHeight = newValue
    }
    
    func onChangeOfFetchMoreAssets(newValue: Bool) {
        if newValue {
            viewModel.getPhotosAndVideosAssets()
        }
    }
    
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
            if selectorHeight > SelectorView.threshold || dragValue.velocity.height >= SelectorView.velocityThreshold {
                selectorHeight = SelectorView.selectorMaxHeight
            } else {
                selectorHeight = minHeight
            }
            
            if dragValue.translation.height > 0 && abs(dragValue.velocity.height) >= SelectorView.velocityThreshold {
                selectorHeight = minHeight
            }
        }
    }
}
