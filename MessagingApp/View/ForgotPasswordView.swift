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
    
    let generalMessageMaxHeight: CGFloat = 50
    
    var body: some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    hideKeyboard()
                }
            
            VStack {
                Text("A password reset link will be sent to your email.")
                    .padding(.top, generalMessageMaxHeight)
                    .padding(.bottom)
                    .overlay(alignment: .top) {
                        Text(generalMessage)
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .bold()
                            .frame(maxWidth: .infinity)
                            .frame(height: generalMessageHeight)
                            .background(generalMessageColor.brightness(-0.5))
                    }
                
                FormTextFieldView(formType: .email, formTitle: "Email", textFieldTitle: "Enter an email", errorMessage: $emailErrorMessage, text: $email)
                    .padding(.horizontal)
                
                Button {
                    emailErrorMessage = ""
                    generalMessage = ""
                    generalMessageHeight = .zero
                    
                    if email.isEmpty {
                        emailErrorMessage = "Email is empty"
                    } else {
                        sendResetPasswordLink()
                    }
                } label: {
                    Text("Send reset password link")
                        .foregroundStyle(.white)
                        .padding(10)
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                        }
                }
                
                Spacer()
            }
            .animation(.spring(duration: 0.5), value: generalMessageHeight)
            .onChange(of: generalMessageHeight) { oldValue, newValue in
                if newValue == 0 {
                    generalMessageColor = .clear
                } else {
                    generalMessageColor = .red
                }
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
                generalMessageColor = .red
                generalMessageHeight = generalMessageMaxHeight
            case .unknown:
                generalMessage = "Unknown error. Please try again later"
                generalMessageColor = .red
                generalMessageHeight = generalMessageMaxHeight
            case nil:
                generalMessage = "Reset password link sent. Please check your email"
                generalMessageColor = .green
                generalMessageHeight = generalMessageMaxHeight
            }
        }
    }
}

#Preview {
    ContentView()
}
