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
            if let uploadData = photoLibraryVM.uploadedFile {
                Button {
                    if messageComposerViewModel.checkDataExist(identifier: uploadData.identifier) {
                        messageComposerViewModel.removeData(identifier: uploadData.identifier)
                    }
                    else {
                        messageComposerViewModel.addData(uploadData: uploadData)
                    }
                } label: {
                    if uploadData.fileType == .photo, let photoInfo = uploadData.photoInfo {
                        PhotoThumbnailView(uiImage: photoInfo.image, dataExistInSelection: $dataExistInSelection)
                    }
                    if uploadData.fileType == .video, let videoInfo = uploadData.videoInfo {
                        VideoThumbnailView(uiImage: videoInfo.thumbnail, duration: videoInfo.duration, dataExistInSelection: $dataExistInSelection)
                    }
                }
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: photoLibraryVM.frame.width, height: photoLibraryVM.frame.height)
                    .overlay(
                        ProgressView()
                    )
            }
        }
        .task {
            await photoLibraryVM.loadPhotoOrVideoFile(asset: asset)
        }
        .onChange(of: messageComposerViewModel.selectionData) { oldValue, newValue in
            if let data = photoLibraryVM.uploadedFile {
                // Use Set-based lookup for O(1) complexity instead of O(n)
                let selectionIdentifiers = Set(newValue.map { $0.identifier })
                dataExistInSelection = selectionIdentifiers.contains(data.identifier)
            }
        }
    }
}
