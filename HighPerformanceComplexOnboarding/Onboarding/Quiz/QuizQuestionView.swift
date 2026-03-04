//
//  QuizQuestionView.swift
//  HighPerformanceComplexOnboarding
//

import SwiftUI
import OnboardingKit

struct QuizQuestionView: View {
    @Bindable var coordinator: QuizSubflowCoordinator

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text(coordinator.progressText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if let question = coordinator.currentQuestion {
                    Text(question.text)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .onboardingAppearance(delay: 0)

                    VStack(spacing: 12) {
                        ForEach(Array(question.options.enumerated()), id: \.offset) { index, option in
                            let isSelected = coordinator.state?.quizUserAnswers[coordinator.currentQuestionIndex] == index
                            Button {
                                coordinator.selectOption(index)
                                coordinator.goNext()
                            } label: {
                                HStack {
                                    Text(option)
                                        .multilineTextAlignment(.leading)
                                    Spacer()
                                    if isSelected {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(.tint)
                                    }
                                }
                                .padding()
                                .background(isSelected ? Color.accentColor.opacity(0.15) : Color(.secondarySystemFill), in: RoundedRectangle(cornerRadius: 12))
                            }
                            .buttonStyle(.plain)
                            .onboardingAppearance(delay: 0.06 + Double(index) * 0.04)
                        }
                    }
                }

                Spacer(minLength: 24)

                if coordinator.currentQuestionIndex > 0 {
                    Button("Back") {
                        coordinator.goBack()
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.secondary)
                }
            }
            .padding(24)
        }
    }
}
