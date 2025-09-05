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
    var userName: String // Unique
    var displayName: String
    @ServerTimestamp var registeredDate: Timestamp?
    var icon: String // Get the image from firebase storage (path)
    var onlineStatus: OnlineStatus
    var aboutMe: String
    var bannerColor: String // in hex
    var friends: [String]
    var channelId: [String]
    var fcmToken: String?
}
