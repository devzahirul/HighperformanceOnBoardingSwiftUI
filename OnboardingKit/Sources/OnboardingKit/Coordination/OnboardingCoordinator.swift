//
//  OnboardingCoordinator.swift
//  OnboardingKit
//
//  Flow engine: generic over your Sequence. Owns path (typed steps), context, events. @MainActor.
//

import Foundation
import OnboardingKitCore
import SwiftUI

/// Root coordinator for the onboarding flow. Generic over your ``OnboardingSequence``; fully type-safe.
///
/// Use from the main actor. All mutation is @MainActor isolated.
@MainActor
@Observable
public final class OnboardingCoordinator<Sequence: OnboardingSequence> {
    public typealias Step = Sequence.Step
    public typealias Context = Sequence.Context

    /// Current navigation path (steps pushed after the root). Bind to NavigationStack(path:). Set by the engine and by SwiftUI when the user taps back.
    public var path: NavigationPath = .init()

    /// App-defined context for branching. Your sequence's ``OnboardingSequence/steps(for:)`` and ``OnboardingSequence/nextStep(after:context:)`` receive this.
    public var context: Context

    /// Lifecycle events for analytics or validation. Set to observe willAdvance, didAdvance, didComplete, etc.
    public var onEvent: ((OnboardingEvent<Step>) -> Void)?

    /// Called when the user reaches the completion step. Dismiss onboarding in your app.
    public var onComplete: (() -> Void)?

    private let sequence: Sequence
    private let persistence: any OnboardingPersistence
    private let completionStep: Step

    /// Registered subflows: stepId → type-erased subflow.
    public private(set) var registeredSubflows: [String: AnyOnboardingSubflow<Step>] = [:]
    public private(set) var subflowCoordinators: [String: Any] = [:]

    public init(
        sequence: Sequence,
        initialContext: Context,
        persistence: any OnboardingPersistence,
        completionStep: Step
    ) {
        self.sequence = sequence
        self.context = initialContext
        self.persistence = persistence
        self.completionStep = completionStep
        self.path = Self.buildRestoredPath(
            sequence: sequence,
            initialContext: initialContext,
            persistence: persistence,
            completionStep: completionStep
        )
    }

    private static func buildRestoredPath(
        sequence: Sequence,
        initialContext: Context,
        persistence: any OnboardingPersistence,
        completionStep: Step
    ) -> NavigationPath {
        let completedSet = Set(persistence.completedStepIds())
        let ordered = sequence.steps(for: initialContext)
        var path = NavigationPath()
        var currentIndex = 0
        for (i, step) in ordered.enumerated() {
            if step == completionStep { break }
            if !completedSet.contains(step.stepId) {
                currentIndex = i
                break
            }
            currentIndex = i
        }
        if currentIndex >= 1 {
            for i in 1...currentIndex where i < ordered.count {
                path.append(ordered[i])
            }
        }
        return path
    }

    /// Root step (first in sequence). Use as the root of your NavigationStack.
    public var rootStep: Step? {
        sequence.steps(for: context).first
    }

    /// Ordered steps for progress indicator. Dynamic from context.
    public func orderedSteps() -> [Step] {
        sequence.steps(for: context)
    }

    /// Whether the user has completed onboarding (reached completion step and advanced from it).
    public var hasCompletedOnboarding: Bool {
        let completed = persistence.completedStepIds()
        return completed.contains(completionStep.stepId)
    }

    /// Advance from the current step to the next. Marks current complete, appends next to path. Calls onComplete when next is completion step.
    public func advance(from step: Step) async {
        guard let next = sequence.nextStep(after: step, context: context) else {
            if step == completionStep {
                persistence.markCompleted(stepId: step.stepId)
                onEvent?(.didComplete(step: step))
                onComplete?()
            }
            return
        }
        onEvent?(.willAdvance(from: step, to: next))
        persistence.markCompleted(stepId: step.stepId)
        path.append(next)
        onEvent?(.didAdvance(from: step, to: next))
        if next == completionStep {
            onComplete?()
        }
    }

    /// Pop the top step from the path. Fires willGoBack.
    public func goBack() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    /// Register a subflow for a step. When the user reaches that step, use ``subflowView(for:)`` or ``getOrCreateSubflowCoordinator(for:)``.
    public func register<S: OnboardingSubflow>(_ subflow: S) where S.ParentStep == Step {
        registeredSubflows[subflow.step.stepId] = AnyOnboardingSubflow(subflow)
    }

    /// Whether a subflow is registered for the given step.
    public func hasSubflow(for step: Step) -> Bool {
        registeredSubflows[step.stepId] != nil
    }

    /// Get or create the subflow coordinator for the step. Returns nil if no subflow is registered.
    public func getOrCreateSubflowCoordinator(for step: Step) -> Any? {
        if let existing = subflowCoordinators[step.stepId] { return existing }
        guard let subflow = registeredSubflows[step.stepId] else { return nil }
        let coord = subflow.makeCoordinator(parent: self)
        subflowCoordinators[step.stepId] = coord
        return coord
    }

    /// The view for the subflow step, or nil if not a subflow. Use in your content closure when step is a subflow.
    @MainActor
    public func subflowView(for step: Step) -> AnyView? {
        guard let subflow = registeredSubflows[step.stepId],
              let coord = subflowCoordinators[step.stepId] else { return nil }
        return subflow.makeView(coordinator: coord)
    }

    /// Call from your subflow when it completes or is skipped. Pops the subflow step and optionally appends the next step.
    public func finishSubflow(step: Step, next: Step?) {
        persistence.markCompleted(stepId: step.stepId)
        subflowCoordinators[step.stepId] = nil
        if !path.isEmpty { path.removeLast() }
        if let next = next { path.append(next) }
    }

    /// Clear persistence and path. Use for re-onboarding. Fires didReset.
    public func reset() {
        persistence.reset()
        path = NavigationPath()
        onEvent?(.didReset)
    }
}

extension OnboardingCoordinator: OnboardingAdvancing {}
