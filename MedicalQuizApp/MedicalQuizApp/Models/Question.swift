//
//  Question.swift
//  MedicalQuizApp
//
//  Created by Raiyan Sharif on 19/11/25.
//

import Foundation

struct Question: Identifiable, Codable {
    let id: String
    let text: String
    let options: [String]
    let correctAnswerIndex: Int
    let explanation: String?
    
    init(id: String = UUID().uuidString, text: String, options: [String], correctAnswerIndex: Int, explanation: String? = nil) {
        self.id = id
        self.text = text
        self.options = options
        self.correctAnswerIndex = correctAnswerIndex
        self.explanation = explanation
    }
}

struct Quiz: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let questions: [Question]
    
    init(id: String = UUID().uuidString, title: String, description: String, questions: [Question]) {
        self.id = id
        self.title = title
        self.description = description
        self.questions = questions
    }
}


