//
//  MessageComposerViewModel.swift
//  MessagingApp
//
//  Created by Daniel Le on 8/4/25.
//

import Foundation
import _PhotosUI_SwiftUI

class MessageComposerViewModel: ObservableObject {
    @Published var selectionData: [UploadedFile] = []
    @Published var dataToShow: UploadedFile? = nil
    @Published var uiTextView: UITextView = UITextView()
    @Published var showSendButton: Bool = false
    @Published var showMention: Bool = false
    @Published var mathchUsers: [User] = []
    @Published var customTextEditorHeight: CGFloat = MessageComposerViewModel.customTextEditorMinHeight
    @Published var userProfile: User?
    @Published var editMessage = false
    @Published var editedMessageId: String?
    @Published var scrollToBottom = false
    @Published var scrollToId: String?
    
    static let maxSelection = 10
    static let customTextEditorMaxHeight = UIScreen.main.bounds.height / 5
    static let customTextEditorMinHeight = UIScreen.main.bounds.height / 20
    
    func addData(uploadData: UploadedFile) {
        if selectionData.count < MessageComposerViewModel.maxSelection {
            
            selectionData.append(uploadData)
        }
    }
    
    func removeData(identifier: String) {
        selectionData.removeAll { $0.identifier == identifier }
    }
    
    func removeDataAtIndex(index: Int) {
        selectionData.remove(at: index)
    }
    
    func checkDataExist(identifier: String) -> Bool {
        selectionData.contains(where: { $0.identifier == identifier })
    }
    
    func finalizeText() -> String? {
        if uiTextView.text.isEmpty {
            return nil
        }
        if uiTextView.text.last == " " {
            return String(uiTextView.text.dropLast())
        }
        return uiTextView.text
    }
    
    func getPhotoInfo() -> [PhotoFile?] {
        return selectionData.map { data in
            if data.fileType == .photo, let photoInfo = data.photoInfo {
                return photoInfo
            }
            return nil
        }
    }
    
    func requestImageFromAsset(asset: PHAsset, size: CGSize, options: PHImageRequestOptions) async -> UIImage? {
        var uiImage: UIImage?
        
        uiImage = await withCheckedContinuation { continuation in
            PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: options) { uiImage, _ in
                if let uiImage = uiImage {
                    continuation.resume(returning: uiImage)
                }
            }
        }
        
        if uiImage == nil {
            print("Image data returned nil when requesting an image from the asset")
        }
        
        return uiImage
    }
    
    func resetInputs() {
        uiTextView.text = ""
        selectionData = []
        showSendButton = false
        customTextEditorHeight = MessageComposerViewModel.customTextEditorMinHeight
        editMessage = false
        editedMessageId = nil
    }
}
