//
//  AccountSettingViewModel.swift
//  MessagingApp
//
//  Created by Daniel Le on 12/6/25.
//

import Foundation

@MainActor
final class AccountSettingViewModel: ObservableObject {
    @Published var password = ""
    
    func logout(userViewModel: UserViewModel, alertMessageViewModel: AlertMessageViewModel) async {
        await userViewModel.clearFCMToken()
        do {
            try FirebaseAuthService.shared.signOut()
            UserDefaults.standard.removeObject(forKey: "email")
            NotificationCenter.default.post(name: .didLogOut, object: nil)
        } catch {
            alertMessageViewModel.presentAlert(message: "Failed to sign out: \(error.localizedDescription)", type: .error)
        }
    }
    
    func deleteAccount(user: User, alertMessageViewModel: AlertMessageViewModel) async {
        do {
            // Reauthenticate user
            try await FirebaseAuthService.shared.reauthenticateUser(password: password)
            
            // Delete user data
            guard let documentId = user.id else {
                throw NSError()
            }
            try await FirebaseCloudStoreService.shared.deleteDocument(collection: .users, documentId: documentId)
            
            //Delete sent messages
            try await deleteUserMessages(user: user)
            
            // Delete user account
            try await FirebaseAuthService.shared.deleteUserAccount()
            
            UserDefaults.standard.removeObject(forKey: "email")
            NotificationCenter.default.post(name: .didLogOut, object: nil)
        } catch {
            alertMessageViewModel.presentAlert(message: "Failed to delete account", type: .error)
            
            #if DEBUG
            print("Failed to delete account. Error: \(error.localizedDescription)")
            #endif
        }
    }
    
    private func deleteUserMessages(user: User) async throws {
        guard let userId = user.id else {
            return
        }
        
        let channelIds = user.channelId
        
        for channelId in channelIds {
            try await FirebaseCloudStoreService.shared.deleteAllMessages(userId: userId, channelId: channelId)
        }
    }
}
