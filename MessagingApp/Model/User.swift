//
//  User.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/9/25.
//
import Foundation
import SwiftUI

struct User: Hashable, Identifiable {
    let id = UUID()
    let userName: String
    let displayName: String
    let icon: String
    let bannerColor: Color
    let onlineStaus: OnlineStatus
    let registeredDate: Date
    
    static let mockUser = [
        User(userName: "clyde#0000", displayName: "Clyde", icon: "icon", bannerColor: .red, onlineStaus: .doNotDisturb, registeredDate: Date()),
        User(userName: "phu", displayName: "Unlimited", icon: "userIcon", bannerColor: .red, onlineStaus: .idle, registeredDate: Date()),
        User(userName: "clyde#0000", displayName: "Clyde", icon: "icon", bannerColor: .red, onlineStaus: .doNotDisturb, registeredDate: Date())
//        User(userName: "phu", displayName: "Unlimited", icon: "userIcon", bannerColor: .red, onlineStaus: .idle, registeredDate: Date()),
//        User(userName: "clyde#0000", displayName: "Clyde", icon: "icon", bannerColor: .red, onlineStaus: .doNotDisturb, registeredDate: Date()),
//        User(userName: "clyde#0000", displayName: "Clyde", icon: "icon", bannerColor: .red, onlineStaus: .doNotDisturb, registeredDate: Date()),
//        User(userName: "phu", displayName: "Unlimited", icon: "userIcon", bannerColor: .red, onlineStaus: .idle, registeredDate: Date()),
//        User(userName: "clyde#0000", displayName: "Clyde", icon: "icon", bannerColor: .red, onlineStaus: .doNotDisturb, registeredDate: Date())
    ]
}

enum OnlineStatus {
    case online
    case offline
    case invisible
    case doNotDisturb
    case idle
}
