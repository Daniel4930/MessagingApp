//
//  FilesButtonView.swift
//  MessagingApp
//
//  Created by Daniel Le on 8/4/25.
//

import SwiftUI

struct FilesButtonView: View {
    @ObservedObject var messageComposerViewModel: MessageComposerViewModel
    @State private var importing = false
    @StateObject private var viewModel = FilesButtonViewModel()
    @EnvironmentObject var alertViewModel: AlertMessageViewModel
    
    var body: some View {
        HStack {
            Button(action: buttonAction) {
                fileButton
            }
            .fileImporter(isPresented: $importing, allowedContentTypes: [.content]) { result in
                viewModel.processImportedFilesResult(
                    result: result,
                    alertViewModel: alertViewModel,
                    messageComposerViewModel: messageComposerViewModel
                )
            }

        }
        .font(.subheadline)
        .bold()
        .padding()
    }
}

// MARK: - View components
extension FilesButtonView {
    var fileButton: some View {
        HStack {
            Image(systemName: "paperclip")
            Text("Files")
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.buttonBackground)
        )
    }
}

// MARK: - View actions
extension FilesButtonView {
    func buttonAction() {
        importing = true
    }
}
