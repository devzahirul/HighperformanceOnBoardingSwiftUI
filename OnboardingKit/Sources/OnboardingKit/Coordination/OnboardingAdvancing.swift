//
//  OnboardingAdvancing.swift
//  OnboardingKit
//
//  Protocol for advancing and going back. Use in ViewModels for testability; inject a mock in tests.
//

import Foundation
import OnboardingKitCore

/// Protocol for types that can advance or go back in the onboarding flow. Use in your ViewModels so tests can inject a mock.
@MainActor
public protocol OnboardingAdvancing<Step>: AnyObject {
    associatedtype Step: OnboardingStep

    /// Marks the given step complete and appends the next step to the path. Call from the main actor.
    func advance(from step: Step) async

    /// Pops the current step from the path (user or programmatic back).
    func goBack()
}
