//
//  PersistenceTests.swift
//  OnboardingKitTests
//

import OnboardingKitCore
import XCTest

final class PersistenceTests: XCTestCase {

    func testInMemoryMarkCompletedAndCompletedStepIds() {
        let p = InMemoryOnboardingPersistence()
        XCTAssertTrue(p.completedStepIds().isEmpty)
        p.markCompleted(stepId: "a")
        p.markCompleted(stepId: "b")
        XCTAssertEqual(Set(p.completedStepIds()), ["a", "b"])
    }

    func testInMemoryReset() {
        let p = InMemoryOnboardingPersistence()
        p.markCompleted(stepId: "a")
        p.reset()
        XCTAssertTrue(p.completedStepIds().isEmpty)
    }

    func testUserDefaultsMarkCompletedAndReset() {
        let p = UserDefaultsOnboardingPersistence(completedStepIdsKey: "test.onboarding.\(UUID().uuidString)")
        p.markCompleted(stepId: "x")
        XCTAssertTrue(p.completedStepIds().contains("x"))
        p.reset()
        XCTAssertFalse(p.completedStepIds().contains("x"))
    }

    func testInMemoryFactory() {
        let p: InMemoryOnboardingPersistence = .inMemory
        p.markCompleted(stepId: "f")
        XCTAssertEqual(p.completedStepIds(), ["f"])
    }

    func testUserDefaultsFactory() {
        let p = UserDefaultsOnboardingPersistence.userDefaults(completedStepIdsKey: "test.\(UUID().uuidString)")
        p.markCompleted(stepId: "y")
        p.reset()
        XCTAssertTrue(p.completedStepIds().isEmpty)
    }
}
