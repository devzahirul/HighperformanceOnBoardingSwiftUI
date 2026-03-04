//
//  WelcomeStepView.swift
//  HighPerformanceComplexOnboarding
//

import SwiftUI
import OnboardingKit
import OnboardingKitCore

struct WelcomeStepView: View {
    let step: AppStep
    let coordinator: OnboardingCoordinator<AppSequence>
    @Bindable var state: AppOnboardingState

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                Image(systemName: "hand.wave.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(.tint)
                    .onboardingHeroIcon(delay: 0)

                VStack(spacing: 8) {
                    Text("Welcome")
                        .font(.title)
                        .fontWeight(.semibold)
                    Text("Set up your experience in a few quick steps.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .onboardingAppearance(delay: 0.08)

                TextField("Your name", text: $state.userName)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.name)
                    .autocapitalization(.words)
                    .padding(.horizontal, 24)
                    .onboardingAppearance(delay: 0.16)

                Spacer(minLength: 24)

                Button {
                    Task { await coordinator.advance(from: step) }
                } label: {
                    Text("Get Started")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal, 24)
                .disabled(state.userName.trimmingCharacters(in: .whitespaces).isEmpty)
                .onboardingAppearance(delay: 0.24)
            }
            .padding(.vertical, 32)
        }
    }
}
