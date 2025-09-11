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
            if let dataToShow = messageComposerViewModel.dataToShow {
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
                .scaledToFill()
                .frame(width: thumbnailSize.width, height: thumbnailSize.height)
                .padding(.vertical)
                .background(Color.primaryBackground)
                
                LineIndicator(color: .white, width: 70, height: 3)
                
                Button {
                    messageComposerViewModel.selectionData.removeAll(where: { $0.identifier == messageComposerViewModel.dataToShow?.identifier })
                    dismiss()
                } label: {
                    Text("Remove file")
                        .bold()
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(height: 20)
                        .padding()
                        .background {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.buttonBackground)
                        }
                }
                .padding(.vertical)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.primaryBackground)
    }
}
