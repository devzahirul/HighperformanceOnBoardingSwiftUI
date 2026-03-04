//
//  OnboardingAnimations.swift
//  OnboardingKit
//
//  Shared animation curves and modifiers for step transitions.
//

import SwiftUI

// MARK: - Animation constants

public enum OnboardingTiming {
    public static let stagger: Double = 0.08
    public static let staggerLong: Double = 0.14
}

public extension Animation {
    static let onboardingContent = Animation.spring(response: 0.52, dampingFraction: 0.82)
    static let onboardingCta = Animation.spring(response: 0.45, dampingFraction: 0.78)
    static let onboardingHero = Animation.spring(response: 0.6, dampingFraction: 0.75)
}

// MARK: - Modifiers

public struct OnboardingAppearanceModifier: ViewModifier {
    public var delay: Double = 0
    public var offset: CGFloat = 16
    public var scale: CGFloat = 1
    public init(delay: Double = 0, offset: CGFloat = 16, scale: CGFloat = 1) {
        self.delay = delay
        self.offset = offset
        self.scale = scale
    }
    @State private var appeared = false

    public func body(content: Content) -> some View {
        content
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : offset)
            .scaleEffect(appeared ? 1 : scale)
            .onAppear {
                withAnimation(Animation.onboardingContent.delay(delay)) { appeared = true }
            }
    }
}

public struct OnboardingHeroIconModifier: ViewModifier {
    public var delay: Double = 0
    public init(delay: Double = 0) {
        self.delay = delay
    }
    @State private var appeared = false

    public func body(content: Content) -> some View {
        content
            .scaleEffect(appeared ? 1 : 0.6)
            .opacity(appeared ? 1 : 0)
            .onAppear {
                withAnimation(Animation.onboardingHero.delay(delay)) { appeared = true }
            }
    }
}

public extension View {
    func onboardingAppearance(delay: Double = 0, offset: CGFloat = 16, scale: CGFloat = 1) -> some View {
        modifier(OnboardingAppearanceModifier(delay: delay, offset: offset, scale: scale))
    }
    func onboardingHeroIcon(delay: Double = 0) -> some View {
        modifier(OnboardingHeroIconModifier(delay: delay))
    }
}

public extension AnyTransition {
    static var onboardingStep: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        )
    }
}
