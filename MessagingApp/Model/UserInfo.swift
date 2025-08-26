//
//  UserInfo.swift
//  MessagingApp
//
//  Created by Daniel Le on 8/16/25.
//

import Foundation
import FirebaseFirestore

enum OnlineStatus: String, Codable {
    case online = "online"
    case offline = "offline"
    case invisible = "invisible"
    case doNotDisturb = "doNotDisturb"
    case idle = "idle"
}

struct UserInfo: Codable, Identifiable, Equatable {
    @DocumentID var id: String?
    let email: String
    let userName: String // Unique
    let displayName: String
    let registeredDate: Double
    let icon: String // Get the image from firebase storage (path)
    let onlineStatus: OnlineStatus.RawValue
    let aboutMe: String
    let bannerColor: String // in hex
    var friends: [String]
    let channelId: [String]
}
