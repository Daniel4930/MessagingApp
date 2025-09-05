//
//  SignupView.swift
//  MessagingApp
//
//  Created by Daniel Le on 8/16/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseMessaging

@MainActor
struct SignupView: View {
    @Binding var currentView: CurrentView
    
    @State private var email: String = ""
    @State private var errorEmailMessage: String = ""
    @State private var password: String = ""
    @State private var errorPasswordMessage: String = ""
    @State private var retypePassword: String = ""
    @State private var errorRetypePasswordMessage: String = ""
    @State private var isLoading: Bool = false
    
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var alertMessageViewModel: AlertMessageViewModel
    
    var body: some View {
        ScrollView {
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
                    
                    FormTextFieldView(formType: .password, formTitle: "Re-type password", textFieldTitle: "Enter a password", errorMessage: $errorRetypePasswordMessage, text: $retypePassword)
                    
                    Group {
                        Text("Password requirements:")
                            .font(.headline)
                        
                        requirement("At least 8 characters")
                        requirement("At least 1 uppercase letter")
                        requirement("At least 1 lowercase letter")
                        requirement("At least 1 number")
                        requirement("At least 1 special character")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Button {
                        errorEmailMessage = ""
                        errorPasswordMessage = ""
                        errorRetypePasswordMessage = ""
                        isLoading = true
                        
                        if email.isEmpty {
                            errorEmailMessage = "Email is missing"
                            isLoading = false
                        }
                        
                        if password != retypePassword {
                            errorPasswordMessage = "Passwords do not match"
                            errorRetypePasswordMessage = "Passwords do not match"
                            isLoading = false
                        } else {
                            let passwordErrors = validatePassword(password)
                            if !passwordErrors.isEmpty {
                                errorPasswordMessage = passwordErrors.joined(separator: "\n")
                                errorRetypePasswordMessage = passwordErrors.joined(separator: "\n")
                                isLoading = false
                            } else {
                                createNewUser()
                            }
                        }
                    } label: {
                        CustomAuthButtonLabelView(isLoading: $isLoading, buttonTitle: "Sign up")
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
            }
        }
        .scrollDismissesKeyboard(.immediately)
    }
}

extension SignupView {
    private func requirement(_ text: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text("•")
                .font(.headline)
            Text(text)
                .font(.body)
        }
    }
    
    func createNewUser() {
        FirebaseAuthService.shared.signUpUser(email: email, password: password) { result in
            switch result {
            case .success(let authDataResult):
                guard let userInsert = setupUserInsert(authDataResult: authDataResult) else {
                    print("Failed to setup user")
                    isLoading = false
                    return
                }
                
                Task {
                    do {
                        try await userViewModel.createNewUser(authId: authDataResult.user.uid, data: userInsert)
                    } catch {
                        isLoading = false
                        alertMessageViewModel.presentAlert(message: "Unable to sign up. Please try again", type: .error)
                    }
                    await userViewModel.fetchCurrentUser(email: email)
                    
                    if let user = userViewModel.user {
                        isLoading = false
                        currentView = user.userName.isEmpty ? .newUser : .content
                    }
                }
            case .failure(let error):
                isLoading = false
                switch error {
                case .emailAlreadyInUse:
                    errorEmailMessage = "Email alredy in use"
                case .invalidEmail:
                    errorEmailMessage = "Email is invalid"
                case .weakPassword:
                    errorPasswordMessage = "Password is weak"
                    errorRetypePasswordMessage = "Password is weak"
                case .operationNotAllowed:
                    alertMessageViewModel.presentAlert(message: "Server side error. Please try again", type: .error)
                case .networkError:
                    alertMessageViewModel.presentAlert(message: "Not connected to the internet", type: .error)
                case .unknown:
                    alertMessageViewModel.presentAlert(message: "Unknown error", type: .error)
                }
            }
        }
    }
    
    func setupUserInsert(authDataResult: AuthDataResult) -> User? {
        guard let email = authDataResult.user.email else { return nil }
        guard let registeredDate = authDataResult.user.metadata.creationDate else { return nil }
        var fmcToken: String?
        
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching FCM registration token: \(error.localizedDescription)")
            } else if let token = token {
                fmcToken = token
            }
        }
        
        let user = User (
            email: email,
            userName: "",
            displayName: "",
            registeredDate: Timestamp(date: registeredDate),
            icon: "",
            onlineStatus: OnlineStatus.online,
            aboutMe: "",
            bannerColor: "",
            friends: [],
            channelId: [],
            fcmToken: fmcToken
        )
        return user
    }
    
    func validatePassword(_ password: String) -> [String] {
           var errors: [String] = []
           
           if password.count < 8 {
               errors.append("Password must be at least 8 characters")
           }
           if password.range(of: "[A-Z]", options: .regularExpression) == nil {
               errors.append("*Password must contain at least 1 uppercase letter")
           }
           if password.range(of: "[a-z]", options: .regularExpression) == nil {
               errors.append("*Password must contain at least 1 lowercase letter")
           }
           if password.range(of: "[0-9]", options: .regularExpression) == nil {
               errors.append("*Password must contain at least 1 number")
           }
           if password.range(of: "[^A-Za-z0-9]", options: .regularExpression) == nil {
               errors.append("*Password must contain at least 1 special character")
           }
           
           return errors
       }
}
