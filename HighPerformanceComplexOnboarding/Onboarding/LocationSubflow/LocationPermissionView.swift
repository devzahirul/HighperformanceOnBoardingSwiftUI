//
//  LocationPermissionView.swift
//  HighPerformanceComplexOnboarding
//

import SwiftUI
import CoreLocation
import OnboardingKit

struct LocationPermissionView: View {
    @Bindable var coordinator: LocationSubflowCoordinator
    let onEnable: () -> Void
    let onSkip: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                Image(systemName: "location.circle.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(.tint)
                    .onboardingHeroIcon(delay: 0)

                VStack(spacing: 8) {
                    Text("Location")
                        .font(.title)
                        .fontWeight(.semibold)
                    Text("We use your location to show nearby places and personalize your experience.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .onboardingAppearance(delay: 0.08)

                Spacer(minLength: 24)

                Button(action: onEnable) {
                    Text("Enable Location")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal, 24)
                .onboardingAppearance(delay: 0.16)

                Button(action: onSkip) {
                    Text("Skip for now")
                        .font(.subheadline)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
                .onboardingAppearance(delay: 0.24)
            }
            .padding(.vertical, 32)
        }
        .onAppear {
            coordinator.updateAuthorizationStatus()
            if coordinator.canProceedToMap {
                coordinator.currentSubStep = .map
            }
        }
    }
}
