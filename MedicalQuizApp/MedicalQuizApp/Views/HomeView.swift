//
//  HomeView.swift
//  MedicalQuizApp
//
//  Created by Raiyan Sharif on 19/11/25.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var coordinator: AppCoordinator
    private let quizService = QuizService.shared
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Welcome Section
                    VStack(spacing: 8) {
                        Text("Welcome to Medical Quiz App!")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        if let user = AuthService.shared.getCurrentUser() {
                            Text("Signed in as: \(user.email)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.top)
                    
                    // Bangladesh Medical License Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Available Quizzes")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .padding(.horizontal)
                        
                        // Bangladesh Medical License Card
                        Button(action: {
                            let quiz = quizService.getBangladeshMedicalLicenseQuiz()
                            coordinator.navigateToQuiz(quiz)
                        }) {
                            HStack(spacing: 16) {
                                // Icon
                                ZStack {
                                    Circle()
                                        .fill(Color.blue.opacity(0.1))
                                        .frame(width: 60, height: 60)
                                    
                                    Image(systemName: "doc.text.fill")
                                        .font(.system(size: 28))
                                        .foregroundColor(.blue)
                                }
                                
                                // Content
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Bangladesh Medical License")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    Text("Practice quiz for medical license examination")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.leading)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal)
                    }
                    .padding(.top, 8)
                    
                    Spacer()
                    
                    // Sign Out Button
                    Button(action: {
                        do {
                            try AuthService.shared.signOut()
                            coordinator.navigateToAuth()
                        } catch {
                            print("Error signing out: \(error)")
                        }
                    }) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Sign Out")
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Home")
        }
    }
}

#Preview {
    HomeView(coordinator: AppCoordinator())
}

