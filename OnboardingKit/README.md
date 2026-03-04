# OnboardingKit

A **type-safe flow engine** for high-performance, resumable onboarding in SwiftUI. Your app defines **steps** (enum), **context**, **sequence**, and **views**; OnboardingKit runs the flow (advance, back, persist, restore) and hosts your content with **no AnyView** and **no stringly-typed APIs**.

---

## Requirements

- **iOS 17+** / **macOS 14+**
- **Swift 5.9+**
- **Xcode 15+**

---

## Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/your-org/OnboardingKit.git", from: "1.0.0"),
],
targets: [
    .target(name: "YourApp", dependencies: ["OnboardingKit", "OnboardingKitCore"]),
]
```

Or in **Xcode**: **File → Add Package Dependencies**.

### Local development

```swift
.package(path: "../OnboardingKit")
```

---

## Quick start

1. **Define your step enum** (conform to `OnboardingStep`; use `String` raw value for free `stepId`):

```swift
import OnboardingKitCore

enum MyStep: String, OnboardingStep, CaseIterable {
    case welcome, permissions, profile, complete
}
```

2. **Define context** (for branching; use `Void` if you don't need it):

```swift
struct MyContext: Sendable {
    var needsProfile = true
}
```

3. **Implement your sequence**:

```swift
struct MySequence: OnboardingSequence {
    typealias Step = MyStep
    typealias Context = MyContext

    func steps(for context: MyContext) -> [MyStep] {
        [.welcome, .permissions, .profile, .complete]
    }

    func nextStep(after step: MyStep, context: MyContext) -> MyStep? {
        switch step {
        case .welcome: return .permissions
        case .permissions: return .profile
        case .profile: return .complete
        case .complete: return nil
        }
    }
}
```

4. **Present the flow** with `OnboardingFlow` and `@ViewBuilder` content:

```swift
import SwiftUI
import OnboardingKit
import OnboardingKitCore

OnboardingFlow(
    sequence: MySequence(),
    initialContext: MyContext(),
    persistence: .userDefaults(),
    completionStep: .complete,
    onComplete: { showOnboarding = false },
    content: { step, coordinator in
        switch step {
        case .welcome: WelcomeView(coordinator: coordinator)
        case .permissions: PermissionsView(coordinator: coordinator)
        case .profile: ProfileView(coordinator: coordinator)
        case .complete: CompletionView(coordinator: coordinator)
        }
    }
)
```

5. **Advance** from your views (coordinator is `@MainActor`):

```swift
Button("Continue") {
    Task { await coordinator.advance(from: step) }
}
```

---

## Architecture

- **OnboardingKitCore** — `OnboardingStep`, `OnboardingSequence` (generic over Step + Context), `OnboardingPersistence` (markCompleted, completedStepIds, reset), `OnboardingEvent`. No UI.
- **OnboardingKit** — `OnboardingCoordinator<Sequence>` (@MainActor, type-safe path and context), `OnboardingFlow` (NavigationStack + your @ViewBuilder), `OnboardingSubflow`, `OnboardingAdvancing`, progress styles (Capsule, Bar, Hidden).

Progress is **dynamic**: `steps(for: context)` so you can skip steps and the indicator stays correct.

---

## Persistence

- **UserDefaults**: `UserDefaultsOnboardingPersistence.userDefaults()` or `.userDefaults(store:key:)`
- **In-memory** (tests/previews): `InMemoryOnboardingPersistence.inMemory`
- **Custom**: conform to `OnboardingPersistence` (markCompleted, completedStepIds, reset). Completion is determined by the coordinator (completion step), not persistence.

---

## Events and lifecycle

Set `coordinator.onEvent` to observe:

- `willAdvance(from:to:)`, `didAdvance(from:to:)`
- `willGoBack(from:to:)`
- `didComplete(step:)`
- `didReset`

Use for analytics or validation.

---

## Subflows

When one step is a multi-screen flow, implement `OnboardingSubflow` (ParentStep, makeCoordinator(parent:), content(coordinator:)), then `coordinator.register(MySubflow())`. Use `coordinator.subflowView(for: step)` in your content when the step is a subflow, or `getOrCreateSubflowCoordinator(for: step)` and render your own view. Call `coordinator.finishSubflow(step:next:)` when the subflow completes.

---

## Progress style

Default is capsule dots. Use the full initializer and pass `progressView: BarProgressView.init` or `HiddenProgressView.init`, or a custom `(Int, Int) -> SomeView`.

---

## API summary

| Type | Purpose |
|------|--------|
| `OnboardingStep` | Protocol; enum with String raw value gets free stepId. |
| `OnboardingSequence` | steps(for:), nextStep(after:context:). Generic Step, Context. |
| `OnboardingPersistence` | markCompleted, completedStepIds, reset. |
| `OnboardingCoordinator<Seq>` | path, context, advance(from:), goBack(), reset(), onComplete, onEvent, subflows. |
| `OnboardingFlow` | Container; takes sequence, context, persistence, completionStep, onComplete, @ViewBuilder content. |
| `OnboardingAdvancing` | Protocol for advance(from:) and goBack(); use in ViewModels for testability. |

---

## Testing

Use `InMemoryOnboardingPersistence.inMemory` and a test sequence. The coordinator is `@MainActor`; use `@MainActor` tests or `Task { await ... }` when advancing.

```bash
swift test
```

---

## License

MIT (or your chosen license).
