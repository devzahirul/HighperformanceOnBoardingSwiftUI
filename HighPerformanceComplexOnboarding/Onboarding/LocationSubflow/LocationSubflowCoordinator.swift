//
//  LocationSubflowCoordinator.swift
//  HighPerformanceComplexOnboarding
//

import Foundation
import CoreLocation
import MapKit
import OnboardingKit
import OnboardingKitCore

@Observable
@MainActor
final class LocationSubflowCoordinator {
    enum SubStep {
        case permission
        case map
    }

    var currentSubStep: SubStep = .permission
    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    var selectedCoordinate: CLLocationCoordinate2D?
    var selectedPlaceName: String?

    weak var parent: OnboardingCoordinator<AppSequence>?
    weak var state: AppOnboardingState?

    private let locationManager = CLLocationManager()

    init(parent: OnboardingCoordinator<AppSequence>? = nil, state: AppOnboardingState? = nil) {
        self.parent = parent
        self.state = state
        self.authorizationStatus = locationManager.authorizationStatus
        switch locationManager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            currentSubStep = .map
        default:
            break
        }
    }

    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    func updateAuthorizationStatus() {
        authorizationStatus = locationManager.authorizationStatus
    }

    var canProceedToMap: Bool {
        switch authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse: return true
        default: return false
        }
    }

    var currentLocation: CLLocationCoordinate2D? {
        locationManager.location?.coordinate
    }
}
