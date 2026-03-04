//
//  InMemoryOnboardingPersistence.swift
//  OnboardingKitCore
//
//  In-memory persistence for tests and previews. Not for production.
//

import Foundation

/// In-memory implementation of ``OnboardingPersistence``. Use in tests or SwiftUI previews.
public final class InMemoryOnboardingPersistence: OnboardingPersistence, @unchecked Sendable {
    private var completedIds: [String] = []

    public init() {}

    public func markCompleted(stepId: String) {
        if !completedIds.contains(stepId) {
            completedIds.append(stepId)
        }
    }

    public func completedStepIds() -> [String] {
        completedIds
    }

    public func reset() {
        completedIds.removeAll()
    }
}

extension OnboardingPersistence where Self == InMemoryOnboardingPersistence {
    /// In-memory persistence for tests and previews.
    public static var inMemory: InMemoryOnboardingPersistence {
        InMemoryOnboardingPersistence()
    }
}
