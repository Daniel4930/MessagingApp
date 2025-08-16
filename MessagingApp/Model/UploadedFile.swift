//
//  UploadedFile.swift
//  MessagingApp
//
//  Created by Daniel Le on 8/5/25.
//

import UIKit

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
    let name: String
    let image: Data
}

struct VideoFile {
    let name: String
    let duration: Double
    let videoData: Data
    let thumbnail: Data
}

struct FileData {
    let name: String
    let data: Data
}
