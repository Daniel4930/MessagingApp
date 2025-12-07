//
//  SignupViewModel.swift
//  MessagingApp
//
//  Created by Daniel Le on 10/19/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseMessaging
import FirebaseCore

@MainActor
final class SignupViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var errorEmailMessage: String = ""
    @Published var password: String = ""
    @Published var errorPasswordMessage: String = ""
    @Published var retypePassword: String = ""
    @Published var errorRetypePasswordMessage: String = ""
    @Published var isLoading: Bool = false
    
    func createNewUser(
        currentView: Binding<CurrentView>,
        userVM: UserViewModel,
        alertMessageVM: AlertMessageViewModel
    ) async {
        errorEmailMessage = ""
        errorPasswordMessage = ""
        errorRetypePasswordMessage = ""
        isLoading = true
        
        guard handleEmptyEmail() else { return }
        guard handleMismatchPasswords() else { return }
        guard handlePasswordValidation() else { return }
        
        do {
            let authResult = try await FirebaseAuthService.shared.signUpUser(email: email, password: password)
            
            guard let userInsert = await setupUserInsert(authDataResult: authResult) else {
                handleSetupUserInsertError(alertMessageVM: alertMessageVM)
                return
            }
            
            try await userVM.saveNewUser(authId: authResult.user.uid, data: userInsert)
            
            await updateCurrentView(userVM: userVM, currentView: currentView)
            
        } catch let error as FirebaseSignUpError {
            handleSignUpError(error: error, alertMessageVM: alertMessageVM)
        } catch let error as FirebaseError {
            handleFirebaseError(error: error, alertMessageVM: alertMessageVM)
        } catch {
            print("Unknown error! \(error.localizedDescription)")
        }
    }
    
    private func handleEmptyEmail() -> Bool {
        guard !email.isEmpty else {
            errorEmailMessage = "Email is missing"
            isLoading = false
            return false
        }
        return true
    }
    
    private func handleMismatchPasswords() -> Bool {
        if password != retypePassword {
            errorPasswordMessage = "Passwords do not match"
            errorRetypePasswordMessage = "Passwords do not match"
            isLoading = false
            return false
        }
        return true
    }
    
    private func handlePasswordValidation() -> Bool {
        let passwordErrors = validatePassword(password)
        guard passwordErrors.isEmpty else {
            errorPasswordMessage = passwordErrors.joined(separator: "\n")
            errorRetypePasswordMessage = passwordErrors.joined(separator: "\n")
            isLoading = false
            return false
        }
        return true
    }
    
    /// Update currentView if the user successfully created
    private func updateCurrentView(userVM: UserViewModel, currentView: Binding<CurrentView>) async {
        
        await userVM.fetchCurrentUser(email: email)
        
        if let user = userVM.user {
            isLoading = false
            currentView.wrappedValue = user.userName.isEmpty ? .newUser : .content
        }
    }
    
    private func handleSetupUserInsertError(alertMessageVM: AlertMessageViewModel) {
        isLoading = false
        alertMessageVM.presentAlert(message: "Failed to setup user. Please try again", type: .error)
    }
    
    private func handleFirebaseError(error: FirebaseError, alertMessageVM: AlertMessageViewModel) {
        isLoading = false
        
        switch error {
        case .operationFailed(_):
            alertMessageVM.presentAlert(message: "Unable to sign up. Please try again", type: .error)
        case .encodingFailed:
            alertMessageVM.presentAlert(message: "Server failed. Please try again", type: .error)
        }
    }
    
    private func handleSignUpError(error: FirebaseSignUpError, alertMessageVM: AlertMessageViewModel) {
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
            alertMessageVM.presentAlert(message: "Server side error. Please try again", type: .error)
        case .networkError:
            alertMessageVM.presentAlert(message: "Not connected to the internet", type: .error)
        case .unknown:
            alertMessageVM.presentAlert(message: "Unknown error", type: .error)
        }
    }
    
    private func getFMCToken() async -> String? {
        do {
            let token = try await Messaging.messaging().token()
            return token
        } catch {
            print("Error fetching FCM registration token: \(error.localizedDescription)")
        }
        
        return nil
    }
    
    private func setupUserInsert(authDataResult: AuthDataResult) async -> User? {
        guard let email = authDataResult.user.email else { return nil }
        guard let registeredDate = authDataResult.user.metadata.creationDate else { return nil }
        var fmcToken: String?
        
        fmcToken = await getFMCToken()
        
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
    
    private func validatePassword(_ password: String) -> [String] {
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
