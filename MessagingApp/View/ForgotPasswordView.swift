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
    @State private var alertMessage: String = ""
    @State private var alertBackgroundColor: Color = .clear
    @State private var alertMessageHeight: CGFloat = .zero
    @State private var isLoading: Bool = false
    
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
                    alertBackgroundColor = .clear
                    alertMessageHeight = .zero
                    alertMessage = ""
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
        .overlay(alignment: .top) {
            AlertMessageView(text: $alertMessage, height: $alertMessageHeight, backgroundColor: $alertBackgroundColor)
        }
        .navigationBarBackButtonHidden(alertMessageHeight == AlertMessageView.maxHeight ? true : false)
    }
}
extension ForgotPasswordView {
    func sendResetPasswordLink() {
        FirebaseAuthService.shared.sendResetPasswordLink(email: email) { result in
            switch result {
            case .invalidEmail:
                emailErrorMessage = "Email is invalid"
            case .networkError:
                alertMessage = "No internet connection. Please check your internet"
                alertBackgroundColor = .red
                alertMessageHeight = AlertMessageView.maxHeight
            case .unknown:
                alertMessage = "Unknown error. Please try again later"
                alertBackgroundColor = .red
                alertMessageHeight = AlertMessageView.maxHeight
            case nil:
                alertMessage = "Reset password link sent. Please check your email"
                alertBackgroundColor = .green
                alertMessageHeight = AlertMessageView.maxHeight
            }
            isLoading = false
        }
    }
}
