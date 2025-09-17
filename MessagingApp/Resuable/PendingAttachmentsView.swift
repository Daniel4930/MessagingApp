
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
    @State private var progressValue: Double = .zero
    
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
                    cancelButtonSystemImage: $cancelButtonSystemImage,
                    progressValue: $progressValue
                )
                .padding(6)
            }
        }
        .animation(.spring(duration: 1), value: progressValue)
        .onAppear {
            task.observe(.failure) { _ in
                self.uploadProgress = .failure
            }
            task.observe(.progress) { snapshot in
                self.uploadProgress = .progress
                if let value = snapshot.progress?.fractionCompleted {
                    self.progressValue = value
                }
            }
            task.observe(.resume) { _ in
                self.uploadProgress = .resume
            }
            task.observe(.success) { _ in
                self.uploadProgress = .success
                self.cancelButtonSystemImage = "checkmark"
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation(.spring()) {
                        self.turnOffOverlay = true
                    }
                }
            }
        }
    }
}
