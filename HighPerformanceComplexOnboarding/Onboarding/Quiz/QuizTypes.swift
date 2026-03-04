//
//  QuizTypes.swift
//  HighPerformanceComplexOnboarding
//
//  Quiz question model and static list of 12 questions.
//

import Foundation

struct QuizQuestion {
    let id: Int
    let text: String
    let options: [String]
    /// 0-based index of the correct option.
    let correctOptionIndex: Int
}

enum QuizQuestions {
    static let all: [QuizQuestion] = [
        QuizQuestion(id: 0, text: "What is the capital of France?", options: ["London", "Paris", "Berlin", "Madrid"], correctOptionIndex: 1),
        QuizQuestion(id: 1, text: "How many continents are there?", options: ["5", "6", "7", "8"], correctOptionIndex: 2),
        QuizQuestion(id: 2, text: "Which planet is known as the Red Planet?", options: ["Venus", "Mars", "Jupiter", "Saturn"], correctOptionIndex: 1),
        QuizQuestion(id: 3, text: "What is 7 × 8?", options: ["54", "56", "58", "60"], correctOptionIndex: 1),
        QuizQuestion(id: 4, text: "Which ocean is the largest?", options: ["Atlantic", "Indian", "Arctic", "Pacific"], correctOptionIndex: 3),
        QuizQuestion(id: 5, text: "How many days are in a leap year?", options: ["364", "365", "366", "367"], correctOptionIndex: 2),
        QuizQuestion(id: 6, text: "What is the chemical symbol for gold?", options: ["Go", "Gd", "Au", "Ag"], correctOptionIndex: 2),
        QuizQuestion(id: 7, text: "Which country is home to the kangaroo?", options: ["South Africa", "India", "Australia", "Brazil"], correctOptionIndex: 2),
        QuizQuestion(id: 8, text: "How many sides does a hexagon have?", options: ["5", "6", "7", "8"], correctOptionIndex: 1),
        QuizQuestion(id: 9, text: "What is the largest mammal?", options: ["Elephant", "Blue whale", "Giraffe", "Polar bear"], correctOptionIndex: 1),
        QuizQuestion(id: 10, text: "In which year did World War II end?", options: ["1943", "1944", "1945", "1946"], correctOptionIndex: 2),
        QuizQuestion(id: 11, text: "What is the smallest prime number?", options: ["0", "1", "2", "3"], correctOptionIndex: 2),
    ]
}
