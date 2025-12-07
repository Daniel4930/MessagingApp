//
//  AttachmentItemPreview.swift
//  MessagingApp
//
//  Created by Daniel Le on 11/2/25.
//

import SwiftUI

struct AttachmentItemPreview: View {
    let uploadData: UploadedFile
    let index: Int
    let viewModel: AttachmentHorizontalScrollViewModel
    @Binding var showAttachment: Bool
    @ObservedObject var messageComposerViewModel: MessageComposerViewModel
    
    var body: some View {
        previewItem()
    }
    
    @ViewBuilder
    private func previewItem() -> some View {
        if viewModel.isPhotoType(uploadData) {
            photoPreview
        } else if viewModel.isVideoType(uploadData) {
            videoPreview
        } else if viewModel.isFileType(uploadData) {
            filePreview
        }
    }
    
    private var photoPreview: some View {
        AttachmentPreview(
            image: viewModel.getPhotoImage(from: uploadData),
            isFile: false,
            index: index,
            showAttachment: $showAttachment,
            messageComposerViewModel: messageComposerViewModel
        )
    }
    
    private var videoPreview: some View {
        AttachmentPreview(
            image: viewModel.getVideoThumbnail(from: uploadData),
            isFile: false,
            index: index,
            showAttachment: $showAttachment,
            messageComposerViewModel: messageComposerViewModel
        )
        .modifier(VideoPlayOverlayModifier(playImageSize: viewModel.playImageSize))
    }
    
    private var filePreview: some View {
        AttachmentPreview(
            image: nil,
            isFile: true,
            index: index,
            showAttachment: $showAttachment,
            messageComposerViewModel: messageComposerViewModel
        )
    }
}
