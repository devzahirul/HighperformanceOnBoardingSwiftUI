# High-Performance Complex Onboarding

> Production-grade onboarding architecture for iOS, built with SwiftUI, an enum-driven state machine, protocol-oriented persistence, and a reusable Swift Package -- **OnboardingKit**.

### Watch demo

[![Watch the app demo](https://img.youtube.com/vi/qbqFjROJhbI/hqdefault.jpg)](https://youtube.com/shorts/qbqFjROJhbI?si=ccheq0dMdJcgoiPd)

**▶ [Play on YouTube](https://youtube.com/shorts/qbqFjROJhbI?si=ccheq0dMdJcgoiPd)** — tap the thumbnail or link to watch the app in action.

---

## Why This Project Exists

Most onboarding implementations are hard-coded `if/else` chains glued to `@AppStorage` booleans. They break the moment a PM asks to reorder steps, add conditional branching, or support mid-flow resume after a cold launch.

This project demonstrates a **fundamentally different approach**: a generic, type-safe flow engine that treats onboarding as a **finite-state machine** with compile-time guarantees, protocol-driven persistence, lifecycle events for analytics, and first-class support for **nested sub-flows** -- all without a single `AnyView` in the engine layer.

---

## Architecture Overview

```
┌──────────────────────────────────────────────────────────────────┐
│                         App Layer                                │
│  AppStep (enum) · AppSequence · AppOnboardingState (@Observable) │
│  Step Views · Subflow Coordinators · HomeView                    │
└──────────────┬───────────────────────────────────┬───────────────┘
               │ depends on                        │
┌──────────────▼───────────────┐  ┌────────────────▼───────────────┐
│       OnboardingKit          │  │      OnboardingKitCore         │
│  OnboardingCoordinator<Seq>  │  │  OnboardingStep (protocol)     │
│  OnboardingFlow (View)       │  │  OnboardingSequence (protocol) │
│  OnboardingSubflow (proto)   │  │  OnboardingPersistence (proto) │
│  OnboardingAdvancing (proto) │  │  OnboardingEvent<Step>         │
│  Animation modifiers         │  │  UserDefaults / InMemory impl  │
└──────────────────────────────┘  └────────────────────────────────┘
```

### Design decisions and trade-offs

| Decision | Rationale |
|----------|-----------|
| **Generic coordinator** `OnboardingCoordinator<Seq>` | Full type safety on `Step` and `Context` with zero type erasure in the public API. The compiler catches step mismatches at build time. |
| **Protocol-driven persistence** | `OnboardingPersistence` is a 3-method contract (`markCompleted`, `completedStepIds`, `reset`). Swap `UserDefaults` for Core Data, Keychain, or a remote backend without touching the engine. |
| **Sequence protocol with context** | `steps(for: Context)` and `nextStep(after:context:)` enable **dynamic branching** -- skip steps, reorder, or gate on runtime state. Progress indicators update automatically. |
| **Subflow as a first-class concept** | Multi-screen steps (e.g. location permission + map picker) get their own coordinator, views, and lifecycle without polluting the parent flow. |
| **`@Observable` + `NavigationPath`** | Leverages iOS 17 Observation framework for fine-grained view invalidation. No `ObservableObject` / `@Published` overhead; no manual `objectWillChange`. |
| **Two-target package split** | `OnboardingKitCore` (no UI) can be imported by ViewModels, services, or server-side Swift. `OnboardingKit` adds the SwiftUI layer. |

---

## App Flow

```
Welcome ──► Location (subflow) ──► Quiz (subflow) ──► Notifications ──► Complete ──► Home
               │                       │
               ├─ Permission screen     ├─ 12 questions, one per screen
               └─ Map picker            └─ Answers stored in shared state
```

**Resumability**: if the user kills the app mid-flow, the coordinator rebuilds the `NavigationPath` from persisted step IDs on next launch -- no data loss, no restart.

---

## Key Components

### OnboardingKit (Swift Package)

| Type | Role |
|------|------|
| `OnboardingStep` | Protocol. Conform an enum with `String` raw value for automatic `stepId`. |
| `OnboardingSequence` | Protocol. Defines step ordering and context-aware branching. |
| `OnboardingPersistence` | Protocol. 3 methods. Ships with `UserDefaultsOnboardingPersistence` and `InMemoryOnboardingPersistence`. |
| `OnboardingCoordinator<Seq>` | `@MainActor @Observable`. Owns `NavigationPath`, context, subflow registry, lifecycle events. |
| `OnboardingFlow<Seq, Content, Progress>` | SwiftUI container. `NavigationStack` + `@ViewBuilder` content -- **no AnyView**. Pluggable progress styles. |
| `OnboardingSubflow` | Protocol for nested multi-screen flows. Type-erased internally via `AnyOnboardingSubflow`. |
| `OnboardingAdvancing` | Protocol extracted for testability. Inject a mock coordinator in unit tests. |
| `OnboardingEvent<Step>` | Enum: `willAdvance`, `didAdvance`, `willGoBack`, `didComplete`, `didReset`. Hook for analytics. |

### Demo App

| File | Responsibility |
|------|----------------|
| `AppOnboardingTypes.swift` | `AppStep` enum, `AppOnboardingState` (`@Observable` shared context), `AppSequence` |
| `OnboardingContentWrapper.swift` | Registers subflows, ensures coordinators are created before rendering, routes steps to views |
| `LocationSubflow/` | Permission screen + MapKit picker. Auto-skips permission when already authorized. Shows `UserAnnotation` and "Use my location" button. |
| `Quiz/` | 12-question quiz subflow. `QuizSubflowCoordinator` manages question index and answer storage. `QuizQuestionView` renders one question per screen with staggered OnboardingKit animations. |
| `HomeView.swift` | Post-onboarding dashboard. Circular score ring, horizontally-paged flash card review (OnboardingKit appearance modifiers), location map card. |

---

## Technical Highlights

### 1. Enum-Driven State Machine

```swift
enum AppStep: String, OnboardingStep, CaseIterable {
    case welcome, location, quiz, notifications, complete
}
```

Every valid state is a compiler-checked enum case. Illegal transitions are impossible -- `nextStep(after:context:)` returns an `Optional<Step>`, not a stringly-typed route.

### 2. Cold-Launch Resume via Path Reconstruction

```swift
private static func buildRestoredPath(
    sequence: Sequence,
    initialContext: Context,
    persistence: any OnboardingPersistence,
    completionStep: Step
) -> NavigationPath { ... }
```

On init, the coordinator walks the sequence, skips persisted steps, and rebuilds the exact `NavigationPath` -- the user lands on the first incomplete step with full back-stack intact.

### 3. Nested Subflows with Coordinator Lifecycle

```swift
protocol OnboardingSubflow {
    associatedtype ParentStep: OnboardingStep
    associatedtype SubflowCoordinator: AnyObject
    func makeCoordinator(parent: some OnboardingAdvancing<ParentStep>) -> SubflowCoordinator
    func content(coordinator: SubflowCoordinator) -> SubflowView
}
```

Subflow coordinators are lazily created, cached per step, and automatically cleaned up on `finishSubflow(step:next:)`. Parent and child communicate through the `OnboardingAdvancing` protocol -- no tight coupling.

### 4. Context-Aware Dynamic Branching

```swift
func steps(for context: AppOnboardingState) -> [AppStep] { ... }
func nextStep(after step: AppStep, context: AppOnboardingState) -> AppStep? { ... }
```

The step list is a **function of context**, not a static array. Change a flag on the shared state and the flow adapts -- steps appear, disappear, or reorder. Progress indicators recalculate automatically.

### 5. Zero AnyView in the Engine

`OnboardingFlow` uses `@ViewBuilder` generics end-to-end. `AnyView` only appears at the subflow boundary (type-erased storage in `AnyOnboardingSubflow`) -- the rest of the view hierarchy preserves SwiftUI's diffing efficiency.

### 6. Testability by Design

- `OnboardingAdvancing` protocol lets you inject a mock coordinator into any ViewModel.
- `InMemoryOnboardingPersistence` for deterministic, isolated test runs.
- Coordinator is `@MainActor` with `async` advance -- standard `@MainActor` test pattern.

```swift
func testFullFlowAdvancesAndPersists() async {
    let persistence = InMemoryOnboardingPersistence()
    let coordinator = OnboardingCoordinator(
        sequence: TestSequence(),
        initialContext: TestContext(),
        persistence: persistence,
        completionStep: .complete
    )
    coordinator.register(TestSubflow())
    await coordinator.advance(from: .welcome)
    // ...
    XCTAssertTrue(coordinator.hasCompletedOnboarding)
}
```

---

## Project Structure

```
HighPerformanceComplexOnboarding/
├── HighPerformanceComplexOnboarding/       # iOS app target
│   ├── HighPerformanceComplexOnboardingApp.swift
│   ├── HomeView.swift                      # Score ring + flash cards
│   └── Onboarding/
│       ├── AppOnboardingTypes.swift         # Step, State, Sequence
│       ├── OnboardingContentWrapper.swift   # Routing + subflow registration
│       ├── WelcomeStepView.swift
│       ├── NotificationsStepView.swift
│       ├── CompletionStepView.swift
│       ├── LocationSubflow/
│       │   ├── LocationSubflow.swift
│       │   ├── LocationSubflowCoordinator.swift
│       │   ├── LocationPermissionView.swift
│       │   └── LocationMapView.swift
│       └── Quiz/
│           ├── QuizTypes.swift
│           ├── QuizSubflow.swift
│           ├── QuizSubflowCoordinator.swift
│           └── QuizQuestionView.swift
├── OnboardingKit/                          # Swift Package
│   ├── Package.swift
│   ├── Sources/
│   │   ├── OnboardingKitCore/              # No UI dependency
│   │   │   ├── OnboardingStep.swift
│   │   │   ├── OnboardingSequence.swift
│   │   │   ├── OnboardingPersistence.swift
│   │   │   ├── OnboardingEvent.swift
│   │   │   ├── UserDefaultsOnboardingPersistence.swift
│   │   │   └── InMemoryOnboardingPersistence.swift
│   │   └── OnboardingKit/                  # SwiftUI layer
│   │       ├── Coordination/
│   │       │   ├── OnboardingCoordinator.swift
│   │       │   └── OnboardingAdvancing.swift
│   │       ├── Core/
│   │       │   └── OnboardingSubflow.swift
│   │       └── UI/
│   │           ├── OnboardingFlow.swift
│   │           ├── OnboardingAnimations.swift
│   │           └── OnboardingProgressStyle.swift
│   └── Tests/
│       └── OnboardingKitTests/
│           ├── OnboardingCoordinatorTests.swift
│           ├── OnboardingIntegrationTests.swift
│           ├── PersistenceTests.swift
│           └── TestTypes.swift
└── HighPerformanceComplexOnboardingTests/
    └── HighPerformanceComplexOnboardingTests.swift
```

---

## Requirements

- **Xcode 15+**
- **iOS 17+**
- **Swift 5.9+**

## Quick Start

```bash
# Clone
git clone <repo-url>
cd HighPerformanceComplexOnboarding

# Open in Xcode
open HighPerformanceComplexOnboarding.xcodeproj

# Run tests (OnboardingKit package)
cd OnboardingKit && swift test
```

Select the **HighPerformanceComplexOnboarding** scheme, pick a simulator (iOS 17+), and run.

---

## Using OnboardingKit in Your Own App

Add as a local or remote Swift Package dependency:

```swift
// Package.swift
dependencies: [
    .package(path: "../OnboardingKit"),  // local
    // .package(url: "https://github.com/your-org/OnboardingKit.git", from: "1.0.0"),
]
```

Minimal integration:

```swift
import SwiftUI
import OnboardingKit
import OnboardingKitCore

@main
struct MyApp: App {
    private static let persistence = UserDefaultsOnboardingPersistence.userDefaults()
    @State private var showOnboarding = !Self.persistence.completedStepIds().contains(MyStep.done.stepId)
    @State private var context = MyContext()

    var body: some Scene {
        WindowGroup {
            if showOnboarding {
                OnboardingFlow(
                    sequence: MySequence(),
                    initialContext: context,
                    persistence: Self.persistence,
                    completionStep: .done,
                    onComplete: { showOnboarding = false },
                    content: { step, coordinator in
                        // Your step views here
                    }
                )
            } else {
                ContentView()
            }
        }
    }
}
```

---

## License

MIT -- see LICENSE file.
