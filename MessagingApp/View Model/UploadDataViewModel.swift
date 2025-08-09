//
//  UploadDataViewModel.swift
//  MessagingApp
//
//  Created by Daniel Le on 8/4/25.
//

import Foundation
import _PhotosUI_SwiftUI

class UploadDataViewModel: ObservableObject {
    @Published var selectionData: [UploadData] = []
    static let maxSelection = 10
    
    func addData(uploadData: UploadData) {
        if selectionData.count < UploadDataViewModel.maxSelection {
            
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
}
