//
//  MessageContentViewModel.swift
//  MessagingApp
//
//  Created by Daniel Le on 11/24/25.
//

import UIKit
import Photos

struct SelectedAttachment: Identifiable {
    let id: String
    let attachmentType: UploadedFile.FileType
    let image: UIImage?
    let file: MessageFile?
    let videoAsset: PHAsset?
}

struct Attachment {
    var selectedAttachments: [SelectedAttachment]
    var photoUrls: [String]
    var videoUrls: [String]
    var files: [MessageFile]
}

final class MessageContentViewModel: ObservableObject {
    @Published var embededTitle = ""
    @Published var embededDescription = ""
    @Published var embededImage: UIImage?
    @Published var showEmbeded = false
    
    let linkRegexPattern = /http(s)?:\/\/(www\.)?.+..+(\/.+)*/
    let linkMetadataService = LinkMetadataService()
    
    private func retrieveMetaDataFromURL(url: String) {
        linkMetadataService.getMetaDataFromUrl(urlString: url) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self.embededTitle = response.title ?? ""
                    self.embededDescription = response.description ?? ""
                    self.embededImage = response.image
                    self.showEmbeded = true
                case .failure(let error):
                    print("Error: Can't retrieve website meta data \(error)")
                }
            }
        }
    }
    
    func retrieveLinkData(text: String) {
        if text.contains(linkRegexPattern) {
            retrieveMetaDataFromURL(url: text)
        }
    }
    
    // MARK: Extract sent attachments
    
    func extractPhotoAttachments(attachmentData: [UploadedFile]) -> [SelectedAttachment] {
        attachmentData.compactMap { data in
            guard let image = data.photoInfo?.image else { return nil }
            
            return SelectedAttachment(id: data.identifier, attachmentType: .photo, image: image, file: nil, videoAsset: nil)
        }
    }
    
    func extractVideoAttachments(attachmentData: [UploadedFile]) -> [SelectedAttachment] {
        attachmentData.compactMap { data in
            guard let thumbnail = data.videoInfo?.thumbnail, let videoAsset = data.videoInfo?.videoAsset else { return nil }
            
            return SelectedAttachment(id: data.identifier, attachmentType: .video, image: thumbnail, file: nil, videoAsset: videoAsset)
        }
    }
    
    func extractFileAttachments(attachmentData: [UploadedFile]) -> [SelectedAttachment] {
        attachmentData.compactMap { data in
            guard let file = data.fileInfo else { return nil }
            
            let messageFile = MessageFile(storageUniqueName: nil, url: nil, data: file.fileData, name: file.name, size: file.size)
            
            return SelectedAttachment(id: data.identifier, attachmentType: .file, image: nil, file: messageFile, videoAsset: nil)
        }
    }
    
    func findAttachments(attachmentData: [UploadedFile]) -> [SelectedAttachment] {
        extractPhotoAttachments(attachmentData: attachmentData) + extractVideoAttachments(attachmentData: attachmentData) + extractFileAttachments(attachmentData: attachmentData)
    }
    
    // MARK: Get attachment urls from Firebase
    
    func getPhotoUrls(message: Message) -> [String] {
        message.photoUrls.isEmpty ? [] : message.photoUrls
    }
    
    func getVideoUrls(message: Message) -> [String] {
        message.videoUrls.isEmpty ? [] : message.videoUrls
    }
    
    func getFileUrls(message: Message) -> [MessageFile] {
        message.files.isEmpty ? [] : message.files
    }
}
