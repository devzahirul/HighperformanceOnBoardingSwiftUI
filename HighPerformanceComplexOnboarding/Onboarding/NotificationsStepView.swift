//
//  NotificationsStepView.swift
//  HighPerformanceComplexOnboarding
//

import SwiftUI
import OnboardingKit
import OnboardingKitCore
import UserNotifications

struct NotificationsStepView: View {
    let step: AppStep
    let coordinator: OnboardingCoordinator<AppSequence>
    @Bindable var state: AppOnboardingState

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(.tint)
                    .onboardingHeroIcon(delay: 0)

                VStack(spacing: 8) {
                    Text("Notifications")
                        .font(.title)
                        .fontWeight(.semibold)
                    Text("Get timely updates and reminders.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .onboardingAppearance(delay: 0.08)

                Spacer(minLength: 24)

                Button {
                    requestNotificationPermission()
                    Task { await coordinator.advance(from: step) }
                } label: {
                    Text("Enable Notifications")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal, 24)
                .onboardingAppearance(delay: 0.16)

                Button {
                    state.notificationsEnabled = false
                    Task { await coordinator.advance(from: step) }
                } label: {
                    Text("Skip for now")
                        .font(.subheadline)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
                .onboardingAppearance(delay: 0.24)
            }
            .padding(.vertical, 32)
        }
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            DispatchQueue.main.async {
                state.notificationsEnabled = granted
            }
        }
    }
}
