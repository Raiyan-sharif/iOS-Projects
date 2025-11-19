//
//  AuthError.swift
//  MedicalQuizApp
//
//  Created by Raiyan Sharif on 19/11/25.
//

import Foundation

enum AuthError: LocalizedError {
    case invalidEmail
    case invalidPassword
    case passwordTooShort
    case passwordsDoNotMatch
    case emailAlreadyInUse
    case weakPassword
    case userNotFound
    case wrongPassword
    case networkError
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return "Please enter a valid email address"
        case .invalidPassword:
            return "Please enter a valid password"
        case .passwordTooShort:
            return "Password must be at least 6 characters"
        case .passwordsDoNotMatch:
            return "Passwords do not match"
        case .emailAlreadyInUse:
            return "This email is already registered"
        case .weakPassword:
            return "Password is too weak"
        case .userNotFound:
            return "No account found with this email"
        case .wrongPassword:
            return "Incorrect password"
        case .networkError:
            return "Network error. Please check your connection"
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}

