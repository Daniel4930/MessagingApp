
//
//  LocalImageView.swift
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

struct LocalImageView: View {
    let uiImage: UIImage
    let uploadTask: StorageUploadTask
    let attachmentId: String
    
    @EnvironmentObject var messageViewModel: MessageViewModel
    @State private var uploadProgress: UploadProgress = .unknown
    @State private var cancelButtonSystemImage: String = "xmark.circle.fill"
    @State private var turnOffOverlay = false
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay {
                    if !turnOffOverlay {
                        Rectangle()
                            .fill(Color.black.opacity(0.3))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
            
            Button {
                uploadTask.cancel()
                uploadProgress = .failure
                messageViewModel.removeAttachmentFromUploadTask(attachmentIdentifier: attachmentId)
            } label: {
                Image(systemName: cancelButtonSystemImage)
                    .foregroundColor(.white.opacity(0.6))
                    .overlay(
                        Circle()
                            .trim(from: 0, to: progressValue(for: uploadProgress))
                            .stroke(strokeColor(for: uploadProgress), lineWidth: 2)
                    )
                    .padding(2)
                    .background(.black)
                    .clipShape(Circle())
            }
            .padding(6)
        }
        .onAppear {
            uploadTask.observe(.failure) { _ in
                self.uploadProgress = .failure
            }
            uploadTask.observe(.progress) { _ in
                self.uploadProgress = .progress
            }
            uploadTask.observe(.resume) { _ in
                self.uploadProgress = .resume
            }
            uploadTask.observe(.success) { _ in
                self.uploadProgress = .success
                self.cancelButtonSystemImage = "checkmark"
            }
        }
        .animation(.spring, value: cancelButtonSystemImage)
        .onChange(of: cancelButtonSystemImage) { _, newValue in
            if newValue == "checkmark" {
                turnOffOverlay = true
            }
        }
    }
    
    private func progressValue(for state: UploadProgress) -> CGFloat {
        switch state {
        case .failure: return 1.0
        case .progress: return uploadTask.snapshot.progress?.fractionCompleted ?? 0.0
        case .resume: return uploadTask.snapshot.progress?.fractionCompleted ?? 0.0
        case .success: return 1.0
        case .unknown: return 0.0
        }
    }

    private func strokeColor(for state: UploadProgress) -> Color {
        switch state {
        case .failure: return .red
        case .progress: return .blue
        case .resume: return .orange
        case .success: return .green
        case .unknown: return .clear
        }
    }
}
