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
    @State private var thumbnail: UIImage?
    @State private var showPlayer = false
    @State private var failedToLoadVideo = false
    @State private var assetUrl: URL?
    
    let frame = CGSize(width: 100, height: 250)
    
    init(url: URL?, phAsset: PHAsset?, thumbnail: UIImage?) {
        self.url = url
        self.phAsset = phAsset
        self._thumbnail = State(initialValue: thumbnail)
    }
    
    var body: some View {
        ZStack {
            if let image = thumbnail {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: frame.height)
                    .clipped()
                    .cornerRadius(12)
                    .shadow(radius: 4)
                    .overlay(
                        Image(systemName: "play.circle.fill")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.white)
                            .shadow(radius: 10)
                    )
                    .onTapGesture {
                        if url != nil || assetUrl != nil {
                            showPlayer = true
                        }
                    }
            } else {
                if failedToLoadVideo {
                    Text("Failed to load video")
                        .frame(height: 250)
                } else {
                    ProgressView()
                        .frame(height: 250)
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .frame(height: 250)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                }
            }
        }
        .frame(height: 250)
        .fullScreenCover(isPresented: $showPlayer, onDismiss: {
            if let assetUrl, phAsset != nil {
                do {
                    try FileManager.default.removeItem(at: assetUrl)
                    self.assetUrl = nil
                } catch {
                    print("Error removing temporary file: \(error.localizedDescription)")
                }
            }
        }) {
            if let url {
                FittingVideoPlayer(url: url)
                    .ignoresSafeArea()
            } else if let assetUrl {
                FittingVideoPlayer(url: assetUrl)
                    .ignoresSafeArea()
            }
        }
        .onAppear {
            generateThumbnail()
        }
    }
    
    private func generateThumbnail() {
        Task {
            do {
                if let url {
                    let avAsset = AVURLAsset(url: url)
                    let cgImage = try await PhotoLibraryService.shared.generateVideoThumbnail(
                        avAsset: avAsset,
                        frame: frame
                    )
                    
                    thumbnail = UIImage(cgImage: cgImage)
                } else if let phAsset {
                    let videoRequest = PHVideoRequestOptions()
                    videoRequest.isNetworkAccessAllowed = true
                    videoRequest.deliveryMode = .highQualityFormat
                    
                    guard let avAsset = await PhotoLibraryService.shared.requestVideoAsset(asset: phAsset, options: videoRequest) else {
                        failedToLoadVideo = true
                        return
                    }
                    
                    if let avURLAsset = avAsset as? AVURLAsset {
                        let sourceURL = avURLAsset.url
                        let tempDirectory = FileManager.default.temporaryDirectory
                        let fileName = UUID().uuidString + "." + sourceURL.pathExtension
                        let destinationURL = tempDirectory.appendingPathComponent(fileName)
                        
                        if FileManager.default.fileExists(atPath: destinationURL.path) {
                            try FileManager.default.removeItem(at: destinationURL)
                        }
                        
                        try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
                        self.assetUrl = destinationURL
                    }
                    
                    let cgImage = try await PhotoLibraryService.shared.generateVideoThumbnail(
                        avAsset: avAsset,
                        frame: frame
                    )
                    thumbnail = UIImage(cgImage: cgImage)
                }
            } catch {
                print("Failed to process video asset: \(error)")
                failedToLoadVideo = true
            }
        }
    }
}
