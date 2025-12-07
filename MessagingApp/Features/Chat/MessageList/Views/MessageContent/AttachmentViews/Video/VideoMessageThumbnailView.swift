//
//  VideoMessageThumbnailView.swift
//  MessagingApp
//
//  Created by Daniel Le on 9/7/25.
//

import SwiftUI
import AVKit
import Photos

struct VideoMessageThumbnailView: View {
    let url: URL?
    let phAsset: PHAsset?
    let dimension: MediaDimension?
    @State private var showPlayer = false
    @StateObject private var viewModel = VideoThumbnailViewModel()

    init(url: URL?, phAsset: PHAsset?, thumbnail: UIImage?, dimension: MediaDimension?) {
        self.url = url
        self.phAsset = phAsset
        self.dimension = dimension
        self.viewModel.setThumbnail(image: thumbnail)
    }
    
    var body: some View {
        ZStack {
            thumbnailView
        }
        .frame(height: dimension != nil ? nil : 250)
        .frame(maxHeight: 250)
        .fullScreenCover(isPresented: $showPlayer, onDismiss: fullScreenDismissAction) {
            fullScreenVideoPlayerView
        }
        .task {
            viewModel.generateThumbnail(
                url: url,
                phAsset: phAsset
            )
        }
    }
}

// MARK: - View components
extension VideoMessageThumbnailView {
    var playCircleView: some View {
        Image(systemName: "play.circle.fill")
            .resizable()
            .frame(width: 60, height: 60)
            .foregroundColor(.white)
            .shadow(radius: 10)
    }
    
    @ViewBuilder var progressView: some View {
        if let dimension {
            Color.gray.opacity(0.1)
                .aspectRatio(CGSize(width: dimension.width, height: dimension.height), contentMode: .fit)
                .frame(maxHeight: 250)
                .cornerRadius(12)
                .overlay {
                    ProgressView()
                }
        }
    }
    
    @ViewBuilder var fullScreenVideoPlayerView: some View {
        if let url {
            FittingVideoPlayer(url: url)
                .ignoresSafeArea()
        } else if let assetUrl = viewModel.assetUrl {
            FittingVideoPlayer(url: assetUrl)
                .ignoresSafeArea()
        }
    }
    
    @ViewBuilder var thumbnailView: some View {
        if let image = viewModel.thumbnail {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(height: VideoThumbnailViewModel.frame.height)
                .clipped()
                .cornerRadius(12)
                .shadow(radius: 4)
                .overlay(playCircleView)
                .onTapGesture { videoPlayerTapAction() }
        } else {
            if viewModel.failedToLoadVideo {
                Text("Failed to load video")
                    .frame(height: 250)
            } else {
                progressView
            }
        }
    }
}

// MARK: - View actions
extension VideoMessageThumbnailView {
    func videoPlayerTapAction() {
        if url != nil || viewModel.assetUrl != nil {
            showPlayer = true
        }
    }
    
    func fullScreenDismissAction() {
        if let assetUrl = viewModel.assetUrl, phAsset != nil {
            do {
                try FileManager.default.removeItem(at: assetUrl)
                viewModel.assetUrl = nil
            } catch {
                print("Error removing temporary file: \(error.localizedDescription)")
            }
        }
    }
}
