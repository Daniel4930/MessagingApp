//
//  PhotoLibraryViewModel.swift
//  MessagingApp
//
//  Created by Daniel Le on 9/20/25.
//

import Foundation
import Photos
import UIKit

@MainActor
class PhotoLibraryViewModel: ObservableObject {
    @Published var uploadedFile: UploadedFile?
    let frame: CGSize = .init(width: 120, height: 120)
    
    func loadPhotoOrVideoFile(asset: PHAsset?) async {
        if let asset = asset {
            if asset.mediaType == .image {
                await updateFileWithImage(asset: asset)
            }
            else if asset.mediaType == .video {
                await updateFileWithVideo(asset: asset)
            }
        }
    }
    
    func toggleThumbnailSelection(messageComposerViewModel: MessageComposerViewModel, uploadData: UploadedFile) {
        if messageComposerViewModel.checkDataExist(identifier: uploadData.identifier) {
            messageComposerViewModel.removeData(identifier: uploadData.identifier)
        }
        else {
            messageComposerViewModel.addData(uploadData: uploadData)
        }
    }
    
    private func createImageOptionsRequest() -> PHImageRequestOptions {
        let requestImageOptions = PHImageRequestOptions()
        requestImageOptions.deliveryMode = .highQualityFormat
        requestImageOptions.isNetworkAccessAllowed = true
        return requestImageOptions
    }
    
    private func createVideoOptionsRequest() -> PHVideoRequestOptions {
        let videoRequestOptions = PHVideoRequestOptions()
        videoRequestOptions.deliveryMode = .highQualityFormat
        videoRequestOptions.isNetworkAccessAllowed = true
        return videoRequestOptions
    }
    
    private func updateFileWithImage(asset: PHAsset) async {
        let size = CGSize(width: frame.width * UIScreen.main.scale, height: frame.height * UIScreen.main.scale)
        let requestImageOptions = createImageOptionsRequest()
        
        guard let uiImage = await PhotoLibraryService.shared.requestImageFromPhotoLibraryAsset(
            asset: asset,
            size: size,
            options: requestImageOptions
        ) else {
            return
        }
        
        self.uploadedFile = UploadedFile(
            identifier: asset.localIdentifier,
            fileType: .photo,
            photoInfo: PhotoFile(image: uiImage),
            videoInfo: nil,
            fileInfo: nil
        )
    }
    
    private func updateFileWithVideo(asset: PHAsset) async {
        let requestVideoOptions = createVideoOptionsRequest()
        
        guard let avAsset = await PhotoLibraryService.shared.requestVideoAsset(
            asset: asset,
            options: requestVideoOptions
        ) else {
            return
        }
        
        guard let urlAsset = avAsset as? AVURLAsset else {
            print("ERROR: Unable to convert avAsset to urlAsset")
            return
        }
        
        do {
            let uiImage = try await UIImage(cgImage: PhotoLibraryService.shared.generateVideoThumbnail(avAsset: avAsset, frame: frame))
            let duration = try await getVideoDuration(urlAsset: urlAsset)
            
            self.uploadedFile = UploadedFile(
                identifier: asset.localIdentifier,
                fileType: .video,
                photoInfo: nil,
                videoInfo: VideoFile(
                    duration: duration,
                    thumbnail: uiImage,
                    videoAsset: asset
                ),
                fileInfo: nil
            )
        } catch {
            print("Failed to generate video thumbnail: \(error.localizedDescription)")
        }
    }
    
    private func getVideoDuration(urlAsset: AVURLAsset) async throws -> Double {
        let duration = try await urlAsset.load(.duration)
        let durationSeconds = CMTimeGetSeconds(duration)
        
        return Double(durationSeconds)
    }
}
