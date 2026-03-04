//
//  OnboardingIntegrationTests.swift
//  OnboardingKitTests
//

import OnboardingKitCore
import XCTest
@testable import OnboardingKit

@MainActor
final class OnboardingIntegrationTests: XCTestCase {

    func testFullFlowWithSubflowsAdvancesAndPersists() async {
        let persistence = InMemoryOnboardingPersistence()
        let coordinator = OnboardingCoordinator(
            sequence: TestSequence(),
            initialContext: TestContext(),
            persistence: persistence,
            completionStep: .complete
        )
        coordinator.register(TestSubflow())

        XCTAssertTrue(coordinator.hasSubflow(for: .location))
        XCTAssertEqual(coordinator.path.count, 0)

        await coordinator.advance(from: .welcome)
        XCTAssertEqual(coordinator.path.count, 1)

        await coordinator.advance(from: .permissions)
        XCTAssertEqual(coordinator.path.count, 2)

        coordinator.finishSubflow(step: .location, next: .profile)
        XCTAssertEqual(coordinator.path.count, 2)
        XCTAssertNil(coordinator.subflowCoordinators[TestStep.location.stepId])

        await coordinator.advance(from: .profile)
        await coordinator.advance(from: .preferences)
        await coordinator.advance(from: .complete)

        XCTAssertTrue(coordinator.hasCompletedOnboarding)
    }

    func testRestoredPathAfterPersistence() {
        let persistence = InMemoryOnboardingPersistence()
        persistence.markCompleted(stepId: TestStep.welcome.stepId)
        persistence.markCompleted(stepId: TestStep.permissions.stepId)

        let coordinator = OnboardingCoordinator(
            sequence: TestSequence(),
            initialContext: TestContext(),
            persistence: persistence,
            completionStep: .complete
        )
        coordinator.register(TestSubflow())

        // Restored path = pushed steps only (root welcome not on path): [permissions, location]
        XCTAssertEqual(coordinator.path.count, 2)
    }

    func testOnEventFiresOnAdvance() async {
        var events: [OnboardingEvent<TestStep>] = []
        let coordinator = OnboardingCoordinator(
            sequence: TestSequence(),
            initialContext: TestContext(),
            persistence: InMemoryOnboardingPersistence(),
            completionStep: .complete
        )
        coordinator.onEvent = { events.append($0) }
        await coordinator.advance(from: .welcome)
        XCTAssertEqual(events.count, 2) // willAdvance, didAdvance
        if case .didAdvance(let from, let to) = events.last {
            XCTAssertEqual(from, .welcome)
            XCTAssertEqual(to, .permissions)
        } else {
            XCTFail("Expected didAdvance")
        }
    }

    func testOnEventFiresOnComplete() async {
        var didCompleteEvent = false
        let coordinator = OnboardingCoordinator(
            sequence: TestSequence(),
            initialContext: TestContext(),
            persistence: InMemoryOnboardingPersistence(),
            completionStep: .complete
        )
        coordinator.onEvent = { if case .didComplete = $0 { didCompleteEvent = true } }
        coordinator.onComplete = {}
        await coordinator.advance(from: .complete)
        XCTAssertTrue(didCompleteEvent)
    }

    func testOnEventFiresOnReset() {
        var didReset = false
        let coordinator = OnboardingCoordinator(
            sequence: TestSequence(),
            initialContext: TestContext(),
            persistence: InMemoryOnboardingPersistence(),
            completionStep: .complete
        )
        coordinator.onEvent = { if case .didReset = $0 { didReset = true } }
        coordinator.reset()
        XCTAssertTrue(didReset)
    }
}
