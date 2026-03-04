//
//  AppOnboardingTypes.swift
//  HighPerformanceComplexOnboarding
//
//  Step enum, shared state, and sequence for onboarding.
//

import Foundation
import OnboardingKit
import OnboardingKitCore

enum AppStep: String, OnboardingStep, CaseIterable {
    case welcome
    case location
    case quiz
    case notifications
    case complete
}

/// Shared state collected during onboarding. App owns this; coordinator holds a reference so steps can mutate it.
@Observable
final class AppOnboardingState {
    var userName: String = ""
    var pickedLatitude: Double?
    var pickedLongitude: Double?
    var locationName: String?
    var notificationsEnabled: Bool = false
    /// Question index (0..<12) → selected option index.
    var quizUserAnswers: [Int: Int] = [:]
}

struct AppSequence: OnboardingSequence {
    typealias Step = AppStep
    typealias Context = AppOnboardingState

    private static let steps: [AppStep] = [.welcome, .location, .quiz, .notifications, .complete]

    func steps(for context: AppOnboardingState) -> [AppStep] {
        Self.steps
    }

    func nextStep(after step: AppStep, context: AppOnboardingState) -> AppStep? {
        guard let i = Self.steps.firstIndex(of: step), i + 1 < Self.steps.count else { return nil }
        return Self.steps[i + 1]
    }
}
