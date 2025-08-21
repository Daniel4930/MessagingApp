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
    @State private var generalMessage: String = ""
    @State private var generalMessageColor: Color = .clear
    @State private var generalMessageHeight: CGFloat = .zero
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
                    .padding(.top, AlertMessageView.maxHeight)
                    .padding(.bottom)
                
                FormTextFieldView(formType: .email, formTitle: "Email", textFieldTitle: "Enter an email", errorMessage: $emailErrorMessage, text: $email)
                
                Button {
                    emailErrorMessage = ""
                    generalMessage = ""
                    generalMessageHeight = .zero
                    isLoading = true
                    
                    if email.isEmpty {
                        emailErrorMessage = "Email is empty"
                        isLoading = false
                    } else {
                        sendResetPasswordLink()
                    }
                } label: {
                    CustomButtonLabelView(isLoading: $isLoading, buttonTitle: "Send reset password link")
                }
                
                Spacer()
            }
            .padding(.horizontal)
            .overlay(alignment: .top) {
                AlertMessageView(text: $generalMessage, height: $generalMessageHeight, backgroundColor: $generalMessageColor)
            }
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
                generalMessage = "No internet connection. Please check your internet"
                generalMessageHeight = AlertMessageView.maxHeight
                generalMessageColor = .red
            case .unknown:
                generalMessage = "Unknown error. Please try again later"
                generalMessageHeight = AlertMessageView.maxHeight
                generalMessageColor = .red
            case nil:
                generalMessage = "Reset password link sent. Please check your email"
                generalMessageHeight = AlertMessageView.maxHeight
                generalMessageColor = .green
            }
            isLoading = false
        }
    }
}
