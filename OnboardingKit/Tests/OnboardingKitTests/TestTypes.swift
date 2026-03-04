//
//  TestTypes.swift
//  OnboardingKitTests
//
//  Test Step, Context, Sequence, and Subflow for the generic API.
//

import OnboardingKitCore
import SwiftUI
@testable import OnboardingKit

enum TestStep: String, OnboardingStep, CaseIterable {
    case welcome
    case permissions
    case location
    case profile
    case preferences
    case complete
}

struct TestContext: Sendable {
    var needsProfile = true
}

struct TestSequence: OnboardingSequence {
    typealias Step = TestStep
    typealias Context = TestContext

    static let steps: [TestStep] = [.welcome, .permissions, .location, .profile, .preferences, .complete]

    func steps(for context: TestContext) -> [TestStep] {
        Self.steps
    }

    func nextStep(after step: TestStep, context: TestContext) -> TestStep? {
        guard let idx = Self.steps.firstIndex(of: step), idx + 1 < Self.steps.count else { return nil }
        let next = Self.steps[idx + 1]
        if next == .profile, !context.needsProfile {
            return .preferences
        }
        return next
    }
}

struct TestSequenceWithConditionalSteps: OnboardingSequence {
    typealias Step = TestStep
    typealias Context = TestContext

    func steps(for context: TestContext) -> [TestStep] {
        var s: [TestStep] = [.welcome, .permissions, .location]
        if context.needsProfile { s.append(.profile) }
        s.append(contentsOf: [.preferences, .complete])
        return s
    }

    func nextStep(after step: TestStep, context: TestContext) -> TestStep? {
        let ordered = steps(for: context)
        guard let idx = ordered.firstIndex(of: step), idx + 1 < ordered.count else { return nil }
        return ordered[idx + 1]
    }
}

final class TestSubflowCoordinator {
    init() {}
}

struct TestSubflow: OnboardingSubflow {
    typealias ParentStep = TestStep
    typealias SubflowCoordinator = TestSubflowCoordinator
    typealias SubflowView = EmptyView

    var step: TestStep { .location }

    func makeCoordinator(parent: some OnboardingAdvancing<TestStep>) -> TestSubflowCoordinator {
        TestSubflowCoordinator()
    }

    @MainActor
    @ViewBuilder
    func content(coordinator: TestSubflowCoordinator) -> EmptyView {
        EmptyView()
    }
}
