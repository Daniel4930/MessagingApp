//
//  UserViewModel.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/19/25.
//

import UIKit

@MainActor
class UserViewModel: ObservableObject {
    @Published var user: User?
    
    func createNewUser(authId: String, data: User) async throws {
        do {
            let _ = try await FirebaseCloudStoreService.shared.addDocument(collection: FirebaseCloudStoreCollection.users, documentId: authId, data: data)
        } catch {
            print(error)
            throw(error)
        }
    }
    
    func fetchCurrentUser(email: String) async {
        self.user = await FirebaseCloudStoreService.shared.fetchUser(email: email)
    }
    
    func fetchUserByUsername(name: String, friends: [User]) -> User? {
        if user?.userName == name {
            return user
        } else {
            return friends.first(where: { $0.userName == name })
        }
    }
}
