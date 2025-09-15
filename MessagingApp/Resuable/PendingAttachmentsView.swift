
//
//  PendingAttachmentsView.swift
//  MessagingApp
//
//  Created by Daniel Le on 9/9/25.
//

import SwiftUI
import FirebaseStorage

enum UploadProgress {
    case failure
    case progress
    case resume
    case success
    case unknown
}

struct PendingAttachmentsView<Content: View>: View {
    let task: StorageUploadTask
    let attachmentId: String
    let content: () -> Content
    
    @State private var turnOffOverlay = false
    @State private var cancelButtonSystemImage: String = "xmark"
    @State private var uploadProgress: UploadProgress = .unknown
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            content()
                .overlay {
                    if !turnOffOverlay {
                        Rectangle()
                            .fill(Color.black.opacity(0.3))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
            
            if !turnOffOverlay {
                CancelImageUploadButton(
                    uploadTask: task,
                    attachmentId: attachmentId,
                    uploadProgress: $uploadProgress,
                    cancelButtonSystemImage: $cancelButtonSystemImage
                )
                .padding(6)
            }
        }
        .onAppear {
            task.observe(.failure) { _ in
                self.uploadProgress = .failure
            }
            task.observe(.progress) { _ in
                self.uploadProgress = .progress
            }
            task.observe(.resume) { _ in
                self.uploadProgress = .resume
            }
            task.observe(.success) { _ in
                self.uploadProgress = .success
                self.cancelButtonSystemImage = "checkmark"
            }
        }
        .animation(.spring, value: cancelButtonSystemImage)
        .onChange(of: cancelButtonSystemImage) { _, newValue in
            if newValue == "checkmark" {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.turnOffOverlay = true
                }
            }
        }
    }
}
