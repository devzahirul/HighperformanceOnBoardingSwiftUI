//
//  OnboardingFlow.swift
//  OnboardingKit
//
//  Container: NavigationStack + your @ViewBuilder content. No AnyView; progress style pluggable.
//

import OnboardingKitCore
import SwiftUI

/// Container view for the onboarding flow. Generic over your sequence; builds content with @ViewBuilder (no AnyView).
public struct OnboardingFlow<
    Seq: OnboardingSequence,
    Content: View,
    ProgressContent: View
>: View {
    public typealias Step = Seq.Step

    @State private var coordinator: OnboardingCoordinator<Seq>
    private let content: (Step, OnboardingCoordinator<Seq>) -> Content
    private let progressView: (Int, Int) -> ProgressContent
    private let onComplete: () -> Void
    private let onEvent: ((OnboardingEvent<Step>) -> Void)?

    public init(
        sequence: Seq,
        initialContext: Seq.Context,
        persistence: any OnboardingPersistence,
        completionStep: Step,
        onEvent: ((OnboardingEvent<Step>) -> Void)? = nil,
        onComplete: @escaping () -> Void,
        progressView: @escaping (Int, Int) -> ProgressContent,
        @ViewBuilder content: @escaping (Step, OnboardingCoordinator<Seq>) -> Content
    ) {
        let coord = OnboardingCoordinator(
            sequence: sequence,
            initialContext: initialContext,
            persistence: persistence,
            completionStep: completionStep
        )
        coord.onComplete = onComplete
        coord.onEvent = onEvent
        _coordinator = State(initialValue: coord)
        self.content = content
        self.progressView = progressView
        self.onComplete = onComplete
        self.onEvent = onEvent
    }

    public var body: some View {
        if let root = coordinator.rootStep {
            let steps = coordinator.orderedSteps()
            let total = max(1, steps.count)
            NavigationStack(path: $coordinator.path) {
                stepStack(step: root, currentIndex: steps.firstIndex(of: root) ?? 0, totalSteps: total)
                    .navigationDestination(for: Step.self) { step in
                        let idx = steps.firstIndex(of: step) ?? 0
                        stepStack(step: step, currentIndex: idx, totalSteps: total)
                            .transition(.onboardingStep)
                    }
            }
            .animation(.onboardingContent, value: coordinator.path.count)
        }
    }

    @ViewBuilder
    private func stepStack(step: Step, currentIndex: Int, totalSteps: Int) -> some View {
        VStack(spacing: 0) {
            progressView(currentIndex, totalSteps)
            content(step, coordinator)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

// MARK: - Default progress (capsule)

extension OnboardingFlow where ProgressContent == CapsuleProgressView {
    /// Convenience initializer using capsule progress. Pass `CapsuleProgressView.init` for progressView or use this overload.
    public init(
        sequence: Seq,
        initialContext: Seq.Context,
        persistence: any OnboardingPersistence,
        completionStep: Step,
        onEvent: ((OnboardingEvent<Step>) -> Void)? = nil,
        onComplete: @escaping () -> Void,
        @ViewBuilder content: @escaping (Step, OnboardingCoordinator<Seq>) -> Content
    ) {
        self.init(
            sequence: sequence,
            initialContext: initialContext,
            persistence: persistence,
            completionStep: completionStep,
            onEvent: onEvent,
            onComplete: onComplete,
            progressView: CapsuleProgressView.init,
            content: content
        )
    }
}
