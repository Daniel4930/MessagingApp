//
//  UploadedFileInfoView.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/27/25.
//

import SwiftUI

struct UploadedFileInfoView: View {
    @ObservedObject var messageComposerViewModel: MessageComposerViewModel
    let thumbnailSize = CGSize(width: 350, height: 500)
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            contentView()
        }
        .modifier(UploadedFileInfoContentViewModifier())
    }
}

// MARK: View Components
extension UploadedFileInfoView {
    func contentView() -> some View {
        if let dataToShow = messageComposerViewModel.dataToShow {
            return AnyView(
                Group {
                    fileInfoView(dataToShow: dataToShow)
                    
                    LineIndicator(color: .white, width: 70, height: 3)
                    
                    Button(action: buttonAction) {
                        Text("Remove file")
                            .modifier(RemoveFileButtonViewModifier())
                    }
                    .padding(.vertical)
                }
            )
        }
        return AnyView(EmptyView())
    }
    
    func fileInfoView(dataToShow: UploadedFile) -> some View {
        Group {
            switch dataToShow.fileType {
            case .photo:
                if let uiImage = dataToShow.photoInfo?.image {
                    Image(uiImage: uiImage)
                        .resizable()
                }
            case .video:
                if let uiImage = dataToShow.videoInfo?.thumbnail {
                    Image(uiImage: uiImage)
                        .resizable()
                }
            case .file:
                if let uiImage = UIImage(systemName: "document.fill") {
                    Image(uiImage: uiImage)
                        .resizable()
                }
            }
        }
        .modifier(FileInfoModifier(thumbnailSize: thumbnailSize))
    }
}

// MARK: View actions
extension UploadedFileInfoView {
    func buttonAction() {
        messageComposerViewModel.selectionData.removeAll(where: { $0.identifier == messageComposerViewModel.dataToShow?.identifier })
        dismiss()
    }
}
