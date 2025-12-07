//
//  LoginViewModel.swift
//  MessagingApp
//
//  Created by Daniel Le on 10/19/25.
//

import SwiftUI
import FirebaseMessaging

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorEmailMessage = ""
    @Published var errorPasswordMessage = ""
    
    func signIn(
        currentView: Binding<CurrentView>,
        userViewModel: UserViewModel,
        friendViewModel: FriendViewModel,
        alertMessageViewModel: AlertMessageViewModel
    ) async {
        isLoading = true
        
        guard handleEmptyCredentials() else {
            isLoading = false
            return
        }
        
        do {
            let authData = try await FirebaseAuthService.shared.signInAUser(email: email, password: password)
            
            //Save user's email for auto login
            UserDefaults.standard.set(email, forKey: "email")
            
            if let email = authData.user.email {
                await userViewModel.fetchCurrentUser(email: email)
                await updateFCMToken(userViewModel: userViewModel)
            }
            
            await updateView(
                currentView: currentView,
                userViewModel: userViewModel,
                friendViewModel: friendViewModel,
                alertMessageViewModel: alertMessageViewModel
            )
            
        } catch let error as FirebaseSignInError {
            presentSignInError(error: error, alertMessageViewModel: alertMessageViewModel)
        } catch {
            presentUnknownSignInError(error: error, alertMessageViewModel: alertMessageViewModel)
        }
    }
    
    private func handleEmptyCredentials() -> Bool {
        errorEmailMessage = ""
        errorPasswordMessage = ""

        guard !email.isEmpty else {
            errorEmailMessage = "Email is missing"
            return false
        }
        guard !password.isEmpty else {
            errorPasswordMessage = "Password is missing"
            return false
        }
        
        return true
    }
    
    private func updateFCMToken(userViewModel: UserViewModel) async {
        if let newToken = try? await Messaging.messaging().token() {
            if userViewModel.user?.fcmToken != newToken {
                await userViewModel.updateUserFCMToken(newToken)
            }
        }
    }
    
    /// Updated the view based on whether the user already exists or not
    private func updateView(
        currentView: Binding<CurrentView>,
        userViewModel: UserViewModel,
        friendViewModel: FriendViewModel,
        alertMessageViewModel: AlertMessageViewModel
    ) async {
        guard let user = userViewModel.user else {
            isLoading = false
            alertMessageViewModel.presentAlert(message: "Failed to sign in. Please try again", type: .error)
            return
        }
            
        if user.userName.isEmpty {
            currentView.wrappedValue = .newUser
        } else {
            await friendViewModel.fetchFriends(for: user)
            currentView.wrappedValue = .content
        }
        
        isLoading = false
    }
    
    private func presentSignInError(
        error: FirebaseSignInError,
        alertMessageViewModel: AlertMessageViewModel
    ) {
        isLoading = false
        
        switch error {
        case .wrongPassword, .invalidCredential:
            alertMessageViewModel.presentAlert(message: "Either or both email and password are incorrect", type: .error)
        case .invalidEmail:
            self.errorEmailMessage = "Email is invalid"
        case .userDisabled:
            alertMessageViewModel.presentAlert(message: "Your account has been disabled", type: .error)
        case .operationNotAllowed:
            alertMessageViewModel.presentAlert(message: "Server side error. Please try again", type: .error)
        case .networkError:
            alertMessageViewModel.presentAlert(message: "Network error. Please check your internet connection", type: .error)
        case .unknown:
            alertMessageViewModel.presentAlert(message: "Unknown error", type: .error)
        }
    }
    
    private func presentUnknownSignInError(
        error: any Error,
        alertMessageViewModel: AlertMessageViewModel
    ) {
        isLoading = false

        alertMessageViewModel.presentAlert(message: "An unexpected error occurred: \(error.localizedDescription)", type: .error)
    }
}
