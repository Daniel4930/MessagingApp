//
//  LoginView.swift
//  MessagingApp
//
//  Created by Daniel Le on 8/16/25.
//

import SwiftUI

struct LoginView: View {
    @Binding var currentView: Tabs
    
    @State private var email: String = ""
    @State private var errorEmailMessage: String = ""
    @State private var password: String = ""
    @State private var errorPasswordMessage: String = ""
    @State private var generalErrorMessage: String = ""
    
    @EnvironmentObject var userViewModel: UserViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        hideKeyboard()
                    }
                VStack {
                    if !generalErrorMessage.isEmpty {
                        Text(generalErrorMessage)
                            .foregroundStyle(.red)
                    }
                    
                    FormTextFieldView(formType: .email, formTitle: "Email", textFieldTitle: "Enter an email", errorMessage: $errorEmailMessage, text: $email)
                        .padding(.bottom)
                    
                    FormTextFieldView(formType: .password, formTitle: "Password", textFieldTitle: "Enter a password", errorMessage: $errorPasswordMessage, text: $password)
                    
                    HStack {
                        NavigationLink(destination: ForgotPasswordView()) {
                            Text("Forgot password")
                        }
                        
                        Spacer()
                        
                        NavigationLink(destination: SignupView(currentView: $currentView)) {
                            Text("Create a new account")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .font(.subheadline)
                    .padding(.top)
                    
                    Button {
                        errorEmailMessage = ""
                        errorPasswordMessage = ""
                        generalErrorMessage = ""
                        
                        if email.isEmpty {
                            errorEmailMessage = "Email is missing"
                        }
                        if password.isEmpty {
                            errorPasswordMessage = "Password is missing"
                        }
                        
                        if errorEmailMessage.isEmpty && errorPasswordMessage.isEmpty {
                            signIn()
                        }
                    } label: {
                        CustomButtonLabelView(buttonTitle: "Login")
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
            }
        }
    }
}
extension LoginView {
    func signIn() {
        FirebaseAuthService.shared.signInAUser(email: email, password: password) { result in
            switch result {
            case .success(let authData):
                Task {
                    if let email = authData.user.email {
                        await userViewModel.fetchCurrentUser(email: email)
                    }
                    currentView = .home
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    switch error {
                    case .wrongPassword, .invalidCredential:
                        self.generalErrorMessage = "Either or both email and password are incorrect"
                    case .invalidEmail:
                        self.errorEmailMessage = "Email is invalid"
                    case .userDisabled:
                        self.generalErrorMessage = "Your account has been disabled"
                    case .operationNotAllowed:
                        self.generalErrorMessage = "Server side error. Please try again"
                    case .networkError:
                        self.generalErrorMessage = "Network error. Please check your internet connection"
                    case .unknown:
                        self.generalErrorMessage = "Unknown error"
                    }
                }
            }
        }
    }
}
