//
//  FirebaseAuthService.swift
//  MessagingApp
//
//  Created by Daniel Le on 8/16/25.
//

import FirebaseAuth

enum FirebaseSignUpError: Error {
    case invalidEmail
    case emailAlreadyInUse
    case weakPassword
    case operationNotAllowed
    case networkError
    case unknown
}

enum FirebaseSignInError: Error {
    case wrongPassword
    case invalidEmail
    case userDisabled
    case networkError
    case operationNotAllowed
    case invalidCredential
    case unknown
}

enum FirebaseResetPasswordError: Error {
    case invalidEmail
    case networkError
    case unknown
}

class FirebaseAuthService {
    static let shared = FirebaseAuthService()
    
    func signUpUser(email: String, password: String, completion: @escaping (Result<AuthDataResult, FirebaseSignUpError>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error as NSError? {                
                if let authError = AuthErrorCode(rawValue: error.code) {
                    switch authError {
                    case .invalidEmail:
                        completion(.failure(.invalidEmail))
                    case .emailAlreadyInUse:
                        completion(.failure(.emailAlreadyInUse))
                    case .weakPassword:
                        completion(.failure(.weakPassword))
                    case .networkError:
                        completion(.failure(.networkError))
                    case .operationNotAllowed:
                        completion(.failure(.operationNotAllowed))
                    default:
                        print("Failed to sign up with unknown error: \(error.localizedDescription)")
                        completion(.failure(.unknown))
                    }
                } else {
                    print("Failed to sign up with unknown error: \(error.localizedDescription)")
                    completion(.failure(.unknown))
                }
                return
            }
            if let authResult = authResult {
                completion(.success(authResult))
            }
        }
    }
    
    func signInAUser(email: String, password: String, completion: @escaping (Result<AuthDataResult, FirebaseSignInError>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error as NSError? {
                if let authError = AuthErrorCode(rawValue: error.code) {
                    switch authError {
                    case .invalidCredential:
                        completion(.failure(.invalidCredential))
                    case .invalidEmail:
                        completion(.failure(.invalidEmail))
                    case .userDisabled:
                        completion(.failure(.userDisabled))
                    case .operationNotAllowed:
                        completion(.failure(.operationNotAllowed))
                    case .wrongPassword:
                        completion(.failure(.wrongPassword))
                    case .networkError:
                        completion(.failure(.networkError))
                    default:
                        print("Failed to sign in with unknown error: \(error.localizedDescription)")
                        completion(.failure(.unknown))
                    }
                } else {
                    print("Failed to sign in with unknown error: \(error.localizedDescription)")
                    completion(.failure(.unknown))
                }
                return
            }
            if let authResult = authResult {
                completion(.success(authResult))
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
