//
//  OnboardingSequence.swift
//  OnboardingKitCore
//
//  Step order and branching. Your app implements this; the engine calls it with your Step and Context types.
//

import Foundation

/// Defines the order and branching of onboarding steps. Generic over your step and context types.
public protocol OnboardingSequence: Sendable {
    associatedtype Step: OnboardingStep
    associatedtype Context

    /// Returns the next step after the given one, or nil if the flow ends.
    func nextStep(after step: Step, context: Context) -> Step?

    /// Ordered list of steps for progress and initial step. Receives context so the list can be dynamic (e.g. skip a step).
    func steps(for context: Context) -> [Step]
}
