//
//  OnboardingSubflow.swift
//  OnboardingKit
//
//  Type-safe subflow: a multi-step flow that occupies one parent step.
//

import Foundation
import OnboardingKitCore
import SwiftUI

/// A sub-flow occupies one parent step and has its own coordinator and internal steps. Register with the coordinator.
public protocol OnboardingSubflow: Sendable {
    associatedtype ParentStep: OnboardingStep
    associatedtype SubflowCoordinator: AnyObject
    associatedtype SubflowView: View

    /// The parent step this subflow occupies.
    var step: ParentStep { get }

    /// Create the subflow's coordinator. Call `parent.advance(from:)` or `parent.finishSubflow(step:next:)` when done.
    @MainActor
    func makeCoordinator(parent: some OnboardingAdvancing<ParentStep>) -> SubflowCoordinator

    @MainActor
    @ViewBuilder
    func content(coordinator: SubflowCoordinator) -> SubflowView
}

// MARK: - Type-erased storage

public struct AnyOnboardingSubflow<ParentStep: OnboardingStep> {
    public let step: ParentStep
    private let _makeCoordinator: @MainActor (any OnboardingAdvancing<ParentStep>) -> Any
    private let _makeView: @MainActor (Any) -> AnyView

    public init<S: OnboardingSubflow>(_ subflow: S) where S.ParentStep == ParentStep {
        self.step = subflow.step
        self._makeCoordinator = { @MainActor parent in
            subflow.makeCoordinator(parent: parent)
        }
        self._makeView = { @MainActor coordinator in
            guard let coord = coordinator as? S.SubflowCoordinator else {
                return AnyView(EmptyView())
            }
            return AnyView(subflow.content(coordinator: coord))
        }
    }

    @MainActor
    func makeCoordinator(parent: any OnboardingAdvancing<ParentStep>) -> Any {
        _makeCoordinator(parent)
    }

    @MainActor
    public func makeView(coordinator: Any) -> AnyView {
        _makeView(coordinator)
    }
}
