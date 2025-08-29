//
//  MessagingBarLayoutView.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/10/25.fdsfsd
//

import SwiftUI
import FirebaseFirestore
import FirebaseStorage

@MainActor
struct MessagingBarLayoutView: View {
    let channelId: String
    @Binding var showFileAndImageSelector: Bool
    @Binding var scrollToBottom: Bool
    @FocusState.Binding var focusedField: Field?
    
    @ObservedObject var messageComposerViewModel: MessageComposerViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var messageViewModel: MessageViewModel
    
    @State private var isSending = false
    
    // Local error enum for upload-specific failures
    enum UploadError: Error {
        case missingData
        case missingUserInfo
        case missingFileName
    }
    
    var body: some View {
        HStack(spacing: 10) {
            SelectorButtonLayoutView(showFileAndImageSelector: $showFileAndImageSelector, focusedField: $focusedField)
            
            CustomTextEditor(
                messageComposerViewModel: messageComposerViewModel,
                focusedField: $focusedField,
                scrollToBottom: $scrollToBottom
            )
            
            if messageComposerViewModel.showSendButton || !messageComposerViewModel.selectionData.isEmpty {
                SendButtonView {
                    Task {
                        isSending = true
                        do {
                            try await uploadFilesAndSendMessage()
                            
                            // Reset composer state on success
                            messageComposerViewModel.uiTextView.text = ""
                            messageComposerViewModel.selectionData = []
                            messageComposerViewModel.showSendButton = false
                            messageComposerViewModel.customTextEditorHeight = MessageComposerViewModel.customTextEditorMinHeight
                            scrollToBottom = true
                            
                        } catch {
                            print("Error sending message: \(error.localizedDescription)")
                            // TODO: Show an error alert to the user
                        }
                        isSending = false
                    }
                }
                .disabled(isSending)
            }
        }
        .padding(.horizontal, 13)
        .padding(.vertical, 10)
        .overlay(alignment: .top) {
            MentionLayoutViewAnimation(messageComposerViewModel: messageComposerViewModel) {
                MentionLayoutView(users: messageComposerViewModel.mathchUsers) { name in
                    let uiTextView = messageComposerViewModel.uiTextView
                    
                    uiTextView.text.removeLast(uiTextView.text.distance(from: uiTextView.text.lastIndex(of: "@")!, to: uiTextView.text.endIndex))
                    uiTextView.text.append("@" + name + " ")
                    messageComposerViewModel.uiTextView = uiTextView
                    messageComposerViewModel.showMention = false
                    
                    if let delegate = uiTextView.delegate as? CustomUITextView.Coordinator {
                        delegate.textViewDidChange(uiTextView)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .background(Color("PrimaryBackgroundColor"))
    }
    
    private func uploadFilesAndSendMessage() async throws {
        guard let senderId = userViewModel.user?.id else { throw UploadError.missingUserInfo }
        
        var photoUrls: [String] = []
        var fileUrls: [String] = []
        
        try await withThrowingTaskGroup(of: (url: URL, fileType: UploadedFile.FileType).self) { group in
            for file in messageComposerViewModel.selectionData {
                group.addTask {
                    let fileData: Data
                    let originalFileName: String
                    let storageFolder: FirebaseStorageFolder

                    // Extract data and metadata from the UploadedFile struct
                    switch file.fileType {
                    case .photo:
                        guard let photoInfo = file.photoInfo else { throw UploadError.missingData }
                        fileData = photoInfo.image
                        originalFileName = photoInfo.name
                        storageFolder = .images
                    case .video:
                        guard let videoInfo = file.videoInfo else { throw UploadError.missingData }
                        fileData = videoInfo.videoData
                        originalFileName = videoInfo.name
                        storageFolder = .videos
                    case .file:
                        guard let fileInfo = file.fileInfo else { throw UploadError.missingData }
                        fileData = fileInfo.data
                        originalFileName = fileInfo.name
                        storageFolder = .files
                    }

                    // Create a unique name for storage while preserving the file extension
                    let fileExtension = URL(fileURLWithPath: originalFileName).pathExtension
                    let uniqueFileNameInStorage = "\(UUID().uuidString).\(fileExtension)"
                    let storageRef = FirebaseStorageService.shared.createChildReference(
                        folder: storageFolder,
                        fileName: uniqueFileNameInStorage
                    )

                    let downloadUrl = try await FirebaseStorageService.shared.uploadData(reference: storageRef, data: fileData)
                    return (url: downloadUrl, fileType: file.fileType)
                }
            }

            for try await result in group {
                switch result.fileType {
                case .photo:
                    photoUrls.append(result.url.absoluteString)
                case .video, .file:
                    fileUrls.append(result.url.absoluteString)
                }
            }
        }
        
        guard messageComposerViewModel.finalizeText() != nil || !photoUrls.isEmpty || !fileUrls.isEmpty else {
            print("Cannot send an empty message")
            return
        }
        
        let message = Message(
            senderId: senderId,
            text: messageComposerViewModel.finalizeText(),
            photoUrls: photoUrls,
            fileUrls: fileUrls,
            date: Timestamp(),
            edited: false,
            reaction: nil,
            forwardMessageId: nil,
            replayMessageId: nil
        )
        
        await messageViewModel.sendMessage(channelId: channelId, message: message)
    }
}
