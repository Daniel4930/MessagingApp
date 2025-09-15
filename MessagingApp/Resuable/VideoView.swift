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
            if let videoUrls {
                ForEach(videoUrls.compactMap { URL(string: $0) }, id: \.self) { url in
                    VideoMessageThumbnailView(url: url)
                }
            }
            
            if let selectedAttachment {
                ForEach(selectedAttachment) { attachment in
                    if attachment.attachmentType == .video, let url = getVideoTemporaryUrl(videoData: attachment.videoData) {
                        PendingAttachmentsView(task: attachment.task, attachmentId: attachment.id) {
                            VideoMessageThumbnailView(url: url)
                        }
                    }
                }
            }
        }
    }
}

extension VideoView {
    private func getVideoTemporaryUrl(videoData: Data?) -> URL? {
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent(UUID().uuidString + ".mp4")
        
        do {
            guard let videoData else {
                print("Video data is nil")
                return nil
            }
            
            try videoData.write(to: fileURL)
        } catch {
            print("Error writing video data: \(error)")
            return nil
        }
        
        return fileURL
    }
}
