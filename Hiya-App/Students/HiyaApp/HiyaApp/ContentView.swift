//
//  ContentView.swift
//  HiyaApp
//
//  Created by Raiyan Sharif on 4/3/26.
//

import SwiftUI
import FoundationModels

struct ContentView: View {
    private var largeLanguageModel = SystemLanguageModel.default
    private var session = LanguageModelSession()
    @State private var response: String = ""
    @State private var isLoading: Bool = false
    
    var body: some View {
        VStack {
            Spacer()
            switch largeLanguageModel.availability {
                case .available:
                if response.isEmpty {
                    if isLoading {
                        ProgressView()
                    } else {
                        Text("Tap the button to get a response")
                            .foregroundStyle(.tertiary)
                            .multilineTextAlignment(.center)
                            .font(.title)
                        
                    }
                    
                } else {
                    
                    
                    Text("\(response)")
                        .multilineTextAlignment(.center)
                        .font(.largeTitle)
                        .bold()
                }
            case .unavailable(.deviceNotEligible):
                Text("Large Language Model is unavailable because device is not eligible")
            case .unavailable(.appleIntelligenceNotEnabled):
                Text("Apple Inteligence is not available")
            case .unavailable(.modelNotReady):
                Text("Model is not Ready")
            case .unavailable(_):
                Text("AL model is not available reason unknown")
            }
            
            Spacer()
            
            Button{
                Task {
                    isLoading = true
                    defer {
                        isLoading = false
                    }
                    let prompt = "Hello, how are you today?"
                    do{
                        let reply = try await session.respond(to: prompt)
                        response = reply.content
                    } catch {
                        response = "Failed to get response: \(error.localizedDescription)"
                    }
                }
                
            } label: {
                Text("Welcome")
                    .font(.largeTitle)
                    .padding()
            }
            .buttonStyle(.borderedProminent)
            .buttonSizing(.flexible)
            .glassEffect(.regular.interactive())
        }
        .padding()
        .tint(.purple)
    }
}

#Preview {
    ContentView()
}
