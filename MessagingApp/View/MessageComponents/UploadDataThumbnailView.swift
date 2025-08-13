//
//  UploadDataThumbnailView.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/26/25.
//

import SwiftUI
import PhotosUI

struct UploadDataThumbnailView: View {
    let asset: PHAsset?
    @ObservedObject var uploadDataViewModel: UploadDataViewModel
    @State private var uploadData: UploadData? = nil
    @State private var dataExistInSelection = false
    
    let frame: (width: CGFloat, height: CGFloat) = (120, 120)
    let newOpacity: CGFloat = 0.3
    
    var body: some View {
        ZStack {
            if let uploadData = uploadData {
                Button {
                    if uploadDataViewModel.checkDataExist(identifier: uploadData.identifier) {
                        uploadDataViewModel.removeData(identifier: uploadData.identifier)
                    }
                    else {
                        uploadDataViewModel.addData(uploadData: uploadData)
                    }
                } label: {
                    if let photoData = uploadData.data.photo {
                        ImageThumbnailView(uiImage: photoData.image)
                            .opacity(dataExistInSelection ? newOpacity : 1)
                            .overlay(alignment: .topTrailing) {
                                if dataExistInSelection {
                                    Image(systemName: "checkmark.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 20, height: 20)
                                        .foregroundStyle(.blue)
                                        .padding([.top, .trailing], 8)
                                }
                            }
                    }
                    if let videoData = uploadData.data.video {
                        ImageThumbnailView(uiImage: videoData.thumbnail)
                            .overlay(alignment: .bottomLeading) {
                                HStack {
                                    Image(systemName: "play.circle.fill")
                                    Text("\(formatTime(seconds: Int(videoData.duration)))")
                                }
                                .font(.caption)
                                .padding(5)
                                .background {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color("SecondaryBackgroundColor"))
                                }
                                .padding([.leading, .bottom], 5)
                            }
                            .opacity(dataExistInSelection ? newOpacity : 1)
                            .overlay(alignment: .topTrailing) {
                                if dataExistInSelection {
                                    Image(systemName: "checkmark.circle.fill")
                                }
                            }
                            .overlay(alignment: .topTrailing) {
                                if dataExistInSelection {
                                    Image(systemName: "checkmark.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 20, height: 20)
                                        .foregroundStyle(.blue)
                                        .padding([.top, .trailing], 8)
                                }
                            }
                    }
                }
            }
            else {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: frame.width, height: frame.height)
                    .overlay(
                        ProgressView()
                    )
            }
        }
        .onAppear {
            loadPhotoOrVideo()
        }
        .onChange(of: uploadDataViewModel.selectionData) { oldValue, newValue in
            if let data = uploadData {
                if uploadDataViewModel.checkDataExist(identifier: data.identifier) {
                    dataExistInSelection = true
                }
                else {
                    dataExistInSelection = false
                }
            }
        }
    }
}



extension UploadDataThumbnailView {
    func formatTime(seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let secs = seconds % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, secs)
        } else {
            return String(format: "%d:%02d", minutes, secs)
        }
    }
    
    func loadPhotoOrVideo() {
        if let asset = asset {
            let size = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
            let requestImageOptions = PHImageRequestOptions()
            requestImageOptions.isSynchronous = false
            requestImageOptions.deliveryMode = .highQualityFormat
            requestImageOptions.isNetworkAccessAllowed = true
            
            if asset.mediaType == .image {
                PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .aspectFit, options: requestImageOptions) { uiImage, _ in
                    if let uiImage = uiImage {
                        uploadData = UploadData(identifier: asset.localIdentifier, data: (photo: UploadData.PhotoData(image: uiImage), nil, nil))
                    } else {
                        print("Can't convert to uiImage \(asset)")
                    }
                }
            }
            else if asset.mediaType == .video {
                //Get video thumbnail
                PHCachingImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .aspectFit, options: requestImageOptions) { uiImage, _ in
                    if let uiImage = uiImage {
                        let videoOptions = PHVideoRequestOptions()
                        videoOptions.isNetworkAccessAllowed = true
                        videoOptions.version = .current
                        videoOptions.deliveryMode = .highQualityFormat
                        
                        //Get the actual video data
                        PHImageManager.default().requestAVAsset(forVideo: asset, options: videoOptions) { avAsset, _, _ in
                            if let avAsset = avAsset as? AVURLAsset {
                                do {
                                    let videoData = try Data(contentsOf: avAsset.url)
                                    uploadData = UploadData(identifier: asset.localIdentifier, data: (nil, video: UploadData.VideoData(thumbnail: uiImage, content: videoData, duration: asset.duration), nil))
                                } catch {
                                    print("Error loading video data: \(error)")
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
