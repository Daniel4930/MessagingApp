//
//  PhotoLibraryThumbnailView.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/26/25.
//

import SwiftUI
import PhotosUI

struct PhotoLibraryThumbnailView: View {
    let asset: PHAsset?
    @ObservedObject var messageComposerViewModel: MessageComposerViewModel
    @State private var uploadedFile: UploadedFile? = nil
    @State private var dataExistInSelection = false
    
    let frame: (width: CGFloat, height: CGFloat) = (120, 120)
    let newOpacity: CGFloat = 0.3
    
    var body: some View {
        ZStack {
            if let uploadData = uploadedFile {
                Button {
                    if messageComposerViewModel.checkDataExist(identifier: uploadData.identifier) {
                        messageComposerViewModel.removeData(identifier: uploadData.identifier)
                    }
                    else {
                        messageComposerViewModel.addData(uploadData: uploadData)
                    }
                } label: {
                    if uploadData.fileType == .photo, let photoInfo = uploadData.photoInfo {
                        PhotoThumbnailView(uiImage: photoInfo.image, dataExistInSelection: $dataExistInSelection)
                    }
                    if uploadData.fileType == .video, let videoInfo = uploadData.videoInfo {
                        VideoThumbnailView(uiImage: videoInfo.thumbnail, duration: videoInfo.duration, dataExistInSelection: $dataExistInSelection)
                    }
                }
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: frame.width, height: frame.height)
                    .overlay(
                        ProgressView()
                    )
            }
        }
        .task {
            await loadPhotoOrVideoFile()
        }
        .onChange(of: messageComposerViewModel.selectionData) { oldValue, newValue in
            if let data = uploadedFile {
                if messageComposerViewModel.checkDataExist(identifier: data.identifier) {
                    dataExistInSelection = true
                }
                else {
                    dataExistInSelection = false
                }
            }
        }
    }
}
extension PhotoLibraryThumbnailView {    
    func loadPhotoOrVideoFile() async {
        if let asset = asset {
            let size = CGSize(width: frame.width * UIScreen.main.scale, height: frame.height * UIScreen.main.scale)
            
            let requestImageOptions = PHImageRequestOptions()
            requestImageOptions.deliveryMode = .highQualityFormat
            requestImageOptions.isNetworkAccessAllowed = true
            
            let videoRequestOptions = PHVideoRequestOptions()
            requestImageOptions.deliveryMode = .highQualityFormat
            videoRequestOptions.isNetworkAccessAllowed = true
            
            if asset.mediaType == .image {
                guard let uIImage = await messageComposerViewModel.requestImageFromAsset(asset: asset, size: size, options: requestImageOptions) else { return }
                let name = (asset.value(forKey: "filename") as? String) ?? UUID().uuidString + ".png"
                uploadedFile = UploadedFile(
                    identifier: asset.localIdentifier,
                    fileType: .photo,
                    photoInfo: PhotoFile(name: name, image: uIImage),
                    videoInfo: nil,
                    fileInfo: nil
                )
            }
            else if asset.mediaType == .video {
                let name = (asset.value(forKey: "filename") as? String) ?? UUID().uuidString + ".mp4"
                PHImageManager.default().requestAVAsset(forVideo: asset, options: videoRequestOptions) { (avAsset, _, _) in
                    guard let urlAsset = avAsset as? AVURLAsset else {
                        print("ERROR: Unable to convert avAsset to urlAsset")
                        return
                    }
                    let generator = AVAssetImageGenerator(asset: avAsset!)
                    generator.appliesPreferredTrackTransform = true
                    generator.maximumSize = size

                    Task {
                        do {
                            let cgImage = try await generator.image(at: CMTime.zero).image
                            let uiImage = UIImage(cgImage: cgImage)

                            let duration = try await urlAsset.load(.duration)
                            let durationSeconds = CMTimeGetSeconds(duration)
                            
                            uploadedFile = UploadedFile(
                                identifier: asset.localIdentifier,
                                fileType: .video,
                                photoInfo: nil,
                                videoInfo: VideoFile(
                                    name: name,
                                    duration: durationSeconds,
                                    videoFileUrl: urlAsset.url,
                                    thumbnail: uiImage
                                ),
                                fileInfo: nil
                            )
                        } catch {
                            print("Failed to generate video thumbnail: \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
    }
}
