//
//  VideoMessageThumbnailView.swift
//  MessagingApp
//
//  Created by Daniel Le on 9/7/25.
//

import SwiftUI
import AVKit

struct VideoMessageThumbnailView: View {
    let url: URL
    @State private var thumbnail: UIImage? = nil
    @State private var showPlayer = false
    @State private var failedToLoadVideo = false
    
    var body: some View {
        ZStack {
            if let image = thumbnail {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 250)
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
                        showPlayer = true
                    }
            } else {
                if failedToLoadVideo {
                    Text("Failed to load video")
                        .frame(height: 250)
                } else {
                    ProgressView()
                        .frame(height: 250)
                        .onAppear {
                            generateThumbnail()
                        }
                }
            }
        }
        .frame(height: 250)
        .fullScreenCover(isPresented: $showPlayer) {
            ZStack(alignment: .topTrailing) {
                FittingVideoPlayer(url: url)
                    .ignoresSafeArea()

                Button {
                    showPlayer = false
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 28))
                        .foregroundColor(.white)
                        .padding([.leading, .bottom, .trailing])
                }
                .contentShape(Rectangle())
            }
        }
    }
    
    private func generateThumbnail() {
        Task {
            do {
                let asset = AVURLAsset(url: url)
                let generator = AVAssetImageGenerator(asset: asset)
                generator.appliesPreferredTrackTransform = true
                let duration = try await asset.load(.duration)
                let durationSeconds = CMTimeGetSeconds(duration)
                let safeTime = CMTime(
                    seconds: min(0.1, durationSeconds / 2),
                    preferredTimescale: 600
                )
                
                let result = try await generator.image(at: safeTime)
                let uiImage = UIImage(cgImage: result.image)
                
                DispatchQueue.main.async {
                    thumbnail = uiImage
                }
            } catch {
                print("Failed to generate video's thumbnail \(error.localizedDescription)")
                failedToLoadVideo = true
            }
        }
    }
}
