//
//  HighPerformanceComplexOnboardingApp.swift
//  HighPerformanceComplexOnboarding
//

import SwiftUI
import OnboardingKit
import OnboardingKitCore

@main
struct HighPerformanceComplexOnboardingApp: App {
    private static let persistence = UserDefaultsOnboardingPersistence.userDefaults()

    @State private var showOnboarding = !Self.persistence.completedStepIds().contains(AppStep.complete.stepId)
    @State private var state = AppOnboardingState()

    var body: some Scene {
        WindowGroup {
            if showOnboarding {
                OnboardingFlow(
                    sequence: AppSequence(),
                    initialContext: state,
                    persistence: Self.persistence,
                    completionStep: .complete,
                    onComplete: { showOnboarding = false },
                    content: { step, coordinator in
                        OnboardingContentWrapper(step: step, coordinator: coordinator)
                    }
                )
            } else {
                HomeView(state: state, onResetOnboarding: {
                    Self.persistence.reset()
                    state.userName = ""
                    state.pickedLatitude = nil
                    state.pickedLongitude = nil
                    state.locationName = nil
                    state.notificationsEnabled = false
                    state.quizUserAnswers = [:]
                    showOnboarding = true
                })
            }
        }
    }
}
