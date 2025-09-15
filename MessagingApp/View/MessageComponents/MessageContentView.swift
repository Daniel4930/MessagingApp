//
//  MessageContentView.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/11/25.
//

import SwiftUI
import UIKit
import FirebaseStorage

struct SelectedAttachment: Identifiable {
    let id: String
    let attachmentType: UploadedFile.FileType
    let image: UIImage?
    let file: MessageFile?
    let videoData: Data?
    let task: StorageUploadTask
}

struct Attachment {
    var selectedAttachments: [SelectedAttachment]?
    var photoUrls: [String]?
    var videoUrls: [String]?
    var files: [MessageFile]?
}

struct MessageContentView: View {
    let message: Message
    @ObservedObject var messageComposerViewModel: MessageComposerViewModel
    @FocusState.Binding var focusedField: Field?
    
    let linkRegexPattern = /http(s)?:\/\/(www\.)?.+..+(\/.+)*/
    let linkMetadataService = LinkMetadataService()
    @State private var embededTitle = ""
    @State private var embededDescription = ""
    @State private var embededImage: UIImage?
    @State private var showEmbeded: Bool = false
    @State private var showSafari: Bool = false
    @State private var embededImageDimension: CGSize = .zero
    @State private var linkEmbededViewDimension: CGSize = .zero
    @State private var customTextViewHeight: CGFloat = .zero
    @State private var showMessageOptions = false
    
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var friendViewModel: FriendViewModel
    @EnvironmentObject var messageViewModel: MessageViewModel
    
    var attachmentFromMessage: Attachment? {
        var result: Attachment = Attachment(selectedAttachments: nil, photoUrls: nil, videoUrls: nil, files: nil)
        
        if !message.photoUrls.isEmpty {
            result.photoUrls = message.photoUrls
        }
        if !message.videoUrls.isEmpty {
            result.videoUrls = message.videoUrls
        }
        if !message.files.isEmpty {
            result.files = message.files
        }
        
        if let selectionData = message.selectionData, !selectionData.isEmpty {
            let uploadProgress = messageViewModel.uploadProgress
            
            let photoAttachments: [SelectedAttachment] = selectionData.compactMap { data in
                guard let image = data.photoInfo?.image,
                      let task = uploadProgress[data.identifier] else { return nil }
                return SelectedAttachment(id: data.identifier, attachmentType: .photo, image: image, file: nil, videoData: nil, task: task)
            }
            
            let videoAttachments: [SelectedAttachment] = selectionData.compactMap { data in
                guard let image = data.videoInfo?.thumbnail,
                        let videoData = data.videoInfo?.videoData,
                      let task = uploadProgress[data.identifier] else { return nil }
                return SelectedAttachment(id: data.identifier, attachmentType: .video, image: image, file: nil, videoData: videoData, task: task)
            }
            
            let fileAttachments: [SelectedAttachment] = selectionData.compactMap { data in
                guard let file = data.fileInfo,
                      let task = uploadProgress[data.identifier] else { return nil }
                
                let messageFile = MessageFile(url: nil, data: file.fileData, name: file.name, size: file.size)
                
                return SelectedAttachment(id: data.identifier, attachmentType: .file, image: nil, file: messageFile, videoData: nil, task: task)
            }
            
            result.selectedAttachments = photoAttachments + videoAttachments + fileAttachments
        }
        
        if result.photoUrls == nil && result.videoUrls == nil && result.files == nil && result.selectedAttachments == nil {
            return nil
        }
        return result
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            if let text = message.text {
                AttributedTextView(
                    text: text,
                    isPending: message.isPending,
                    customTextViewHeight: $customTextViewHeight,
                    showSafari: $showSafari,
                    showMessageOptions: $showMessageOptions,
                    isEdited: message.edited,
                    editing: messageComposerViewModel.editedMessageId == message.id,
                    onMentionTap: { userName in
                        if let user = userViewModel.fetchUserByUsername(name: userName, friends: friendViewModel.friends) {
                            messageComposerViewModel.userProfile = user
                        }
                    }
                )
                .frame(height: customTextViewHeight)
                .sheet(isPresented: $showSafari) {
                    if let url = URL(string: text) {
                        SafariView(url: url)
                    }
                }
                .task {
                    if text.contains(linkRegexPattern) {
                        retrieveMetaDataFromURL(url: text)
                    }
                }
            }
            
            if showEmbeded {
                organizeEmbededItems()
                    .overlay(alignment: .leading) {
                        Color.gray
                            .frame(width: linkEmbededViewDimension.width * 0.015)
                    }
                    .background(
                        GeometryReader { proxy in
                            Color("SecondaryBackgroundColor")
                                .onAppear {
                                    linkEmbededViewDimension.width = proxy.size.width
                                    linkEmbededViewDimension.height = proxy.size.height
                                }
                        }
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            
            if let attachmentFromMessage {
                GridImageView(
                    imageUrls: attachmentFromMessage.photoUrls,
                    selectedImages: attachmentFromMessage.selectedAttachments
                )
            
                VideoView(
                    videoUrls: attachmentFromMessage.videoUrls,
                    selectedAttachment: attachmentFromMessage.selectedAttachments
                )
                
                GridFilesView(
                    files: attachmentFromMessage.files,
                    selectedAttachment: attachmentFromMessage.selectedAttachments
                )
            }
        }
        .onLongPressGesture(perform: {
            showMessageOptions.toggle()
            focusedField = nil
        })
        .sheet(isPresented: $showMessageOptions) {
            EditMessageView(message: message, messageComposerViewModel: messageComposerViewModel)
                .presentationDetents([.medium, .large])
        }
    }
}
extension MessageContentView {
    func retrieveMetaDataFromURL(url: String) {
        linkMetadataService.getMetaDataFromUrl(urlString: url) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    embededTitle = response.title ?? ""
                    embededDescription = response.description ?? ""
                    embededImage = response.image
                    showEmbeded = true
                case .failure(let error):
                    print("Error: Can't retrieve website meta data \(error)")
                }
            }
        }
    }
    
    @ViewBuilder func organizeEmbededItems() -> some View {
        if embededImageDimension.width > embededImageDimension.height {
            VStack(alignment: .center) {
                EmbededLinkLayoutView(embededTitle: embededTitle, embededDescription: embededDescription, embededImage: embededImage, embededImageDimension: $embededImageDimension)
            }
        } else {
            HStack(alignment: .center) {
                EmbededLinkLayoutView(embededTitle: embededTitle, embededDescription: embededDescription, embededImage: embededImage, embededImageDimension: $embededImageDimension)
            }
        }
    }
    
    func separateMentionedNameAndMessage(text: String) -> [String] {
        var result: [String] = []
        
        var string: String = ""
        for subString in text.components(separatedBy: " ") {
            if let firstCharacter = subString.first, firstCharacter == "@" {
                if !string.isEmpty {
                    result.append(string)
                    string = ""
                }
                result.append(subString)
            } else {
                string.append(subString + " ")
            }
        }
        if !string.isEmpty {
            result.append(string)
        }
        
        //Remove extract space at the end if there is any
        result = result.map { $0.last == " " ? String($0.dropLast()) : $0 }
        
        return result
    }
    
    func styleMessage(_ text: String) -> AttributedString {
        var attributedString = AttributedString()
        
        for (index, substr) in separateMentionedNameAndMessage(text: text).enumerated() {
            var attributedSubstring = AttributedString()
            if substr.first == "@", let user = userViewModel.fetchUserByUsername(name: String(substr.dropFirst()), friends: friendViewModel.friends) {
                let name = user.displayName.isEmpty ? user.userName : user.displayName
                var tempAttributedString = AttributedString("@\(name)")
                tempAttributedString.font = Font.system(.body).bold()
                tempAttributedString.foregroundColor = Color.white
                tempAttributedString.backgroundColor = .blue.opacity(0.5)
                attributedSubstring.append(tempAttributedString)
                attributedSubstring.append(AttributedString(" "))
            } else {
                if index == 0 {
                    attributedSubstring.append(AttributedString("\(substr) "))
                } else {
                    attributedString.append(AttributedString("\(substr) "))
                }
            }
            attributedString.append(attributedSubstring)
        }
        
        return attributedString
    }
}


