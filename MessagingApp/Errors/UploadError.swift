//
//  UploadError.swift
//  MessagingApp
//
//  Created by Daniel Le on 12/6/25.
//

enum UploadError: Error {
    case missingData
    case missingFileName
    case missingUserInfo
    case uploadFailed(String)
}
