//
//  PhotoLibraryService.swift
//  MessagingApp
//
//  Created by Daniel Le on 9/20/25.
//

import AVFoundation
import Photos
import UIKit

class PhotoLibraryService {
    static let shared = PhotoLibraryService()
    
    func requestImageFromPhotoLibraryAsset(asset: PHAsset, size: CGSize, options: PHImageRequestOptions) async -> UIImage? {
        var uiImage: UIImage?
        
        uiImage = await withCheckedContinuation { continuation in
            PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: options) { uiImage, _ in
                if let uiImage = uiImage {
                    continuation.resume(returning: uiImage)
                }
            }
        }
        
        if uiImage == nil {
            print("Image data returned nil when requesting an image from the asset")
        }
        
        return uiImage
    }
    
    func requestVideoAsset(asset: PHAsset, options: PHVideoRequestOptions) async -> AVAsset? {
        var avAsset: AVAsset?
        
        avAsset = await withCheckedContinuation { continuation in
            PHImageManager.default().requestAVAsset(forVideo: asset, options: options) { avAsset, _, _ in
                if let avAsset = avAsset {
                    continuation.resume(returning: avAsset)
                }
            }
        }
        return avAsset
    }
    
    func generateVideoThumbnail(avAsset: AVAsset, frame: CGSize) async throws -> CGImage {
        let size = await CGSize(width: frame.width * UIScreen.main.scale, height: frame.height * UIScreen.main.scale)
        let generator = AVAssetImageGenerator(asset: avAsset)
        generator.appliesPreferredTrackTransform = true
        generator.maximumSize = size
        
        return try await generator.image(at: CMTime.zero).image
    }
    
    func compressVideo(asset: PHAsset) async -> Data? {
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("mp4")

        let options = createVideoOptionsRequest()
        
        guard let avAsset = await requestVideoAsset(asset: asset, options: options) else {
            print("Failed to get AVAsset from PHAsset.")
            return nil
        }
        
        guard let exportSession = AVAssetExportSession(asset: avAsset, presetName: AVAssetExportPresetMediumQuality) else {
            print("Failed to create AVAssetExportSession.")
            return nil
        }
        
        exportSession.outputURL = tempURL
        exportSession.outputFileType = .mp4
        exportSession.shouldOptimizeForNetworkUse = true
        
        do {
            try await exportSession.export(to: tempURL, as: .mp4)
            defer {
                try? FileManager.default.removeItem(at: tempURL)
            }
            let data = try Data(contentsOf: tempURL)
            
            return data
        } catch {
            print("Video export failed: \(error.localizedDescription)")
            try? FileManager.default.removeItem(at: tempURL)
            return nil
        }
    }
    
    private func createVideoOptionsRequest() -> PHVideoRequestOptions {
        let videoRequestOptions = PHVideoRequestOptions()
        videoRequestOptions.deliveryMode = .highQualityFormat
        videoRequestOptions.isNetworkAccessAllowed = true
        return videoRequestOptions
    }
}
