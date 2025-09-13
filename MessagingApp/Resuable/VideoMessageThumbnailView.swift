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
    
    var body: some View {
        ZStack {
            if showPlayer {
                VideoPlayer(player: AVPlayer(url: url))
                    .onAppear {
                        let player = AVPlayer(url: url)
                        player.play() // autoplay on tap
                    }
            } else {
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
                    ProgressView() // loading spinner
                        .frame(height: 250)
                        .onAppear {
                            generateThumbnail()
                        }
                }
            }
        }
        .frame(height: 250)
    }
    
    private func generateThumbnail() {
        let asset = AVURLAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        let time = NSValue(time: CMTime(seconds: 1, preferredTimescale: 600))

        generator.generateCGImagesAsynchronously(forTimes: [time]) { _, cgImage, _, _, error in
            if let cgImage = cgImage {
                let uiImage = UIImage(cgImage: cgImage)
                DispatchQueue.main.async {
                    thumbnail = uiImage
                }
            } else if let error = error {
                print("Thumbnail generation failed: \(error.localizedDescription)")
            }
        }
    }
}

