//
//  AuthCoordinator.swift
//  MedicalQuizApp
//
//  Created by Raiyan Sharif on 19/11/25.
//

import SwiftUI

enum AuthRoute {
    case signIn
    case signUp
}

class AuthCoordinator: ObservableObject {
    @Published var currentRoute: AuthRoute = .signIn
    
    weak var appCoordinator: AppCoordinator?
    
    init(appCoordinator: AppCoordinator? = nil) {
        self.appCoordinator = appCoordinator
    }
    
    func navigateToSignIn() {
        currentRoute = .signIn
    }
    
    func navigateToSignUp() {
        currentRoute = .signUp
    }
    
    func navigateToHome() {
        appCoordinator?.navigateToHome()
    }
}


