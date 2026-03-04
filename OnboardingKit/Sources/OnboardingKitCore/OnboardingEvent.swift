//
//  OnboardingEvent.swift
//  OnboardingKitCore
//
//  Lifecycle events for analytics, logging, and validation hooks.
//

import Foundation

/// Events emitted by the onboarding flow. Subscribe via the coordinator's `onEvent` to log analytics or run validation.
public enum OnboardingEvent<Step: OnboardingStep>: Sendable {
    /// Fired before advancing from one step to the next.
    case willAdvance(from: Step, to: Step)
    /// Fired after the path has been updated to the next step.
    case didAdvance(from: Step, to: Step)
    /// Fired when the user (or app) goes back. `to` is the step we're returning to, or nil if popping to root.
    case willGoBack(from: Step, to: Step?)
    /// Fired when the user reaches the completion step and onboarding finishes.
    case didComplete(step: Step)
    /// Fired when onboarding state is reset (e.g. for re-onboarding).
    case didReset
}
