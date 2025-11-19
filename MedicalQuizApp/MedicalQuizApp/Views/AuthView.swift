//
//  AuthView.swift
//  MedicalQuizApp
//
//  Created by Raiyan Sharif on 19/11/25.
//

import SwiftUI

struct AuthView: View {
    @ObservedObject var coordinator: AuthCoordinator
    
    var body: some View {
        Group {
            switch coordinator.currentRoute {
            case .signIn:
                SignInView(coordinator: coordinator)
            case .signUp:
                SignUpView(coordinator: coordinator)
            }
        }
    }
}

#Preview {
    AuthView(coordinator: AuthCoordinator())
}

