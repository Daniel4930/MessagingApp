//
//  EditUsernameViewModel.swift
//  MessagingApp
//
//  Created by Daniel Le on 12/6/25.
//

import Foundation

@MainActor
final class EditUsernameViewModel: ObservableObject {
    @Published var newUsername = ""
    @Published var usernameErrorMessage = ""
    @Published var isLoading = false
    
    func initializeUsername(userViewModel: UserViewModel) {
        if let username = userViewModel.user?.userName {
            newUsername = username
        }
    }
    
    func updateUsername(
        userViewModel: UserViewModel,
        alertMessageViewModel: AlertMessageViewModel
    ) async {
        usernameErrorMessage = ""
        isLoading = true
        
        if !handleNewUsernameError() {
            return
        }
        
        do {
            try await userViewModel.updateUsername(newUsername: newUsername)
            alertMessageViewModel.presentAlert(message: "Username updated successfully", type: .success)
        } catch {
            alertMessageViewModel.presentAlert(message: error.localizedDescription, type: .error)
        }
        isLoading = false
    }
    
    func handleNewUsernameError() -> Bool {
        if newUsername.isEmpty {
            usernameErrorMessage = "Username is empty"
            isLoading = false
            return false
        }
        
        if newUsername.contains(" ") {
            usernameErrorMessage = "Username can't contain spaces"
            isLoading = false
            return false
        }
        
        return true
    }
}
