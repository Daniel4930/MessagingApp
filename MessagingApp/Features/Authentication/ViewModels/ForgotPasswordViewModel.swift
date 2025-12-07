//
//  ForgotPasswordViewModel.swift
//  MessagingApp
//
//  Created by Daniel Le on 10/19/25.
//

import Foundation

@MainActor
final class ForgotPasswordViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var emailErrorMessage: String = ""
    @Published var isLoading: Bool = false
    
    func sendResetPasswordLink(alertMessageViewModel: AlertMessageViewModel) {
        isLoading = true
        emailErrorMessage = ""
        
        guard handleEmptyEmail() else { return }
        
        FirebaseAuthService.shared.sendResetPasswordLink(email: email) { error in
            self.handleErrorResult(error: error, alertMessageViewModel: alertMessageViewModel)
        }
    }
    
    private func handleErrorResult(
        error: FirebaseResetPasswordError?,
        alertMessageViewModel: AlertMessageViewModel
    ) {
        isLoading = false
        switch error {
        case .invalidEmail:
            emailErrorMessage = "Email is invalid"
        case .networkError:
            alertMessageViewModel.presentAlert(message: "No internet connection. Please check your internet", type: .error)
        case .unknown:
            alertMessageViewModel.presentAlert(message: "Unknown error. Please try again later", type: .error)
        case nil:
            alertMessageViewModel.presentAlert(message: "Reset password link sent. Please check your email", type: .success)
        }
    }
    
    private func handleEmptyEmail() -> Bool {
        guard !email.isEmpty else {
            emailErrorMessage = "Email is empty"
            isLoading = false
            return false
        }
        
        return true
    }
}
