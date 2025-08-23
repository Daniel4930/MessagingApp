//
//  UserInfo.swift
//  MessagingApp
//
//  Created by Daniel Le on 8/16/25.
//

import Foundation

enum OnlineStatus {
    case online
    case offline
    case invisible
    case doNotDisturb
    case idle
}

struct UserInfo: Codable, Identifiable, Equatable {
    let id: String
    let email: String
    let userName: String // Unique
    let displayName: String
    let registeredDate: Double
    let icon: String // Get the image from firebase storage (path)
    let onlineStatus: String
    let aboutMe: String
    let bannerColor: String // in hex
    let friends: [String]
}
