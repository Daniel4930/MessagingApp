//
//  UploadedFile.swift
//  MessagingApp
//
//  Created by Daniel Le on 8/5/25.
//

import UIKit
import Photos

struct UploadedFile: Equatable {
    enum FileType {
        case photo
        case video
        case file
    }
    
    static func == (lhs: UploadedFile, rhs: UploadedFile) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    let identifier: String
    let fileType: FileType
    let photoInfo: PhotoFile?
    let videoInfo: VideoFile?
    let fileInfo: FileData?
}

struct PhotoFile {
    let image: UIImage
}

struct VideoFile {
    let duration: Double
    let thumbnail: UIImage
    let videoAsset: PHAsset
}

struct FileData {
    let storageUniqueName = UUID().uuidString
    let name: String
    let fileData: Data
    let size: Int
}
