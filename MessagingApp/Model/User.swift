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
    let name: String
    let icon: String
    let bannerColor: Color
    let onlineStaus: OnlineStatus
    let registeredDate: Date
    
    static let mockUser = [
        User(name: "Clyde", icon: "icon", bannerColor: .red, onlineStaus: .online, registeredDate: Date()),
        User(name: "Phu", icon: "icon", bannerColor: .red, onlineStaus: .online, registeredDate: Date())
    ]
}

enum OnlineStatus {
    case online
    case offline
    case invisible
}
