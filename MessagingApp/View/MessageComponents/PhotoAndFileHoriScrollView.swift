//
//  PhotoAndFileHorizontalScrollView.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/28/25.
//

import SwiftUI

struct PhotoAndFileHoriScrollView: View {
    @ObservedObject var uploadDataViewModel: MessageComposerViewModel
    @Binding var showPhotoAndFile: Bool
    
    let playImageSize = CGSize(width: 8, height: 8)
    
    
    var body: some View {
        ScrollView([.horizontal]) {
            HStack {
                ForEach(Array(uploadDataViewModel.selectionData.enumerated()), id: \.offset) { index, uploadData in
                    if let photo = uploadData.data.photo {
                        SelectedDataImagePreview(image: photo.image, index: index, showPhotoAndFile: $showPhotoAndFile, uploadDataViewModel: uploadDataViewModel)
                    }
                    else if let video = uploadData.data.video {
                        SelectedDataImagePreview(image: video.thumbnail, index: index, showPhotoAndFile: $showPhotoAndFile, uploadDataViewModel: uploadDataViewModel)
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
                    else if let file = uploadData.data.file {
                        
                    }
                }
            }
        }
        .padding(.leading)
    }
}

struct Preview: View {
    @State var show = true
    @StateObject var viewModel: MessageComposerViewModel = MessageComposerViewModel()
    
    var body: some View {
        PhotoAndFileHoriScrollView(uploadDataViewModel: viewModel, showPhotoAndFile: $show)
    }
}
