//
//  PhotosAndVideosGridView.swift
//  MessagingApp
//
//  Created by Daniel Le on 8/4/25.
//

import SwiftUI
import Photos
import PhotosUI

struct PhotosAndVideosGridView: View {
    @Binding var assets: [PHAsset]
    let refreshAssets: () -> Void
    @ObservedObject var messageComposerViewModel: MessageComposerViewModel
    
    @State private var openCamera = false
    let gridColums = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        contentView
    }
}

// MARK: View components
extension PhotosAndVideosGridView {
    var contentView: some View {
        LazyVGrid(columns: gridColums) {
            cameraButton
            
            thumbnailsView
        }
        .padding(.vertical)
    }
    
    var cameraButton: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color.buttonBackground)
            .frame(width: 120, height: 120)
            .overlay {
                cameraIcon
            }
            .onTapGesture {
                openCamera.toggle()
            }
            .fullScreenCover(isPresented: $openCamera) {
                CameraView(refreshAssets: refreshAssets)
            }
    }
    
    var thumbnailsView: some View {
        ForEach(assets, id: \.localIdentifier) { asset in
            PhotoLibraryThumbnailView(asset: asset, messageComposerViewModel: messageComposerViewModel)
        }
    }
    
    var cameraIcon: some View {
        Image(systemName: "camera")
            .resizable()
            .scaledToFit()
            .frame(width: 50, height: 50)
    }
}
