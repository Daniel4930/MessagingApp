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
            documentImageView
            
            fileInfomation
        }
        .padding()
        .background(Color("SecondaryBackgroundColor"))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .onTapGesture(perform: tapAction)
        .sheet(isPresented: $showFile) {
            if let fileUrl = embeddedFileViewModel.fileUrl {
                FilePreviewView(fileURL: fileUrl)
            }
        }
        .task { await prepareFileUrlLocally() }
    }
}

// MARK: - View components
extension EmbededFileLayoutView {
    var documentImageView: some View {
        Image(systemName: "document.fill")
            .resizable()
            .scaledToFit()
            .frame(width: 40, height: 40)
            .foregroundStyle(.gray)
    }
    
    var fileInfomation: some View {
        VStack(alignment: .leading) {
            Text(embeddedFileViewModel.file.name)
                .font(.callout)
                .foregroundStyle(.blue)
            
            Text(fileSize)
                .font(.caption)
        }
    }
}

// MARK: - View properties
extension EmbededFileLayoutView {
    var fileSize: String {
        embeddedFileViewModel.fileSizeTextFormat()
    }
}

// MARK: - View actions
extension EmbededFileLayoutView {
    func tapAction() {
        if embeddedFileViewModel.fileUrl != nil {
            showFile.toggle()
        } else {
            alertVM.presentAlert(message: "File can't be viewed.", type: .error)
        }
    }
    
    func prepareFileUrlLocally() async {
        if embeddedFileViewModel.fileUrl == nil {
            embeddedFileViewModel.fileUrl = await embeddedFileViewModel.prepareFileUrl()
        }
    }
}
