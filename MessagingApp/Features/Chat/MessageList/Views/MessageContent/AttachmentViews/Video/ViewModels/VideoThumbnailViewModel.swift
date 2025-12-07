//
//  VideoThumbnailViewModel.swift
//  MessagingApp
//
//  Created by Daniel Le on 12/1/25.
//

import Foundation
import Photos
import UIKit

final class VideoThumbnailViewModel: ObservableObject {
    @Published var thumbnail: UIImage?
    @Published var failedToLoadVideo = false
    @Published var assetUrl: URL?
    
    static let frame = CGSize(width: 100, height: 250)
    
    private func generateThumbnailFromUrl(url: URL) async throws {
        let avAsset = AVURLAsset(url: url)
        let cgImage = try await PhotoLibraryService.shared.generateVideoThumbnail(
            avAsset: avAsset,
            frame: VideoThumbnailViewModel.frame
        )
        await MainActor.run {
            self.thumbnail = UIImage(cgImage: cgImage)
        }
    }
    
    private func setVideoRequestOptions(videoRequest: inout PHVideoRequestOptions) {
        videoRequest.isNetworkAccessAllowed = true
        videoRequest.deliveryMode = .highQualityFormat
    }
    
    private func requestVideoAsset(phAsset: PHAsset, videoRequest: PHVideoRequestOptions) async -> AVAsset? {
        guard let avAsset = await PhotoLibraryService.shared.requestVideoAsset(asset: phAsset, options: videoRequest) else {
            await MainActor.run {
                self.failedToLoadVideo = true
            }
            return nil
        }
        return avAsset
    }
    
    private func setAssetUrl(avAsset: AVAsset) async throws {
        if let avURLAsset = avAsset as? AVURLAsset {
            let sourceURL = avURLAsset.url
            let tempDirectory = FileManager.default.temporaryDirectory
            let fileName = UUID().uuidString + "." + sourceURL.pathExtension
            let destinationURL = tempDirectory.appendingPathComponent(fileName)

            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL)
            }

            try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
            await MainActor.run {
                self.assetUrl = destinationURL
            }
        }
    }
    
    private func generateThumbnailFromAsset(avAsset: AVAsset) async throws {
        let cgImage = try await PhotoLibraryService.shared.generateVideoThumbnail(
            avAsset: avAsset,
            frame: VideoThumbnailViewModel.frame
        )
        await MainActor.run {
            self.thumbnail = UIImage(cgImage: cgImage)
        }
    }
    
    func setThumbnail(image: UIImage?) {
        thumbnail = image
    }
    
    func generateThumbnail(url: URL?, phAsset: PHAsset?) {
        Task.detached(priority: .userInitiated) {
            do {
                if let url {
                    try await self.generateThumbnailFromUrl(url: url)
                } else if let phAsset {
                    var videoRequest = PHVideoRequestOptions()
                    self.setVideoRequestOptions(videoRequest: &videoRequest)

                    guard let avAsset = await self.requestVideoAsset(phAsset: phAsset, videoRequest: videoRequest) else {
                        return
                    }

                    try await self.setAssetUrl(avAsset: avAsset)

                    try await self.generateThumbnailFromAsset(avAsset: avAsset)
                }
            } catch {
                print("Failed to process video asset: \(error)")
                await MainActor.run {
                    self.failedToLoadVideo = true
                }
            }
        }
    }
}
