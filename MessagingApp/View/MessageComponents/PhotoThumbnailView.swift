//
//  PhotoThumbnailView.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/26/25.
//

import SwiftUI
import PhotosUI

enum ImageFrom {
    case photoAsset
    case videoAsset(duration: Double)
}

struct PhotoThumbnailView: View {
    let asset: PHAsset?
    let item: PhotosPickerItem?
    @Binding var selectedPhotosAndFiles: [(image: UIImage?, file: Data?)]
    @State private var image: (uiImage: UIImage, from: ImageFrom)? = nil
    
    let frame: (width: CGFloat, height: CGFloat) = (120, 120)
    
    var body: some View {
        ZStack {
            if let image = image {
                Button {
                    selectedPhotosAndFiles.append((image: image.uiImage, file: nil))
                } label: {
                    Image(uiImage: image.uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: frame.width, height: frame.height)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(alignment: .bottomLeading) {
                            switch image.from {
                            case .photoAsset:
                                Color.clear
                            case .videoAsset(let duration):
                                HStack {
                                    Image(systemName: "play.circle.fill")
                                    Text("\(formatTime(seconds: Int(duration)))")
                                }
                                .font(.caption)
                                .padding(5)
                                .background {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color("SecondaryBackgroundColor"))
                                }
                                .padding([.leading, .bottom], 5)
                            }
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
        .onAppear {
            loadImage()
            loadPhotoOrVideo()
        }
    }
}

extension PhotoThumbnailView {
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
    
    func loadImage() {
        Task {
            do {
                if let item = item, let data = try await item.loadTransferable(type: Data.self), let uiImage = UIImage(data: data) {
                    image = (uiImage, ImageFrom.photoAsset)
                }
            } catch {
                print("Failed to load image: \(error)")
            }
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
                PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .aspectFit, options: requestImageOptions) { uiImage, info in
                    if let uiImage = uiImage {
                        image = (uiImage, ImageFrom.photoAsset)
                    } else {
                        print("Can't convert to uiImage \(asset)")
                        
                        if let info = info {
                            print("Info: \(info)")
                        }
                    }
                }
            }
            else if asset.mediaType == .video {
                PHCachingImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .aspectFit, options: requestImageOptions) { uiImage, _ in
                    if let uiImage = uiImage {
                        image = (uiImage, ImageFrom.videoAsset(duration: asset.duration))
                    }
                }
            }
        }
    }
}
