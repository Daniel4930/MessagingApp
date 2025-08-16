//
//  PhotoAndFileHorizontalScrollView.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/28/25.
//

import SwiftUI

struct PhotoAndFileHoriScrollView: View {
    @ObservedObject var messageComposerViewModel: MessageComposerViewModel
    @Binding var showPhotoAndFile: Bool
    
    let playImageSize = CGSize(width: 8, height: 8)
    
    var body: some View {
        ScrollView([.horizontal]) {
            HStack {
                ForEach(Array(messageComposerViewModel.selectionData.enumerated()), id: \.offset) { index, uploadData in
                    if uploadData.fileType == .photo, let photoInfo = uploadData.photoInfo, let uiImage = UIImage(data: photoInfo.image) {
                        SelectedDataImagePreview(image: uiImage, index: index, showPhotoAndFile: $showPhotoAndFile, messageComposerViewModel: messageComposerViewModel)
                    }
                    else if uploadData.fileType == .video, let videoInfo = uploadData.videoInfo, let uiImage = UIImage(data: videoInfo.thumbnail) {
                        SelectedDataImagePreview(image: uiImage, index: index, showPhotoAndFile: $showPhotoAndFile, messageComposerViewModel: messageComposerViewModel)
                            .overlay(alignment: .bottomLeading) {
                                Image(systemName: "play.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: playImageSize.width, height: playImageSize.height)
                                    .padding(5)
                                    .background {
                                        RoundedRectangle(cornerRadius: 5)
                                            .fill(Color.secondaryBackground)
                                    }
                                    .padding([.leading, .bottom], 3)
                            }
                    }
                    else if uploadData.fileType == .file {
                        
                    }
                }
            }
        }
        .padding(.leading)
    }
}
