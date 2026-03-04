//
//  OnboardingCoordinatorTests.swift
//  OnboardingKitTests
//

import OnboardingKitCore
import XCTest
@testable import OnboardingKit

@MainActor
final class OnboardingCoordinatorTests: XCTestCase {

    func testNextStepSequence() {
        let sequence = TestSequence()
        let context = TestContext()
        XCTAssertEqual(sequence.nextStep(after: .welcome, context: context), .permissions)
        XCTAssertEqual(sequence.nextStep(after: .permissions, context: context), .location)
        XCTAssertEqual(sequence.nextStep(after: .location, context: context), .profile)
        XCTAssertEqual(sequence.nextStep(after: .profile, context: context), .preferences)
        XCTAssertEqual(sequence.nextStep(after: .preferences, context: context), .complete)
        XCTAssertNil(sequence.nextStep(after: .complete, context: context))
    }

    func testNextStepSkipsProfileWhenNeedsProfileFalse() {
        let sequence = TestSequence()
        var context = TestContext()
        context.needsProfile = false
        XCTAssertEqual(sequence.nextStep(after: .location, context: context), .preferences)
    }

    func testAdvanceUpdatesPath() async {
        let persistence = InMemoryOnboardingPersistence()
        let coordinator = OnboardingCoordinator(
            sequence: TestSequence(),
            initialContext: TestContext(),
            persistence: persistence,
            completionStep: .complete
        )
        XCTAssertEqual(coordinator.path.count, 0)
        await coordinator.advance(from: .welcome)
        XCTAssertEqual(coordinator.path.count, 1)
        XCTAssertFalse(coordinator.hasCompletedOnboarding)
    }

    func testHasSubflowReturnsFalseBeforeRegister() {
        let coordinator = OnboardingCoordinator(
            sequence: TestSequence(),
            initialContext: TestContext(),
            persistence: InMemoryOnboardingPersistence(),
            completionStep: .complete
        )
        XCTAssertFalse(coordinator.hasSubflow(for: .location))
    }

    func testHasSubflowReturnsTrueAfterRegister() {
        let coordinator = OnboardingCoordinator(
            sequence: TestSequence(),
            initialContext: TestContext(),
            persistence: InMemoryOnboardingPersistence(),
            completionStep: .complete
        )
        coordinator.register(TestSubflow())
        XCTAssertTrue(coordinator.hasSubflow(for: .location))
    }

    func testGetOrCreateSubflowCoordinatorReturnsNilWhenNoSubflowRegistered() {
        let coordinator = OnboardingCoordinator(
            sequence: TestSequence(),
            initialContext: TestContext(),
            persistence: InMemoryOnboardingPersistence(),
            completionStep: .complete
        )
        XCTAssertNil(coordinator.getOrCreateSubflowCoordinator(for: .location))
    }

    func testGetOrCreateSubflowCoordinatorCreatesAndReusesCoordinator() {
        let coordinator = OnboardingCoordinator(
            sequence: TestSequence(),
            initialContext: TestContext(),
            persistence: InMemoryOnboardingPersistence(),
            completionStep: .complete
        )
        coordinator.register(TestSubflow())
        let first = coordinator.getOrCreateSubflowCoordinator(for: .location) as? TestSubflowCoordinator
        let second = coordinator.getOrCreateSubflowCoordinator(for: .location) as? TestSubflowCoordinator
        XCTAssertNotNil(first)
        XCTAssertTrue(first === second)
    }

    func testFinishSubflowPopsStepAndAppendsNext() {
        let coordinator = OnboardingCoordinator(
            sequence: TestSequence(),
            initialContext: TestContext(),
            persistence: InMemoryOnboardingPersistence(),
            completionStep: .complete
        )
        coordinator.register(TestSubflow())
        _ = coordinator.getOrCreateSubflowCoordinator(for: .location)
        coordinator.path.append(TestStep.location)
        XCTAssertEqual(coordinator.path.count, 1)
        coordinator.finishSubflow(step: .location, next: .profile)
        XCTAssertEqual(coordinator.path.count, 1)
        XCTAssertNil(coordinator.subflowCoordinators[TestStep.location.stepId])
    }

    func testFinishSubflowClearsSubflowCoordinator() {
        let coordinator = OnboardingCoordinator(
            sequence: TestSequence(),
            initialContext: TestContext(),
            persistence: InMemoryOnboardingPersistence(),
            completionStep: .complete
        )
        coordinator.register(TestSubflow())
        _ = coordinator.getOrCreateSubflowCoordinator(for: .location)
        XCTAssertNotNil(coordinator.subflowCoordinators[TestStep.location.stepId])
        coordinator.path.append(TestStep.location)
        coordinator.finishSubflow(step: .location, next: .profile)
        XCTAssertNil(coordinator.subflowCoordinators[TestStep.location.stepId])
    }

    func testGoBackRemovesLastStep() {
        let coordinator = OnboardingCoordinator(
            sequence: TestSequence(),
            initialContext: TestContext(),
            persistence: InMemoryOnboardingPersistence(),
            completionStep: .complete
        )
        coordinator.path.append(TestStep.permissions)
        coordinator.path.append(TestStep.location)
        XCTAssertEqual(coordinator.path.count, 2)
        coordinator.goBack()
        XCTAssertEqual(coordinator.path.count, 1)
    }

    func testResetClearsPathAndPersistence() {
        let persistence = InMemoryOnboardingPersistence()
        persistence.markCompleted(stepId: TestStep.welcome.stepId)
        let coordinator = OnboardingCoordinator(
            sequence: TestSequence(),
            initialContext: TestContext(),
            persistence: persistence,
            completionStep: .complete
        )
        coordinator.path.append(TestStep.permissions)
        coordinator.reset()
        XCTAssertEqual(coordinator.path.count, 0)
        XCTAssertTrue(persistence.completedStepIds().isEmpty)
    }

    func testOnCompleteFiresWhenAdvancingFromCompletionStep() async {
        var didComplete = false
        let coordinator = OnboardingCoordinator(
            sequence: TestSequence(),
            initialContext: TestContext(),
            persistence: InMemoryOnboardingPersistence(),
            completionStep: .complete
        )
        coordinator.onComplete = { didComplete = true }
        await coordinator.advance(from: .complete)
        XCTAssertTrue(didComplete)
    }

    func testOrderedStepsReturnsDynamicSteps() {
        let coordinator = OnboardingCoordinator(
            sequence: TestSequenceWithConditionalSteps(),
            initialContext: TestContext(needsProfile: true),
            persistence: InMemoryOnboardingPersistence(),
            completionStep: .complete
        )
        let withProfile = coordinator.orderedSteps()
        XCTAssertEqual(withProfile.count, 6)
        coordinator.context = TestContext(needsProfile: false)
        let withoutProfile = coordinator.orderedSteps()
        XCTAssertEqual(withoutProfile.count, 5)
        XCTAssertFalse(withoutProfile.contains(.profile))
    }
}
