//
//  User.swift
//  MessagingApp
//
//  Created by Daniel Le on 8/16/25.
//

import Foundation
import FirebaseFirestore

enum OnlineStatus: String, Codable {
    case online
    case offline
    case invisible
    case doNotDisturb
    case idle
}

struct User: Codable, Identifiable, Equatable, Hashable {
    @DocumentID var id: String?
    let email: String
    let userName: String // Unique
    let displayName: String
    @ServerTimestamp var registeredDate: Timestamp?
    let icon: String // Get the image from firebase storage (path)
    let onlineStatus: OnlineStatus
    let aboutMe: String
    let bannerColor: String // in hex
    var friends: [String]
    let channelId: [String]
    var fcmToken: String?
}
