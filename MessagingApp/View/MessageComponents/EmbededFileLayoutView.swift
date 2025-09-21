//
//  FileEmbededView.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/13/25.
//

import SwiftUI

struct EmbededFileLayoutView: View {
    @StateObject var embeddedFileViewModel: EmbededFileViewModel
    @State private var showFile = false
    @EnvironmentObject var alertVM: AlertMessageViewModel
    
    init(file: MessageFile) {
        self._embeddedFileViewModel = StateObject(wrappedValue: EmbededFileViewModel(file: file))
    }
    
    var body: some View {
        HStack(alignment: .center) {
            Image(systemName: "document.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .foregroundStyle(.gray)
            VStack(alignment: .leading) {
                Text(embeddedFileViewModel.file.name)
                    .font(.callout)
                    .foregroundStyle(.blue)
                
                let fileSizeString = embeddedFileViewModel.fileSizeTextFormat()
                Text(fileSizeString)
                    .font(.caption)
            }
        }
        .padding()
        .background(Color("SecondaryBackgroundColor"))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .onTapGesture {
            if embeddedFileViewModel.fileUrl != nil {
                showFile.toggle()
            } else {
                alertVM.presentAlert(message: "File can't be viewed.", type: .error)
            }
        }
        .sheet(isPresented: $showFile) {
            if let fileUrl = embeddedFileViewModel.fileUrl {
                FilePreviewView(fileURL: fileUrl)
            }
        }
        .task {
            embeddedFileViewModel.fileUrl = await embeddedFileViewModel.prepareFileUrl()
        }
    }
}
