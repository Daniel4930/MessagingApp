//
//  FirebaseAuthError.swift
//  MessagingApp
//
//  Created by Daniel Le on 12/6/25.
//

import Foundation

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

enum FirebaseSignOutError: Error {
    case keychainError
    case unknown
}
