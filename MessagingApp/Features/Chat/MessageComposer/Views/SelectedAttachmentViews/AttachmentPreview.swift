//
//  AttachmentPreview.swift
//  MessagingApp
//
//  Created by Daniel Le on 8/8/25.
//

import SwiftUI

struct AttachmentPreview: View {
    let image: UIImage?
    let isFile: Bool
    let index: Int
    @Binding var showAttachment: Bool
    @ObservedObject var messageComposerViewModel: MessageComposerViewModel
    
    var body: some View {
        attachmentPreviewContent
    }
}


// MARK: View components
extension AttachmentPreview {
    var attachmentPreviewContent: some View {
        Group {
            attachmentTypePreview()
        }
        .modifier(AttachmentPreviewModifier(
            messageComposerViewModel: messageComposerViewModel,
            showAttachment: $showAttachment,
            index: index)
        )
    }
    
    func attachmentTypePreview() -> some View {
        if isFile {
            return AnyView(
                Image(systemName: "document.fill")
                    .resizable()
                    .scaledToFit()
            )
        } else if let uiImage = image {
            return AnyView(
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            )
        }
        
        return AnyView(EmptyView())
    }
}
