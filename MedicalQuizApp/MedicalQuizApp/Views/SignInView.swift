//
//  SignInView.swift
//  MedicalQuizApp
//
//  Created by Raiyan Sharif on 19/11/25.
//

import SwiftUI

struct SignInView: View {
    @StateObject private var viewModel: SignInViewModel
    @ObservedObject var coordinator: AuthCoordinator
    
    init(coordinator: AuthCoordinator) {
        self.coordinator = coordinator
        _viewModel = StateObject(wrappedValue: SignInViewModel())
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "stethoscope")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Medical Quiz App")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Sign in to continue")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 40)
                .padding(.bottom, 20)
                
                // Form
                VStack(spacing: 16) {
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
                
                // Sign In Button
                Button(action: {
                    Task {
                        await viewModel.signIn()
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
                            Text("Sign In")
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
                
                // Sign Up Link
                HStack {
                    Text("Don't have an account?")
                        .foregroundColor(.secondary)
                    
                    Button(action: {
                        coordinator.navigateToSignUp()
                    }) {
                        Text("Sign Up")
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.top, 8)
                
                Spacer()
            }
            .navigationBarHidden(true)
        }
    }
}

// Custom TextField Style
struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
    }
}

#Preview {
    SignInView(coordinator: AuthCoordinator())
}


