//
//  CancelImageUploadButton.swift
//  MessagingApp
//
//  Created by Daniel Le on 9/14/25.
//

import SwiftUI
import FirebaseStorage

struct CancelImageUploadButton: View {
    let uploadTask: StorageUploadTask
    let attachmentId: String
    @Binding var uploadProgress: UploadProgress
    @Binding var cancelButtonSystemImage: String
    
    @EnvironmentObject var messageViewModel: MessageViewModel
    
    var body: some View {
        Button {
            uploadTask.cancel()
            uploadProgress = .failure
            messageViewModel.removeAttachmentFromUploadTask(attachmentIdentifier: attachmentId)
        } label: {
            Image(systemName: cancelButtonSystemImage)
                .frame(width: 20, height: 20)
                .foregroundColor(.white.opacity(0.6))
                .font(.footnote).bold()
                .padding(3)
                .overlay(
                    Circle()
                        .stroke(.gray, lineWidth: 2)
                )
                .overlay(
                    Circle()
                        .trim(from: 0, to: progressValue(for: uploadProgress))
                        .stroke(strokeColor(for: uploadProgress), lineWidth: 2)
                )
                .padding(5)
                .background(.black.opacity(0.7))
                .clipShape(Circle())
        }
        .tint(.clear)
    }
}

extension CancelImageUploadButton {
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
