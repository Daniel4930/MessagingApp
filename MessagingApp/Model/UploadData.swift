//
//  UploadData.swift
//  MessagingApp
//
//  Created by Daniel Le on 8/5/25.
//

import UIKit

struct UploadData: Equatable {
    enum DataType {
        case photo
        case video
        case file
    }
    
    let identifier: String
    let data: (photo: PhotoData?, video: VideoData?, file: FileData?)
    
    static func == (lhs: UploadData, rhs: UploadData) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    struct PhotoData {
        let image: UIImage
    }
    
    struct VideoData {
        let thumbnail: UIImage
        let content: Data
        let duration: Double
    }
    
    struct FileData {
        let data: Data
    }
}
