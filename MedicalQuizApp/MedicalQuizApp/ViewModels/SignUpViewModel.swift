//
//  SignUpViewModel.swift
//  MedicalQuizApp
//
//  Created by Raiyan Sharif on 19/11/25.
//

import Foundation
import SwiftUI

@MainActor
class SignUpViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var displayName: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showError: Bool = false
    
    private let authService: AuthServiceProtocol
    
    init(authService: AuthServiceProtocol = AuthService.shared) {
        self.authService = authService
    }
    
    func signUp() async {
        guard validateInputs() else { return }
        
        isLoading = true
        errorMessage = nil
        showError = false
        
        do {
            _ = try await authService.signUp(
                email: email,
                password: password,
                displayName: displayName.isEmpty ? nil : displayName
            )
            // Navigation will be handled by coordinator
        } catch let error as AuthError {
            errorMessage = error.errorDescription
            showError = true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        
        isLoading = false
    }
    
    private func validateInputs() -> Bool {
        if email.isEmpty {
            errorMessage = AuthError.invalidEmail.errorDescription
            showError = true
            return false
        }
        
        if !isValidEmail(email) {
            errorMessage = AuthError.invalidEmail.errorDescription
            showError = true
            return false
        }
        
        if password.isEmpty {
            errorMessage = AuthError.invalidPassword.errorDescription
            showError = true
            return false
        }
        
        if password.count < 6 {
            errorMessage = AuthError.passwordTooShort.errorDescription
            showError = true
            return false
        }
        
        if password != confirmPassword {
            errorMessage = AuthError.passwordsDoNotMatch.errorDescription
            showError = true
            return false
        }
        
        return true
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}


