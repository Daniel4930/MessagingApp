//
//  UserInfo.swift
//  MessagingApp
//
//  Created by Daniel Le on 8/16/25.
//

import Foundation

struct UserInfo: Codable {
    let id: UUID
    let email: String
    let password: String //Hash the password
    let userName: String // Unique
    let displayName: String
    let registeredData: String
    let icon: String // Get the image from firebase storage (path)
    let onlineStatus: String
    let aboutMe: String
    let bannerColor: String // in hex
    let friends: [UUID]
}
