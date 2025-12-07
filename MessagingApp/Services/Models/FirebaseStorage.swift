//
//  StorageFolder.swift
//  MessagingApp
//
//  Created by Daniel Le on 12/6/25.
//

import Foundation

enum FirebaseStorageFolder {
    case images
    case videos
    case files
    case icons
}

struct Config: Decodable {
    let STORAGE_BUCKET: String
}
