//
//  FirebaseStorageError.swift
//  MessagingApp
//
//  Created by Daniel Le on 12/6/25.
//

import Foundation

enum FirebaseStorageUploadError: Error {
    case uploadFailed(String)
    case getDownloadUrlFailed(String)
    case noDownloadUrl
}

enum FirebaseDownloadFileError: Error {
    case downloadError(String)
    case noUrlError
}
