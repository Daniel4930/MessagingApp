
//
//  PendingAttachmentsView.swift
//  MessagingApp
//
//  Created by Daniel Le on 9/9/25.
//

import SwiftUI
import FirebaseStorage

struct SelectedAttachment: Identifiable {
    let id: String
    let image: UIImage
    let task: StorageUploadTask
}

struct PendingAttachmentsView: View {
    let selectionData: [UploadedFile]
    let uploadProgress: [String: StorageUploadTask]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            // MARK: - Photos
            if !photos.isEmpty {
                GridImageView(imageUrls: nil, selectedImages: photoAttachments)
            }
            
            // MARK: - Videos
            if !videos.isEmpty {
                GridImageView(imageUrls: nil, selectedImages: videoAttachments)
            }
            
            // MARK: - Files
            if !files.isEmpty {
                HStack(spacing: 12) {
                    ForEach(files, id: \.identifier) { file in
                        VStack(alignment: .center, spacing: 4) {
                            Image(systemName: "doc.text.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                            
                            if let fileInfo = file.fileInfo {
                                Text(fileInfo.name)
                                    .font(.caption)
                                    .lineLimit(1)
                            }
                        }
                        .frame(width: 80)
                    }
                }
            }
        }
    }
    
    // MARK: - Computed categories
    private var photos: [UIImage] {
        selectionData.compactMap { $0.photoInfo?.image }
    }
    
    private var videos: [UIImage] {
        selectionData.compactMap { $0.videoInfo?.thumbnail }
    }
    
    private var files: [UploadedFile] {
        selectionData.filter { $0.fileType == .file }
    }
    
    private var photoAttachments: [SelectedAttachment] {
        selectionData.compactMap { data in
            guard let image = data.photoInfo?.image,
                  let task = uploadProgress[data.identifier] else { return nil }
            return SelectedAttachment(id: data.identifier, image: image, task: task)
        }
    }
    
    private var videoAttachments: [SelectedAttachment] {
        selectionData.compactMap { data in
            guard let image = data.videoInfo?.thumbnail,
                  let task = uploadProgress[data.identifier] else { return nil }
            return SelectedAttachment(id: data.identifier, image: image, task: task)
        }
    }
}
