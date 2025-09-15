//
//  GridFilesView.swift
//  MessagingApp
//
//  Created by Daniel Le on 9/14/25.
//

import SwiftUI

struct GridFilesView: View {
    let files: [MessageFile]?
    let selectedAttachment: [SelectedAttachment]?
    let columns = Array(repeating: GridItem(.flexible(), alignment: .leading), count: 1)
    
    var body: some View {
        LazyVGrid(columns: columns) {
            if let files {
                ForEach(files.indices, id: \.self) { index in
                    EmbededFileLayoutView(file: files[index])
                }
            }
            
            if let selectedAttachment {
                ForEach(selectedAttachment) { attachment in
                    if attachment.attachmentType == .file, let file = attachment.file {
                        PendingAttachmentsView(task: attachment.task, attachmentId: attachment.id) {
                            EmbededFileLayoutView(file: file)
                        }
                    }
                }
            }
        }
    }
}
