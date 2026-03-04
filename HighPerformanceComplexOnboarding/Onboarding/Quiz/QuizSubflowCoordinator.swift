//
//  QuizSubflowCoordinator.swift
//  HighPerformanceComplexOnboarding
//

import Foundation
import OnboardingKit
import OnboardingKitCore

@Observable
@MainActor
final class QuizSubflowCoordinator {
    var currentQuestionIndex: Int = 0
    weak var parent: OnboardingCoordinator<AppSequence>?
    weak var state: AppOnboardingState?

    private static let totalQuestions = 12

    var currentQuestion: QuizQuestion? {
        guard currentQuestionIndex >= 0, currentQuestionIndex < QuizQuestions.all.count else { return nil }
        return QuizQuestions.all[currentQuestionIndex]
    }

    var isLastQuestion: Bool {
        currentQuestionIndex >= Self.totalQuestions - 1
    }

    var progressText: String {
        "Question \(currentQuestionIndex + 1) of \(Self.totalQuestions)"
    }

    func selectOption(_ optionIndex: Int) {
        state?.quizUserAnswers[currentQuestionIndex] = optionIndex
    }

    func goNext() {
        if isLastQuestion {
            parent?.finishSubflow(step: .quiz, next: .notifications)
        } else {
            currentQuestionIndex += 1
        }
    }

    func goBack() {
        if currentQuestionIndex > 0 {
            currentQuestionIndex -= 1
        }
    }
}
