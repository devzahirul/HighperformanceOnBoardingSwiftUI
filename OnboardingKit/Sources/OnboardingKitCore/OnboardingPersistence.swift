//
//  OnboardingPersistence.swift
//  OnboardingKitCore
//
//  Persistence contract: store completed step IDs. No SwiftUI. Completion is determined by the coordinator.
//

import Foundation

/// Persistence contract for saving and restoring onboarding progress. Persist step IDs only; the coordinator owns completion logic.
public protocol OnboardingPersistence: Sendable {
    /// Mark a step as completed.
    func markCompleted(stepId: String)
    /// All completed step IDs (order may not match flow order; coordinator uses sequence to restore).
    func completedStepIds() -> [String]
    /// Clear all stored progress (e.g. for re-onboarding).
    func reset()
}
