
//
//  LocalImageView.swift
//  MessagingApp
//
//  Created by Daniel Le on 9/9/25.
//

import SwiftUI
import FirebaseStorage

struct LocalImageView: View {
    let uiImage: UIImage
    let uploadTask: StorageUploadTask
    let attachmentId: String
    
    @EnvironmentObject var messageViewModel: MessageViewModel
    @State private var uploadProgress: UploadProgress = .unknown
    @State private var cancelButtonSystemImage: String = "xmark"
    @State private var turnOffOverlay = false
    
    var body: some View {
        PendingAttachmentsView(task: uploadTask, attachmentId: attachmentId) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}
