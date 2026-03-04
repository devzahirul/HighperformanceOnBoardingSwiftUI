//
//  LocationSubflow.swift
//  HighPerformanceComplexOnboarding
//
//  Subflow: permission → map → finish. Writes picked location into parent context.
//

import SwiftUI
import MapKit
import OnboardingKit
import OnboardingKitCore

struct LocationSubflow: OnboardingSubflow {
    typealias ParentStep = AppStep
    typealias SubflowCoordinator = LocationSubflowCoordinator
    typealias SubflowView = AnyView

    let state: AppOnboardingState

    var step: AppStep { .location }

    func makeCoordinator(parent: some OnboardingAdvancing<AppStep>) -> LocationSubflowCoordinator {
        let main = parent as? OnboardingCoordinator<AppSequence>
        return LocationSubflowCoordinator(parent: main, state: state)
    }

    @MainActor
    @ViewBuilder
    func content(coordinator: LocationSubflowCoordinator) -> AnyView {
        AnyView(Group {
            switch coordinator.currentSubStep {
            case .permission:
                LocationPermissionView(
                    coordinator: coordinator,
                    onEnable: {
                        coordinator.requestPermission()
                        coordinator.updateAuthorizationStatus()
                        if coordinator.canProceedToMap {
                            coordinator.currentSubStep = .map
                        }
                    },
                    onSkip: {
                        coordinator.parent?.finishSubflow(step: .location, next: .quiz)
                    }
                )
            case .map:
                LocationMapView(
                    coordinator: coordinator,
                    onConfirm: {
                        guard let coord = coordinator.selectedCoordinate else { return }
                        coordinator.state?.pickedLatitude = coord.latitude
                        coordinator.state?.pickedLongitude = coord.longitude
                        coordinator.state?.locationName = coordinator.selectedPlaceName
                        coordinator.parent?.finishSubflow(step: .location, next: .quiz)
                    },
                    onBack: {
                        coordinator.currentSubStep = .permission
                    }
                )
            }
        })
    }
}
