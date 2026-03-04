//
//  OnboardingProgressStyle.swift
//  OnboardingKit
//
//  Pluggable progress indicators for the onboarding flow.
//

import SwiftUI

/// Capsule-style step indicator (dots; current step is wider). Use as default progress.
public struct CapsuleProgressView: View {
    let currentIndex: Int
    let totalSteps: Int
    private let dotSize: CGFloat = 8
    private let dotSpacing: CGFloat = 8

    public init(currentIndex: Int, totalSteps: Int) {
        self.currentIndex = currentIndex
        self.totalSteps = totalSteps
    }

    public var body: some View {
        HStack(spacing: dotSpacing) {
            ForEach(0..<max(1, totalSteps), id: \.self) { index in
                Capsule()
                    .fill(index <= currentIndex ? Color.accentColor : Color.secondary.opacity(0.3))
                    .frame(width: index == currentIndex ? 20 : dotSize, height: dotSize)
                    .animation(.onboardingContent, value: currentIndex)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
}

/// Bar-style progress (linear fill).
public struct BarProgressView: View {
    let currentIndex: Int
    let totalSteps: Int

    public init(currentIndex: Int, totalSteps: Int) {
        self.currentIndex = currentIndex
        self.totalSteps = totalSteps
    }

    public var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.secondary.opacity(0.3))
                Rectangle()
                    .fill(Color.accentColor)
                    .frame(width: totalSteps > 0 ? geo.size.width * CGFloat(currentIndex + 1) / CGFloat(totalSteps) : 0)
                    .animation(.onboardingContent, value: currentIndex)
            }
        }
        .frame(height: 4)
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
}

/// Hides the progress indicator.
public struct HiddenProgressView: View {
    let currentIndex: Int
    let totalSteps: Int

    public init(currentIndex: Int, totalSteps: Int) {
        self.currentIndex = currentIndex
        self.totalSteps = totalSteps
    }

    public var body: some View {
        EmptyView()
    }
}
