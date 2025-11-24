//
//  QuizViewModel.swift
//  MedicalQuizApp
//
//  Created by Raiyan Sharif on 19/11/25.
//

import Foundation
import SwiftUI

@MainActor
class QuizViewModel: ObservableObject {
    @Published var quiz: Quiz
    @Published var currentQuestionIndex: Int = 0
    @Published var selectedAnswerIndex: Int?
    @Published var showResult: Bool = false
    @Published var score: Int = 0
    @Published var showExplanation: Bool = false
    @Published var isQuizCompleted: Bool = false
    
    private let quizService: QuizServiceProtocol
    
    var currentQuestion: Question {
        quiz.questions[currentQuestionIndex]
    }
    
    var progress: Double {
        Double(currentQuestionIndex + 1) / Double(quiz.questions.count)
    }
    
    var isLastQuestion: Bool {
        currentQuestionIndex == quiz.questions.count - 1
    }
    
    init(quiz: Quiz, quizService: QuizServiceProtocol = QuizService.shared) {
        self.quiz = quiz
        self.quizService = quizService
    }
    
    func selectAnswer(at index: Int) {
        guard !showResult else { return }
        selectedAnswerIndex = index
    }
    
    func submitAnswer() {
        guard let selectedIndex = selectedAnswerIndex else { return }
        
        showResult = true
        
        if selectedIndex == currentQuestion.correctAnswerIndex {
            score += 1
        }
    }
    
    func nextQuestion() {
        if isLastQuestion {
            isQuizCompleted = true
        } else {
            currentQuestionIndex += 1
            selectedAnswerIndex = nil
            showResult = false
            showExplanation = false
        }
    }
    
    func resetQuiz() {
        currentQuestionIndex = 0
        selectedAnswerIndex = nil
        showResult = false
        score = 0
        showExplanation = false
        isQuizCompleted = false
    }
}


