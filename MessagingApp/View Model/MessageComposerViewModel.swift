//
//  MessageComposerViewModel.swift
//  MessagingApp
//
//  Created by Daniel Le on 8/4/25.
//

import Foundation
import _PhotosUI_SwiftUI

class MessageComposerViewModel: ObservableObject {
    @Published var selectionData: [UploadData] = []
    @Published var dataToShow: UploadData? = nil
    @Published var uiTextView: UITextView = UITextView()
    @Published var showSendButton: Bool = false
    @Published var showMention: Bool = false
    @Published var mathchUsers: [User] = []
    @Published var customTextEditorHeight: CGFloat = MessageComposerViewModel.customTextEditorMinHeight
    
    static let maxSelection = 10
    static let customTextEditorMaxHeight = UIScreen.main.bounds.height / 5
    static let customTextEditorMinHeight = UIScreen.main.bounds.height / 20
    
    func addData(uploadData: UploadData) {
        if selectionData.count < MessageComposerViewModel.maxSelection {
            
            let identifier = uploadData.identifier
            
            if let photoData = uploadData.data.photo {
                selectionData.append(UploadData(identifier: identifier, data: (photo: photoData, video: nil, file: nil)))
            }
            else if let videoData = uploadData.data.video {
                selectionData.append(UploadData(identifier: identifier, data: (nil, videoData, nil)))
            }
            else if let fileData = uploadData.data.file {
                selectionData.append(UploadData(identifier: identifier, data: (nil, nil, fileData)))
            }
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
    
    func convertUImageToImageData() -> [Data?] {
        return selectionData.map { data in
            if let uiImage = data.data.photo?.image {
                return uiImage.pngData() ?? nil
            }
            return nil
        }
    }
}
