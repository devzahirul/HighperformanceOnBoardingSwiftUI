//
//  CompletionStepView.swift
//  HighPerformanceComplexOnboarding
//

import SwiftUI
import OnboardingKit
import OnboardingKitCore

struct CompletionStepView: View {
    let step: AppStep
    let coordinator: OnboardingCoordinator<AppSequence>
    @Bindable var state: AppOnboardingState

    @State private var checkmarkScale: CGFloat = 0.5
    @State private var checkmarkOpacity: Double = 0

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(.green)
                    .scaleEffect(checkmarkScale)
                    .opacity(checkmarkOpacity)
                    .onAppear {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                            checkmarkScale = 1
                            checkmarkOpacity = 1
                        }
                    }

                VStack(spacing: 8) {
                    Text("You're All Set")
                        .font(.title)
                        .fontWeight(.semibold)
                    Text(summaryText)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .onboardingAppearance(delay: 0.12)

                Spacer(minLength: 24)

                Button {
                    Task { await coordinator.advance(from: step) }
                } label: {
                    Text("Let's Go")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal, 24)
                .onboardingAppearance(delay: 0.2)
            }
            .padding(.vertical, 32)
        }
    }

    private var summaryText: String {
        var parts: [String] = []
        if !state.userName.isEmpty {
            parts.append("Welcome, \(state.userName).")
        }
        if state.pickedLatitude != nil {
            parts.append("Your location is saved.")
        }
        if state.notificationsEnabled {
            parts.append("Notifications are on.")
        }
        if parts.isEmpty {
            return "We're ready to get started."
        }
        return parts.joined(separator: " ")
    }
}
