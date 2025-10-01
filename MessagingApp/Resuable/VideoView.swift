//
//  VideoView.swift
//  MessagingApp
//
//  Created by Daniel Le on 9/6/25.
//

import SwiftUI
import AVKit

struct VideoView: View {
    let videoUrls: [String]?
    let selectedAttachment: [SelectedAttachment]?
    let dimensions: [MediaDimension]?
    let columns = Array(repeating: GridItem(.flexible()), count: 2)

    @State private var uploadProgress: UploadProgress = .unknown
    @State private var cancelButtonSystemImage = "xmark"

    var body: some View {
        LazyVGrid(columns: columns) {
            if let selectedAttachment {
                ForEach(selectedAttachment) { attachment in
                    if attachment.attachmentType == .video, let videoAsset = attachment.videoAsset, let thumbnail = attachment.image {
                        PendingAttachmentsView(attachmentId: attachment.id) {
                            VideoMessageThumbnailView(url: nil, phAsset: videoAsset, thumbnail: thumbnail, dimension: nil)
                        }
                    }
                }
            } else {
                if let videoUrls {
                    ForEach(Array(videoUrls.enumerated()), id: \.element) { index, urlString in
                        if let url = URL(string: urlString) {
                            VideoMessageThumbnailView(url: url, phAsset: nil, thumbnail: nil, dimension: dimensions?[safe: index])
                        }
                    }
                }
            }
        }
    }
}
