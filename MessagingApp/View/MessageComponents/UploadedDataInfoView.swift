//
//  UploadedDataInfoView.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/27/25.
//

import SwiftUI

struct UploadedDataInfoView: View {
    @ObservedObject var uploadDataViewModel: MessageComposerViewModel
    let thumbnailSize = CGSize(width: 350, height: 500)
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {            
            if let dataToShow = uploadDataViewModel.dataToShow {
                let data = dataToShow.data
                
                if let photoData = data.photo {
                    Image(uiImage: photoData.image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: thumbnailSize.width, height: thumbnailSize.height)
                        .padding(.vertical)
                        .background(Color.primaryBackground)
                }
                
                LineIndicator(color: .white, width: 70, height: 3)
                
                Button {
                    uploadDataViewModel.selectionData.removeAll(where: { $0.identifier == uploadDataViewModel.dataToShow?.identifier })
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
