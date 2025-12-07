//
//  AttachmentHorizontalScrollView.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/28/25.
//

import SwiftUI

struct AttachmentHorizontalScrollView: View {
    @ObservedObject var messageComposerViewModel: MessageComposerViewModel
    @Binding var showAttachment: Bool
    
    @StateObject private var viewModel = AttachmentHorizontalScrollViewModel()
    
    var body: some View {
        attachmentPreviewScrollView
    }
}

// MARK: - View Components
extension AttachmentHorizontalScrollView {
    private var attachmentPreviewScrollView: some View {
        ScrollView([.horizontal]) {
            filePreviewContent
        }
        .padding(.leading)
    }
    
    private var filePreviewContent: some View {
        HStack {
            ForEach(Array(messageComposerViewModel.selectionData.enumerated()), id: \.offset) { index, uploadData in
                AttachmentItemPreview(
                    uploadData: uploadData,
                    index: index,
                    viewModel: viewModel,
                    showAttachment: $showAttachment,
                    messageComposerViewModel: messageComposerViewModel
                )
            }
        }
    }
}
