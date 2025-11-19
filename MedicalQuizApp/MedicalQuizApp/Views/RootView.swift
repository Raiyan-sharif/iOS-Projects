//
//  RootView.swift
//  MedicalQuizApp
//
//  Created by Raiyan Sharif on 19/11/25.
//

import SwiftUI

struct RootView: View {
    @StateObject private var appCoordinator = AppCoordinator()
    @StateObject private var authCoordinator = AuthCoordinator()
    
    var body: some View {
        Group {
            switch appCoordinator.currentRoute {
            case .auth:
                AuthView(coordinator: authCoordinator)
                    .onAppear {
                        authCoordinator.appCoordinator = appCoordinator
                    }
            case .home:
                HomeView(coordinator: appCoordinator)
            case .quiz(let quiz):
                QuizView(quiz: quiz, coordinator: appCoordinator)
            }
        }
    }
}

#Preview {
    RootView()
}

