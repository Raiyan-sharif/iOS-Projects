//
//  QuizService.swift
//  MedicalQuizApp
//
//  Created by Raiyan Sharif on 19/11/25.
//

import Foundation

protocol QuizServiceProtocol {
    func getBangladeshMedicalLicenseQuiz() -> Quiz
}

class QuizService: QuizServiceProtocol {
    static let shared = QuizService()
    
    private init() {}
    
    func getBangladeshMedicalLicenseQuiz() -> Quiz {
        // Sample questions for Bangladesh Medical License
        // In a real app, these would come from a database or API
        let questions = [
            Question(
                text: "What is the normal range for adult blood pressure?",
                options: [
                    "120/80 mmHg",
                    "140/90 mmHg",
                    "100/60 mmHg",
                    "160/100 mmHg"
                ],
                correctAnswerIndex: 0,
                explanation: "Normal adult blood pressure is typically around 120/80 mmHg."
            ),
            Question(
                text: "Which of the following is a symptom of diabetes mellitus?",
                options: [
                    "Polyuria",
                    "Bradycardia",
                    "Hypotension",
                    "Hypothermia"
                ],
                correctAnswerIndex: 0,
                explanation: "Polyuria (excessive urination) is a classic symptom of diabetes mellitus."
            ),
            Question(
                text: "What is the first-line treatment for hypertension?",
                options: [
                    "ACE inhibitors",
                    "Antibiotics",
                    "Antihistamines",
                    "Antidepressants"
                ],
                correctAnswerIndex: 0,
                explanation: "ACE inhibitors are commonly used as first-line treatment for hypertension."
            ),
            Question(
                text: "Which organ is primarily responsible for filtering blood?",
                options: [
                    "Kidney",
                    "Liver",
                    "Heart",
                    "Lungs"
                ],
                correctAnswerIndex: 0,
                explanation: "The kidneys are responsible for filtering waste products from the blood."
            ),
            Question(
                text: "What is the normal heart rate for adults at rest?",
                options: [
                    "60-100 bpm",
                    "40-60 bpm",
                    "100-120 bpm",
                    "120-140 bpm"
                ],
                correctAnswerIndex: 0,
                explanation: "Normal resting heart rate for adults is typically 60-100 beats per minute."
            )
        ]
        
        return Quiz(
            title: "Bangladesh Medical License Quiz",
            description: "Test your knowledge for the Bangladesh Medical License examination",
            questions: questions
        )
    }
}

