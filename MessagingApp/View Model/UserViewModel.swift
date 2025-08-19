//
//  UserViewModel.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/19/25.
//

import CoreData
import UIKit

enum OnlineStatus {
    case online
    case offline
    case invisible
    case doNotDisturb
    case idle
}

@MainActor
class UserViewModel: ObservableObject {
    @Published var user: UserInfo?
    @Published var friends: [UserInfo] = []
    
    private let sharedContainerInstance = PersistenceContainer.shared
    
    func fetchCurrentUser(email: String) async {
        self.user = await FirebaseCloudStoreService.shared.fetchUser(email: email)
    }
    
    func fetchUserById(id: String) async {
        if let friend = await FirebaseCloudStoreService.shared.fetchFriend(id: id) {
            self.friends.append(friend)
        }
    }
    
    func fetchUserByUsername(name: String) -> UserInfo? {
        if user?.userName == name {
            return user
        } else {
            return friends.first(where: { $0.userName == name })
        }
    }
}
