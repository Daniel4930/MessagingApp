//
//  ForgotPasswordView.swift
//  MessagingApp
//
//  Created by Daniel Le on 8/16/25.
//

import SwiftUI

struct ForgotPasswordView: View {
    @State private var email: String = ""
    @State private var emailErrorMessage: String = ""
    @State private var isLoading: Bool = false
    
    @EnvironmentObject var alertMessageViewModel: AlertMessageViewModel
    
    var body: some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    hideKeyboard()
                }
            
            VStack {
                Text("A password reset link will be sent to your email.")
                    .padding(.bottom)
                
                FormTextFieldView(formType: .email, formTitle: "Email", textFieldTitle: "Enter an email", errorMessage: $emailErrorMessage, text: $email)
                
                Button {
                    hideKeyboard()
                    emailErrorMessage = ""
                    isLoading = true
                    
                    if email.isEmpty {
                        emailErrorMessage = "Email is empty"
                        isLoading = false
                    } else {
                        sendResetPasswordLink()
                    }
                } label: {
                    CustomAuthButtonLabelView(isLoading: $isLoading, buttonTitle: "Send reset password link")
                }
                
                Spacer()
            }
            .padding(.horizontal)
        }
    }
}
extension ForgotPasswordView {
    func sendResetPasswordLink() {
        FirebaseAuthService.shared.sendResetPasswordLink(email: email) { result in
            switch result {
            case .invalidEmail:
                emailErrorMessage = "Email is invalid"
            case .networkError:
                alertMessageViewModel.presentAlert(message: "No internet connection. Please check your internet", type: .error)
            case .unknown:
                alertMessageViewModel.presentAlert(message: "Unknown error. Please try again later", type: .error)
            case nil:
                alertMessageViewModel.presentAlert(message: "Reset password link sent. Please check your email", type: .success)
            }
            isLoading = false
        }
    }
}
