//
//  SignUpView.swift
//  MedicalQuizApp
//
//  Created by Raiyan Sharif on 19/11/25.
//

import SwiftUI

struct SignUpView: View {
    @StateObject private var viewModel: SignUpViewModel
    @ObservedObject var coordinator: AuthCoordinator
    
    init(coordinator: AuthCoordinator) {
        self.coordinator = coordinator
        _viewModel = StateObject(wrappedValue: SignUpViewModel())
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "stethoscope")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("Create Account")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Sign up to get started")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 40)
                    .padding(.bottom, 20)
                    
                    // Form
                    VStack(spacing: 16) {
                        // Display Name Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Display Name (Optional)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            TextField("Enter your name", text: $viewModel.displayName)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                        
                        // Email Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            TextField("Enter your email", text: $viewModel.email)
                                .textFieldStyle(CustomTextFieldStyle())
                                .autocapitalization(.none)
                                .keyboardType(.emailAddress)
                        }
                        
                        // Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            SecureField("Enter your password", text: $viewModel.password)
                                .textFieldStyle(CustomTextFieldStyle())
                            
                            Text("Must be at least 6 characters")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        // Confirm Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Confirm Password")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            SecureField("Confirm your password", text: $viewModel.confirmPassword)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    // Error Message
                    if viewModel.showError, let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.horizontal, 24)
                    }
                    
                    // Sign Up Button
                    Button(action: {
                        Task {
                            await viewModel.signUp()
                            if viewModel.errorMessage == nil {
                                coordinator.navigateToHome()
                            }
                        }
                    }) {
                        HStack {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Sign Up")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(viewModel.isLoading ? Color.blue.opacity(0.6) : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(viewModel.isLoading)
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                    
                    // Sign In Link
                    HStack {
                        Text("Already have an account?")
                            .foregroundColor(.secondary)
                        
                        Button(action: {
                            coordinator.navigateToSignIn()
                        }) {
                            Text("Sign In")
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    SignUpView(coordinator: AuthCoordinator())
}


