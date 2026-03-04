//
//  OnboardingStep.swift
//  OnboardingKitCore
//
//  A type that identifies a step in the onboarding flow. Use with OnboardingSequence for full type safety.
//

import Foundation

/// A step in the onboarding flow. Conform your enum (e.g. `enum MyStep: String, OnboardingStep`) for compile-time safety.
public protocol OnboardingStep: Hashable, Codable, Sendable {
    /// String identifier used for persistence. Must be unique within the flow.
    var stepId: String { get }
}

extension OnboardingStep where Self: RawRepresentable, RawValue == String {
    /// Default: use the enum's raw value as stepId. No boilerplate needed.
    public var stepId: String { rawValue }
}
