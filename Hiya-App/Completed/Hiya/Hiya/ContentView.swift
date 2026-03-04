//
//  CREDO ACADEMY ♥ DESIGN AND CODE
//  SwiftUI • SwiftData • Apple Intelligence • UI/UX Design • Apple AR
//  https://credo.academy 
//  Created by Robert Petras
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
            Text("Tap the button to get a fun response")
              .foregroundStyle(.tertiary)
              .multilineTextAlignment(.center)
              .font(.title)
          }
        } else {
          Text(response)
            .multilineTextAlignment(.center)
            .font(.largeTitle)
            .bold()
        }
      case .unavailable(.deviceNotEligible):
        Text("Your device isn't eligible for Apple Intelligence.")
      case .unavailable(.appleIntelligenceNotEnabled):
        Text("Please enable Apple Intelligence in Settings.")
      case .unavailable(.modelNotReady):
        Text("The AI model is not ready.")
      case .unavailable(_):
        Text("The AI feature is unavailable for an unkown reason.")
      }
      
      Spacer()
      
      Button {
        Task {
          isLoading = true
          defer { isLoading = false }
          
          let prompt = "Say hi in a fun way."
          
          do {
            let replay = try await session.respond(to: prompt)
            response = replay.content
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
