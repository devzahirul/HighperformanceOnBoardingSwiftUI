# OnboardingKit

A production-grade Swift package for high-performance, resumable onboarding flows in SwiftUI.

## Overview

OnboardingKit provides a root coordinator, navigation path, and pluggable sub-flows so you can build multi-step onboarding (welcome → permissions → location → profile → preferences → complete) with persistence and extensibility.

## Topics

### Getting started

- ``OnboardingView`` – Root SwiftUI view; add to your app and inject the coordinator via environment.
- ``OnboardingCoordinator`` – Create one with a persistence implementation; register sub-flows and present ``OnboardingView``.

### Coordination

- ``OnboardingCoordinator`` – Owns path, collected data, and step sequence; register sub-flows via ``OnboardingCoordinator/register(_:)``.
- ``OnboardingAdvancing`` – Protocol for advancing the flow and writing collected data; use in ViewModels for testability.
- ``OnboardingSubflow`` – Implement to add a new Step → sub-steps flow without forking the package.
- ``OnboardingCoordinator/registerDefaultSubflows()`` – Registers the built-in location sub-flow.
- ``OnboardingCoordinator/hasSubflow(for:)`` – Returns whether a sub-flow is registered for a step.
- ``OnboardingCoordinator/finishSubflow(step:next:)`` – Call from a sub-flow when it completes or is skipped.

### Persistence

- ``OnboardingPersistence`` – Protocol for saving and restoring progress; implement for custom storage or tests.
- ``UserDefaultsOnboardingPersistence`` – Default implementation using UserDefaults.

### Data and steps

- ``OnboardingStep`` – Enum of main steps (welcome, permissions, location, profile, preferences, complete).
- ``OnboardingData`` – Data collected during onboarding (name, avatar, location, preferences, etc.).

### Location sub-flow

- ``LocationOnboardingSubflow`` – Built-in sub-flow for the location step.
- ``LocationCoordinator`` – Sub-coordinator for location steps (request, denied, settings, map, confirm).
- ``LocationStep``, ``LocationEvent``, ``LocationFlowData``, ``PickedLocation`` – Supporting types.
