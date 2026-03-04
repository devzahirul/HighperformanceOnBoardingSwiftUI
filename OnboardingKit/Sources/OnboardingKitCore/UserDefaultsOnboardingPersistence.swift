//
//  UserDefaultsOnboardingPersistence.swift
//  OnboardingKitCore
//

import Foundation

/// UserDefaults-backed implementation of ``OnboardingPersistence``.
public final class UserDefaultsOnboardingPersistence: OnboardingPersistence, @unchecked Sendable {
    private let store: UserDefaults
    private let completedStepIdsKey: String

    public init(
        store: UserDefaults = .standard,
        completedStepIdsKey: String = "onboardingKit.completedStepIds"
    ) {
        self.store = store
        self.completedStepIdsKey = completedStepIdsKey
    }

    public func markCompleted(stepId: String) {
        var ids = completedStepIds()
        if !ids.contains(stepId) {
            ids.append(stepId)
            store.set(ids, forKey: completedStepIdsKey)
        }
    }

    public func completedStepIds() -> [String] {
        if let strings = store.array(forKey: completedStepIdsKey) as? [String] {
            return strings
        }
        if let ints = store.array(forKey: "onboardingKit.completedStepIndices") as? [Int] {
            let migrated = ints.map { String($0) }
            store.set(migrated, forKey: completedStepIdsKey)
            return migrated
        }
        return []
    }

    public func reset() {
        store.removeObject(forKey: completedStepIdsKey)
    }
}

// MARK: - Factory

extension OnboardingPersistence where Self == UserDefaultsOnboardingPersistence {
    /// UserDefaults-backed persistence. Completion is determined by the coordinator, not persistence.
    public static func userDefaults(
        store: UserDefaults = .standard,
        completedStepIdsKey: String = "onboardingKit.completedStepIds"
    ) -> UserDefaultsOnboardingPersistence {
        UserDefaultsOnboardingPersistence(store: store, completedStepIdsKey: completedStepIdsKey)
    }
}

