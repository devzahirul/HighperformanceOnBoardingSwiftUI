//
//  QuizSubflow.swift
//  HighPerformanceComplexOnboarding
//
//  Subflow: 12 questions, one per screen; writes answers to state.quizUserAnswers.
//

import SwiftUI
import OnboardingKit
import OnboardingKitCore

struct QuizSubflow: OnboardingSubflow {
    typealias ParentStep = AppStep
    typealias SubflowCoordinator = QuizSubflowCoordinator
    typealias SubflowView = AnyView

    let state: AppOnboardingState

    var step: AppStep { .quiz }

    func makeCoordinator(parent: some OnboardingAdvancing<AppStep>) -> QuizSubflowCoordinator {
        let main = parent as? OnboardingCoordinator<AppSequence>
        let coord = QuizSubflowCoordinator()
        coord.parent = main
        coord.state = state
        return coord
    }

    @MainActor
    @ViewBuilder
    func content(coordinator: QuizSubflowCoordinator) -> AnyView {
        AnyView(QuizQuestionView(coordinator: coordinator))
    }
}
