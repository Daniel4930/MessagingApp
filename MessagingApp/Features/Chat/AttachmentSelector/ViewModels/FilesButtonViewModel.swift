//
//  FilesButtonViewModel.swift
//  MessagingApp
//
//  Created by Daniel Le on 12/5/25.
//

import Foundation

@MainActor
final class FilesButtonViewModel: ObservableObject {
    func processImportedFilesResult(result: Result<URL, any Error>, alertViewModel: AlertMessageViewModel, messageComposerViewModel: MessageComposerViewModel) {
        switch result {
        case .success(let url):
            let didStartAccessing = url.startAccessingSecurityScopedResource()
            defer {
                if didStartAccessing {
                    url.stopAccessingSecurityScopedResource()
                }
            }

            guard didStartAccessing else {
                alertViewModel.presentAlert(message: "Failed to access the selected file.", type: .error)
                return
            }

            do {
                // 1. Read file data
                let fileData = try Data(contentsOf: url)

                // 2. Get file size (bytes)
                let fileSize = fileData.count

                // 3. Extract filename
                let fileName = url.lastPathComponent

                // 4. Build FileData with Data instead of URL
                let file = FileData(
                    name: fileName,
                    fileData: fileData,
                    size: fileSize
                )

                let uploadedFile = UploadedFile(
                    identifier: UUID().uuidString,
                    fileType: .file,
                    photoInfo: nil,
                    videoInfo: nil,
                    fileInfo: file
                )

                messageComposerViewModel.addData(uploadData: uploadedFile)

            } catch {
                print("Could not read file: \(error.localizedDescription)")
                alertViewModel.presentAlert(message: "Could not read file.", type: .error)
            }

        case .failure(let error):
            alertViewModel.presentAlert(message: "Failed to get file: \(error.localizedDescription)", type: .error)
        }
    }
}
