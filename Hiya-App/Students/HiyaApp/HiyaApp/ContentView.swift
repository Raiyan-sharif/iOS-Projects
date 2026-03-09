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
    
    var body: some View {
        VStack {
            switch largeLanguageModel.availability {
                case .available:
                Text("Large Language Model is available!")
            case .unavailable(.deviceNotEligible):
                Text("Large Language Model is unavailable because device is not eligible")
            case .unavailable(.appleIntelligenceNotEnabled):
                Text("Apple Inteligence is not available")
            case .unavailable(.modelNotReady):
                Text("Model is not Ready")
            case .unavailable(_):
                Text("AL model is not available reason unknown")
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
