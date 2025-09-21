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
    let columns = Array(repeating: GridItem(.flexible()), count: 2)
    
    @State private var uploadProgress: UploadProgress = .unknown
    @State private var cancelButtonSystemImage = "xmark"

    var body: some View {
        LazyVGrid(columns: columns) {
            if let selectedAttachment {
                ForEach(selectedAttachment) { attachment in
                    if attachment.attachmentType == .video, let videoAsset = attachment.videoAsset, let thumbnail = attachment.image {
                        PendingAttachmentsView(attachmentId: attachment.id) {
                            VideoMessageThumbnailView(url: nil, phAsset: videoAsset, thumbnail: thumbnail)
                        }
                    }
                }
            } else {
                if let videoUrls {
                    ForEach(videoUrls.compactMap { URL(string: $0) }, id: \.self) { url in
                        VideoMessageThumbnailView(url: url, phAsset: nil, thumbnail: nil)
                    }
                }
            }
        }
    }
}
