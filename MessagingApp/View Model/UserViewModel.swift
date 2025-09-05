//
//  UserViewModel.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/19/25.
//

import UIKit
import SwiftUI

@MainActor
class UserViewModel: ObservableObject {
    @Published var user: User?
    
    private var userListenerTask: Task<Void, Never>? = nil

    deinit {
        userListenerTask?.cancel()
    }
    
    func createNewUser(authId: String, data: User) async throws {
        do {
            let _ = try await FirebaseCloudStoreService.shared.addDocument(collection: FirebaseCloudStoreCollection.users, documentId: authId, data: data, additionalData: nil)
        } catch {
            print(error)
            throw(error)
        }
    }
    
    func fetchCurrentUser(email: String) async {
        self.user = await FirebaseCloudStoreService.shared.fetchUserByEmail(email: email)
    }
    
    func listenForUserChanges(userId: String) {
        userListenerTask?.cancel()
        userListenerTask = Task {
            do {
                let stream = FirebaseCloudStoreService.shared.listenForUser(userId: userId)
                for try await updatedUser in stream {
                    self.user = updatedUser
                }
            } catch {
                print("Error listening for user changes: \(error.localizedDescription)")
            }
        }
    }
    
    func fetchUserByUsername(name: String, friends: [User]) -> User? {
        if user?.userName == name {
            return user
        } else {
            return friends.first(where: { $0.userName == name })
        }
    }
    
    func updateUserFCMToken(_ token: String) async {
        guard let userId = user?.id else { return }
        await FirebaseCloudStoreService.shared.updateUserFCMToken(userId: userId, token: token)
    }

    func updateOnlineStatus(status: OnlineStatus) async {
        guard let userId = self.user?.id else { return }
        
        do {
            let statusData = ["onlineStatus": status.rawValue]
            try await FirebaseCloudStoreService.shared.updateData(collection: .users, documentId: userId, newData: statusData)
        } catch {
            print("Error updating online status: \(error.localizedDescription)")
        }
    }
    
    func updateUsername(newUsername: String) async throws {
        guard let currentUser = self.user, let userId = currentUser.id else { return }
        
        // Don't update if the username is the same
        guard currentUser.userName != newUsername else { return }
        
        // Check if username is already taken
        if let existingUser = await FirebaseCloudStoreService.shared.fetchUserByUsername(username: newUsername), existingUser.id != userId {
            throw NSError(domain: "UserViewModel", code: 0, userInfo: [NSLocalizedDescriptionKey: "Username is already taken"])
        }
        
        let updatedData: [String: Any] = ["userName": newUsername]
        
        try await FirebaseCloudStoreService.shared.updateData(collection: .users, documentId: userId, newData: updatedData)
        
        self.user?.userName = newUsername
    }
    
    func saveUser(displayName: String, aboutMe: String, bannerColor: Color, avatarImageData: Data?) async throws {
        guard let currentUser = self.user, let userId = currentUser.id else { return }
        
        var updatedData: [String: Any] = [:]
        
        // Keep track of new values
        var newDisplayName = currentUser.displayName
        var newAboutMe = currentUser.aboutMe
        var newBannerColor = currentUser.bannerColor
        var newIcon = currentUser.icon

        if currentUser.displayName != displayName {
            updatedData["displayName"] = displayName
            newDisplayName = displayName
        }
        
        if currentUser.aboutMe != aboutMe {
            updatedData["aboutMe"] = aboutMe
            newAboutMe = aboutMe
        }
        
        if let bannerColorHex = bannerColor.toHex(), currentUser.bannerColor != bannerColorHex {
            updatedData["bannerColor"] = bannerColorHex
            newBannerColor = bannerColorHex
        }
        
        if let imageData = avatarImageData {
            let iconUrl = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<URL, Error>) in
                let storageRef = FirebaseStorageService.shared.createChildReference(folder: .icons, fileName: userId)
                FirebaseStorageService.shared.uploadDataToBucket(reference: storageRef, data: imageData) { result in
                    switch result {
                    case .success(let url):
                        continuation.resume(returning: url)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
            }
            let iconUrlString = iconUrl.absoluteString
            updatedData["icon"] = iconUrlString
            newIcon = iconUrlString
        }
        
        if !updatedData.isEmpty {
            try await FirebaseCloudStoreService.shared.updateData(collection: .users, documentId: userId, newData: updatedData)
            
            self.user?.displayName = newDisplayName
            self.user?.aboutMe = newAboutMe
            self.user?.bannerColor = newBannerColor
            self.user?.icon = newIcon
        }
    }
}
