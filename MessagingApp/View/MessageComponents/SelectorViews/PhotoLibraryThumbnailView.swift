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
                    if uploadData.fileType == .photo, let photoInfo = uploadData.photoInfo, let uiImage = UIImage(data: photoInfo.image) {
                        PhotoThumbnailView(uiImage: uiImage)
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
//                    if uploadData.fileType == .video, let url = uploadData.url {
//                        VideoThumbnailView(videoUrl: url, dataExistInSelection: $dataExistInSelection)
//                    }
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
            loadPhotoOrVideoFile()
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
    func loadPhotoOrVideoFile() {
        if let asset = asset {
            let size = CGSize(width: frame.width * UIScreen.main.scale, height: frame.height * UIScreen.main.scale)
            
            let requestImageOptions = PHImageRequestOptions()
            requestImageOptions.isSynchronous = false
            requestImageOptions.deliveryMode = .highQualityFormat
            requestImageOptions.isNetworkAccessAllowed = true

            let contentEditingInputRequestOptions = PHContentEditingInputRequestOptions()
            contentEditingInputRequestOptions.isNetworkAccessAllowed = true
            
            let videoRequestOptions = PHVideoRequestOptions()
            videoRequestOptions.isNetworkAccessAllowed = true
            videoRequestOptions.deliveryMode = .highQualityFormat
            
            if asset.mediaType == .image {
                PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .aspectFit, options: requestImageOptions) { uiImage, _ in
                    if let uiImage = uiImage, let imageData = uiImage.pngData() {
                        let name = (asset.value(forKey: "filename") as? String) ?? UUID().uuidString + ".png"
                        uploadedFile = UploadedFile(identifier: asset.localIdentifier, fileType: .photo, photoInfo: PhotoFile(name: name, image: imageData), videoInfo: nil, fileInfo: nil)
                    }
                }
            }
            else if asset.mediaType == .video {
                PHImageManager.default().requestAVAsset(forVideo: asset, options: videoRequestOptions) { (avAsset, _, _) in
                    avAsset?.loadMetadata(for: .quickTimeMetadata) { metadata, error in
                        guard error != nil else { return }
                        guard let metadata = metadata else { return }
                        
                        print(metadata)
                    }
                }
            }
        }
    }
}
