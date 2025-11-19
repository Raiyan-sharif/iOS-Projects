//
//  AppCoordinator.swift
//  MedicalQuizApp
//
//  Created by Raiyan Sharif on 19/11/25.
//

import SwiftUI

enum AppRoute {
    case auth
    case home
    case quiz(Quiz)
}

class AppCoordinator: ObservableObject {
    @Published var currentRoute: AppRoute = .auth
    
    private let authService: AuthServiceProtocol
    
    init(authService: AuthServiceProtocol = AuthService.shared) {
        self.authService = authService
        checkAuthenticationStatus()
    }
    
    func checkAuthenticationStatus() {
        if authService.getCurrentUser() != nil {
            currentRoute = .home
        } else {
            currentRoute = .auth
        }
    }
    
    func navigateToHome() {
        currentRoute = .home
    }
    
    func navigateToAuth() {
        currentRoute = .auth
    }
    
    func navigateToQuiz(_ quiz: Quiz) {
        currentRoute = .quiz(quiz)
    }
}

