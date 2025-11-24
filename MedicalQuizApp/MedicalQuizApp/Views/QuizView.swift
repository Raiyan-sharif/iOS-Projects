//
//  QuizView.swift
//  MedicalQuizApp
//
//  Created by Raiyan Sharif on 19/11/25.
//

import SwiftUI

struct QuizView: View {
    @StateObject private var viewModel: QuizViewModel
    @ObservedObject var coordinator: AppCoordinator
    
    init(quiz: Quiz, coordinator: AppCoordinator) {
        self.coordinator = coordinator
        _viewModel = StateObject(wrappedValue: QuizViewModel(quiz: quiz))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isQuizCompleted {
                    QuizResultView(viewModel: viewModel, coordinator: coordinator)
                } else {
                    quizContentView
                }
            }
            .navigationTitle(viewModel.quiz.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        coordinator.navigateToHome()
                    }
                }
            }
        }
    }
    
    private var quizContentView: some View {
        VStack(spacing: 20) {
            // Progress Bar
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Question \(viewModel.currentQuestionIndex + 1) of \(viewModel.quiz.questions.count)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("Score: \(viewModel.score)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                
                ProgressView(value: viewModel.progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
            }
            .padding(.horizontal)
            .padding(.top)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Question
                    Text(viewModel.currentQuestion.text)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.horizontal)
                    
                    // Answer Options
                    VStack(spacing: 12) {
                        ForEach(Array(viewModel.currentQuestion.options.enumerated()), id: \.offset) { index, option in
                            AnswerOptionView(
                                option: option,
                                index: index,
                                isSelected: viewModel.selectedAnswerIndex == index,
                                isCorrect: viewModel.showResult && index == viewModel.currentQuestion.correctAnswerIndex,
                                isWrong: viewModel.showResult && viewModel.selectedAnswerIndex == index && index != viewModel.currentQuestion.correctAnswerIndex,
                                isDisabled: viewModel.showResult
                            ) {
                                viewModel.selectAnswer(at: index)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Explanation
                    if viewModel.showResult, let explanation = viewModel.currentQuestion.explanation {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Explanation")
                                .font(.headline)
                                .foregroundColor(.blue)
                            
                            Text(explanation)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    
                    // Next/Submit Button
                    Button(action: {
                        if viewModel.showResult {
                            viewModel.nextQuestion()
                        } else {
                            viewModel.submitAnswer()
                        }
                    }) {
                        HStack {
                            Text(viewModel.showResult ? (viewModel.isLastQuestion ? "Finish Quiz" : "Next Question") : "Submit Answer")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(viewModel.selectedAnswerIndex == nil ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(viewModel.selectedAnswerIndex == nil)
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
            }
        }
    }
}

struct AnswerOptionView: View {
    let option: String
    let index: Int
    let isSelected: Bool
    let isCorrect: Bool
    let isWrong: Bool
    let isDisabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(option)
                    .foregroundColor(textColor)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                if isCorrect {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                } else if isWrong {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                } else if isSelected {
                    Image(systemName: "circle.fill")
                        .foregroundColor(.blue)
                } else {
                    Image(systemName: "circle")
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(backgroundColor)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: isSelected ? 2 : 1)
            )
        }
        .disabled(isDisabled)
    }
    
    private var backgroundColor: Color {
        if isCorrect {
            return Color.green.opacity(0.1)
        } else if isWrong {
            return Color.red.opacity(0.1)
        } else if isSelected {
            return Color.blue.opacity(0.1)
        } else {
            return Color(.systemGray6)
        }
    }
    
    private var borderColor: Color {
        if isCorrect {
            return Color.green
        } else if isWrong {
            return Color.red
        } else if isSelected {
            return Color.blue
        } else {
            return Color(.systemGray4)
        }
    }
    
    private var textColor: Color {
        if isCorrect || isWrong {
            return .primary
        } else {
            return .primary
        }
    }
}

struct QuizResultView: View {
    @ObservedObject var viewModel: QuizViewModel
    @ObservedObject var coordinator: AppCoordinator
    
    var scorePercentage: Int {
        guard viewModel.quiz.questions.count > 0 else { return 0 }
        return Int((Double(viewModel.score) / Double(viewModel.quiz.questions.count)) * 100)
    }
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Result Icon
            Image(systemName: scorePercentage >= 70 ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(scorePercentage >= 70 ? .green : .orange)
            
            // Score
            Text("Your Score")
                .font(.title2)
                .foregroundColor(.secondary)
            
            Text("\(viewModel.score) / \(viewModel.quiz.questions.count)")
                .font(.system(size: 48, weight: .bold))
            
            Text("\(scorePercentage)%")
                .font(.title)
                .foregroundColor(scorePercentage >= 70 ? .green : .orange)
            
            // Message
            Text(scorePercentage >= 70 ? "Excellent! You passed!" : "Keep practicing to improve!")
                .font(.headline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
            
            // Buttons
            VStack(spacing: 12) {
                Button(action: {
                    viewModel.resetQuiz()
                }) {
                    Text("Retake Quiz")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                
                Button(action: {
                    coordinator.navigateToHome()
                }) {
                    Text("Back to Home")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color(.systemGray5))
                        .foregroundColor(.primary)
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 40)
        }
    }
}

#Preview {
    let quiz = QuizService.shared.getBangladeshMedicalLicenseQuiz()
    QuizView(quiz: quiz, coordinator: AppCoordinator())
}


