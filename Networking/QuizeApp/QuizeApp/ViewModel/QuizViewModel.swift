//
//  QuizViewModel.swift
//  QuizeApp
//
//  Created by Raiyan Sharif on 18/11/25.
//

import Foundation
import Combine

class QuizViewModel: ObservableObject {
    @Published var questions: [Result] = []            // raw decoded results
    @Published var questionStrings: [String] = []      // just the question texts (decoded)

    init() {
        fetchData()
    }

    func fetchData() {
        let urlString = "https://opentdb.com/api.php?amount=10&encode=url3986"
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Network error:", error)
                return
            }
            guard let data = data else {
                print("No data returned from request.")
                return
            }

            do {
                let decoder = JSONDecoder()
                let quizModel = try decoder.decode(QuizModel.self, from: data)
                DispatchQueue.main.async {
                    self.handleFetchedData(quizModel)
                }
            } catch {
                print("Decoding error:", error)
                // You can print response as string for debugging:
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Response string:", jsonString)
                }
            }
        }.resume()
    }

    // MARK: - Process fetched data
    func handleFetchedData(_ quizModel: QuizModel) {
        // Assign raw results
        self.questions = quizModel.results

        // Extract and decode the question strings (because API returned url-encoded text)
        self.questionStrings = quizModel.results.map { result in
            // attempt percent-decoding; fallback to original if nil
            return result.question.removingPercentEncoding ?? result.question
        }
    }
}

