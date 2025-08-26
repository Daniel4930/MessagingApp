//
//  UserViewModel.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/19/25.
//

import UIKit

@MainActor
class UserViewModel: ObservableObject {
    @Published var user: UserInfo?
    @Published var userIcon: UIImage?
    
    func createNewUser(authId: String, data: UserInfo) async {
        await FirebaseCloudStoreService.shared.addDocument(collection: FirebaseCloudStoreCollection.users.rawValue, documentId: authId, data: data)
    }
    
    func fetchCurrentUser(email: String) async {
        self.user = await FirebaseCloudStoreService.shared.fetchUser(email: email)
    }
    
    func fetchUserByUsername(name: String, friends: [UserInfo]) -> UserInfo? {
        if user?.userName == name {
            return user
        } else {
            return friends.first(where: { $0.userName == name })
        }
    }
}
