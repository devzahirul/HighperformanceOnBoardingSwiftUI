//
//  OnboardingContentWrapper.swift
//  HighPerformanceComplexOnboarding
//
//  Wraps onboarding content: registers subflow once, ensures location coordinator is created before showing subflow view.
//

import SwiftUI
import OnboardingKit
import OnboardingKitCore

struct OnboardingContentWrapper: View {
    let step: AppStep
    let coordinator: OnboardingCoordinator<AppSequence>
    @State private var didRegisterSubflow = false
    @State private var locationReady = false
    @State private var quizReady = false

    var body: some View {
        Group {
            if step == .location {
                if locationReady, let subflowView = coordinator.subflowView(for: step) {
                    subflowView
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .onAppear {
                            ensureLocationSubflowReady()
                        }
                }
            } else if step == .quiz {
                if quizReady, let subflowView = coordinator.subflowView(for: step) {
                    subflowView
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .onAppear {
                            ensureQuizSubflowReady()
                        }
                }
            } else if let subflowView = coordinator.subflowView(for: step) {
                subflowView
            } else {
                switch step {
                case .welcome:
                    WelcomeStepView(step: step, coordinator: coordinator, state: coordinator.context)
                case .location:
                    EmptyView()
                case .quiz:
                    EmptyView()
                case .notifications:
                    NotificationsStepView(step: step, coordinator: coordinator, state: coordinator.context)
                case .complete:
                    CompletionStepView(step: step, coordinator: coordinator, state: coordinator.context)
                }
            }
        }
        .onAppear {
            if !didRegisterSubflow {
                if !coordinator.hasSubflow(for: .location) {
                    coordinator.register(LocationSubflow(state: coordinator.context))
                }
                if !coordinator.hasSubflow(for: .quiz) {
                    coordinator.register(QuizSubflow(state: coordinator.context))
                }
                didRegisterSubflow = true
            }
        }
    }

    private func ensureLocationSubflowReady() {
        if !didRegisterSubflow {
            coordinator.register(LocationSubflow(state: coordinator.context))
            if !coordinator.hasSubflow(for: .quiz) {
                coordinator.register(QuizSubflow(state: coordinator.context))
            }
            didRegisterSubflow = true
        }
        _ = coordinator.getOrCreateSubflowCoordinator(for: .location)
        locationReady = true
    }

    private func ensureQuizSubflowReady() {
        if !didRegisterSubflow {
            if !coordinator.hasSubflow(for: .location) {
                coordinator.register(LocationSubflow(state: coordinator.context))
            }
            coordinator.register(QuizSubflow(state: coordinator.context))
            didRegisterSubflow = true
        }
        _ = coordinator.getOrCreateSubflowCoordinator(for: .quiz)
        quizReady = true
    }
}
