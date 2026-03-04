//
//  HomeView.swift
//  HighPerformanceComplexOnboarding
//

import SwiftUI
import MapKit
import OnboardingKit

struct HomeView: View {
    @Bindable var state: AppOnboardingState
    let onResetOnboarding: () -> Void

    private var quizScore: (correct: Int, total: Int) {
        let correct = QuizQuestions.all.reduce(0) { acc, q in
            guard let selected = state.quizUserAnswers[q.id] else { return acc }
            return acc + (selected == q.correctOptionIndex ? 1 : 0)
        }
        return (correct, 12)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    headerSection

                    if let lat = state.pickedLatitude, let lon = state.pickedLongitude {
                        locationCard(lat: lat, lon: lon)
                    } else {
                        noLocationCard
                    }

                    if state.notificationsEnabled {
                        notificationsPill
                    }

                    if state.quizUserAnswers.count == 12 {
                        scoreRingSection
                        quizFlashCardsSection
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Home")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        onResetOnboarding()
                    } label: {
                        Image(systemName: "arrow.counterclockwise.circle")
                    }
                }
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Welcome\(state.userName.isEmpty ? "" : ", \(state.userName)")")
                .font(.title)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Location

    private func locationCard(lat: Double, lon: Double) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Your location", systemImage: "mappin.circle.fill")
                .font(.headline)
            Map(initialPosition: .region(MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
            ))) {
                Annotation(state.locationName ?? "Picked", coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon)) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.title)
                        .foregroundStyle(.red)
                }
            }
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .padding(20)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 20))
    }

    private var noLocationCard: some View {
        HStack(spacing: 14) {
            Image(systemName: "location.slash")
                .font(.title2)
                .foregroundStyle(.secondary)
            Text("No location set")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 20))
    }

    private var notificationsPill: some View {
        HStack(spacing: 8) {
            Image(systemName: "bell.fill")
                .font(.subheadline)
            Text("Notifications enabled")
                .font(.subheadline)
        }
        .foregroundStyle(.secondary)
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(Color(.tertiarySystemFill), in: Capsule())
    }

    // MARK: - Score ring

    private var scoreRingSection: some View {
        let score = quizScore
        let fraction = score.total > 0 ? Double(score.correct) / Double(score.total) : 0
        let ringColor = fraction >= 0.75 ? Color.green : (fraction >= 0.5 ? Color.orange : Color.red)

        return VStack(spacing: 20) {
            Text("Quiz results")
                .font(.title2)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 24) {
                ZStack {
                    Circle()
                        .stroke(Color(.tertiarySystemFill), lineWidth: 12)
                        .frame(width: 120, height: 120)
                    Circle()
                        .trim(from: 0, to: fraction)
                        .stroke(ringColor, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(-90))
                    VStack(spacing: 2) {
                        Text("\(score.correct)")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                        Text("of \(score.total)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .onboardingAppearance(delay: 0)

                Text("\(score.correct) out of 12 correct")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .onboardingAppearance(delay: 0.08)
                Spacer(minLength: 0)
            }
            .padding(24)
            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 20))
        }
    }

    // MARK: - Flash cards (OnboardingKit styling)

    private var quizFlashCardsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Review answers")
                .font(.title2)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)

            TabView {
                ForEach(Array(QuizQuestions.all.enumerated()), id: \.element.id) { index, question in
                    QuizResultCard(
                        question: question,
                        selectedIndex: state.quizUserAnswers[question.id],
                        questionNumber: index + 1,
                        totalQuestions: 12
                    )
                    .onboardingAppearance(delay: Double(index) * 0.04)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .frame(height: 280)
        }
    }
}

// MARK: - Flash card

private struct QuizResultCard: View {
    let question: QuizQuestion
    let selectedIndex: Int?
    let questionNumber: Int
    let totalQuestions: Int

    private var isCorrect: Bool {
        guard let s = selectedIndex else { return false }
        return s == question.correctOptionIndex
    }

    private var userAnswerText: String {
        selectedIndex.map { question.options[$0] } ?? "—"
    }

    private var correctAnswerText: String {
        question.options[question.correctOptionIndex]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("\(questionNumber)/\(totalQuestions)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.tertiarySystemFill), in: Capsule())
                Spacer()
                Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(isCorrect ? .green : .red)
            }

            Text(question.text)
                .font(.body)
                .fontWeight(.medium)
                .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Text("Your answer:")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(userAnswerText)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                if !isCorrect {
                    HStack(spacing: 6) {
                        Text("Correct:")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(correctAnswerText)
                            .font(.subheadline)
                            .foregroundStyle(.green)
                    }
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
}
