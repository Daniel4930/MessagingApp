//
//  FirebaseCloudStoreError.swift
//  MessagingApp
//
//  Created by Daniel Le on 12/6/25.
//

import Foundation

enum FirebaseError: Error {
    case operationFailed(String)
    case encodingFailed
}

enum FirebaseCloudStoreCollection: String {
    case users = "users"
    case channels = "channels"
    case messages = "messages"
    case notifications = "notifications"
}
