//
//  LoginView.swift
//  MessagingApp
//
//  Created by Daniel Le on 8/16/25.
//

import SwiftUI
import FirebaseMessaging

struct LoginView: View {
    @Binding var currentView: CurrentView
    
    @State private var email: String = ""
    @State private var errorEmailMessage: String = ""
    @State private var password: String = ""
    @State private var errorPasswordMessage: String = ""
    @State private var isLoading: Bool = false
    
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var friendViewModel: FriendViewModel
    @EnvironmentObject var channelViewModel: ChannelViewModel
    @EnvironmentObject var messageViewModel: MessageViewModel
    @EnvironmentObject var alertMessageViewModel: AlertMessageViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        hideKeyboard()
                    }
                VStack {
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
                        hideKeyboard()
                        errorEmailMessage = ""
                        errorPasswordMessage = ""
                        isLoading = true
                        
                        if email.isEmpty {
                            errorEmailMessage = "Email is missing"
                            isLoading = false
                        }
                        if password.isEmpty {
                            errorPasswordMessage = "Password is missing"
                            isLoading = false
                        }
                        
                        if errorEmailMessage.isEmpty && errorPasswordMessage.isEmpty {
                            signIn()
                        }
                    } label: {
                        CustomAuthButtonLabelView(isLoading: $isLoading, buttonTitle: "Login")
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
        Task {
            do {
                let authData = try await FirebaseAuthService.shared.signInAUser(email: email, password: password)
                
                UserDefaults.standard.set(email, forKey: "email")
                
                if let email = authData.user.email {
                    await userViewModel.fetchCurrentUser(email: email)
                    
                    if let newToken = try? await Messaging.messaging().token() {
                        if userViewModel.user?.fcmToken != newToken {
                            await userViewModel.updateUserFCMToken(newToken)
                        }
                    }
                }
                
                if let user = userViewModel.user {
                    if user.userName.isEmpty {
                        isLoading = false
                        currentView = .newUser
                    } else {
                        await friendViewModel.fetchFriends(for: user)
                        isLoading = false
                        currentView = .content
                    }
                } else {
                    isLoading = false
                    alertMessageViewModel.presentAlert(message: "Failed to sign in. Please try again", type: .error)
                }
                
            } catch let error as FirebaseSignInError {
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
            } catch {
                isLoading = false
                alertMessageViewModel.presentAlert(message: "An unexpected error occurred: \(error.localizedDescription)", type: .error)
            }
        }
    }
}
