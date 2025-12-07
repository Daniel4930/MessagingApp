//
//  FirebaseAuthService.swift
//  MessagingApp
//
//  Created by Daniel Le on 8/16/25.
//

import FirebaseAuth

class FirebaseAuthService {
    static let shared = FirebaseAuthService()
    
    func deleteUserAccount() async throws {
        guard let user = Auth.auth().currentUser else {
            print("Failed to get current user information")
            return
        }
        
        try await user.delete()
    }
    
    func reauthenticateUser(password: String) async throws {
        guard let user = Auth.auth().currentUser, let email = user.email else {
            print("Failed to get current user information")
            return
        }
        
        // Reauthenticate to make sure this action is from the legitimate user
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        try await user.reauthenticate(with: credential)
    }
    
    func signUpUser(email: String, password: String) async throws -> AuthDataResult {
        do {
            let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
            return authResult
        } catch let error as NSError {
            if let authError = AuthErrorCode(rawValue: error.code) {
                switch authError {
                case .invalidEmail:
                    throw FirebaseSignUpError.invalidEmail
                case .emailAlreadyInUse:
                    throw FirebaseSignUpError.emailAlreadyInUse
                case .weakPassword:
                    throw FirebaseSignUpError.weakPassword
                case .networkError:
                    throw FirebaseSignUpError.networkError
                case .operationNotAllowed:
                    throw FirebaseSignUpError.operationNotAllowed
                default:
                    print("Failed to sign up with unknown error: \(error.localizedDescription)")
                    throw FirebaseSignUpError.unknown
                }
            } else {
                print("Failed to sign up with unknown error: \(error.localizedDescription)")
                throw FirebaseSignUpError.unknown
            }
        }
    }
    
    func signInAUser(email: String, password: String) async throws -> AuthDataResult {
        do {
            let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
            return authResult
        } catch let error as NSError {
            if let authError = AuthErrorCode(rawValue: error.code) {
                switch authError {
                case .invalidCredential:
                    throw FirebaseSignInError.invalidCredential
                case .invalidEmail:
                    throw FirebaseSignInError.invalidEmail
                case .userDisabled:
                    throw FirebaseSignInError.userDisabled
                case .operationNotAllowed:
                    throw FirebaseSignInError.operationNotAllowed
                case .wrongPassword:
                    throw FirebaseSignInError.wrongPassword
                case .networkError:
                    throw FirebaseSignInError.networkError
                default:
                    print("Failed to sign in with unknown error: \(error.localizedDescription)")
                    throw FirebaseSignInError.unknown
                }
            } else {
                print("Failed to sign in with unknown error: \(error.localizedDescription)")
                throw FirebaseSignInError.unknown
            }
        }
    }
    
    func isSignIn(email: String) -> Bool {
        return Auth.auth().currentUser != nil
    }
    
    func signOut() throws {
        do {
            try Auth.auth().signOut()
        } catch let error as NSError {
            if let authError = AuthErrorCode(rawValue: error.code) {
                switch authError {
                case .keychainError:
                    throw FirebaseSignOutError.keychainError
                default:
                    throw FirebaseSignOutError.unknown
                }
            } else {
                throw FirebaseSignOutError.unknown
            }
        }
    }
    
    func sendResetPasswordLink(email: String, completion: @escaping (FirebaseResetPasswordError?) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error as NSError? {
                if let authError = AuthErrorCode(rawValue: error.code) {
                    switch authError {
                    case .invalidRecipientEmail, .invalidEmail:
                        completion(FirebaseResetPasswordError.invalidEmail)
                    case .networkError:
                        completion(FirebaseResetPasswordError.networkError)
                    default:
                        print("Failed to send reset password link with unknown error: \(error.localizedDescription)")
                        completion(FirebaseResetPasswordError.unknown)
                    }
                }
                return
            }
            completion(nil)
        }
    }
}
