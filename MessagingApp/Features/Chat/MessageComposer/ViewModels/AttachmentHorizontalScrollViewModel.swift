//
//  AttachmentHorizontalScrollViewModel.swift
//  MessagingApp
//
//  Created by Daniel Le on 10/27/25.
//

import Foundation
import SwiftUI

@MainActor
final class AttachmentHorizontalScrollViewModel: ObservableObject {
    let playImageSize = CGSize(width: 8, height: 8)
    
    func isPhotoType(_ uploadData: UploadedFile) -> Bool {
        return uploadData.fileType == .photo && uploadData.photoInfo != nil
    }
    
    func isVideoType(_ uploadData: UploadedFile) -> Bool {
        return uploadData.fileType == .video && uploadData.videoInfo != nil
    }
    
    func isFileType(_ uploadData: UploadedFile) -> Bool {
        return uploadData.fileType == .file
    }
    
    func getPhotoImage(from uploadData: UploadedFile) -> UIImage? {
        return uploadData.photoInfo?.image
    }
    
    func getVideoThumbnail(from uploadData: UploadedFile) -> UIImage? {
        return uploadData.videoInfo?.thumbnail
    }
}
