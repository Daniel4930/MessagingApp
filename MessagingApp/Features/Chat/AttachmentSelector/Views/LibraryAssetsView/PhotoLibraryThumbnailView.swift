//
//  PhotoLibraryThumbnailView.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/26/25.
//

import SwiftUI
import PhotosUI

struct PhotoLibraryThumbnailView: View {
    let asset: PHAsset?
    @ObservedObject var messageComposerViewModel: MessageComposerViewModel
    @StateObject var photoLibraryVM = PhotoLibraryViewModel()
    @State private var dataExistInSelection = false
    
    var body: some View {
        ZStack {
            contentView()
        }
        .task {
            await photoLibraryVM.loadPhotoOrVideoFile(asset: asset)
        }
        .onChange(of: messageComposerViewModel.selectionData) { oldValue, newValue in
            onChangeSelectionData(newValue: newValue)
        }
    }
}

// MARK: View components
extension PhotoLibraryThumbnailView {
    func contentView() -> some View {
        if let uploadData = photoLibraryVM.uploadedFile {
            return AnyView(Button(action: { photoLibraryVM.toggleThumbnailSelection(messageComposerViewModel: messageComposerViewModel, uploadData: uploadData) })
            {
                thumbnailView(uploadData: uploadData)
            })
        }
        return AnyView(loadingAssetView)
    }
    
    func thumbnailView(uploadData: UploadedFile) -> some View {
        if uploadData.fileType == .photo, let photoInfo = uploadData.photoInfo {
            return AnyView(PhotoThumbnailView(uiImage: photoInfo.image, dataExistInSelection: $dataExistInSelection))
        }
        if uploadData.fileType == .video, let videoInfo = uploadData.videoInfo {
            return AnyView(VideoThumbnailView(uiImage: videoInfo.thumbnail, duration: videoInfo.duration, dataExistInSelection: $dataExistInSelection))
        }
        return AnyView(EmptyView())
    }
    
    var loadingAssetView: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color.gray.opacity(0.3))
            .frame(width: photoLibraryVM.frame.width, height: photoLibraryVM.frame.height)
            .overlay(
                ProgressView()
            )
    }
}

// MARK: View actions
extension PhotoLibraryThumbnailView {
    func onChangeSelectionData(newValue: [UploadedFile]) {
        if let data = photoLibraryVM.uploadedFile {
            let selectionIdentifiers = Set(newValue.map { $0.identifier })
            dataExistInSelection = selectionIdentifiers.contains(data.identifier)
        }
    }
}
