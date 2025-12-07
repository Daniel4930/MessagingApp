//
//  CancelImageUploadButton.swift
//  MessagingApp
//
//  Created by Daniel Le on 9/14/25.
//

import SwiftUI
import FirebaseStorage

struct CancelImageUploadButton: View {
    let uploadTask: StorageUploadTask?
    let attachmentId: String
    @Binding var uploadProgress: UploadProgress
    @Binding var cancelButtonSystemImage: String
    @Binding var progressValue: Double
    
    @EnvironmentObject var messageViewModel: MessageViewModel
    
    var body: some View {
        Button {
            if let uploadTask {
                uploadTask.cancel()
                uploadProgress = .failure
                messageViewModel.removeAttachmentFromUploadTask(attachmentIdentifier: attachmentId)
            }
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
                        .trim(from: 0, to: progressValue)
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
