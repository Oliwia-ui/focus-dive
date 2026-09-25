# Component Inventory

## App shell

| Component | Location | Responsibility |
| --- | --- | --- |
| `FocusDiveApp` | `FocusDiveApp.swift` | Window, commands, menu-bar extra, shared model |
| `FocusDiveViewModel` | `FocusDiveViewModel.swift` | Core-to-UI adapter, ticker, persistence, notifications, discoveries |
| `FocusDiveDashboard` | `FocusDiveDashboard.swift` | Full dashboard composition and sheets |
| `CompactTimerView` | `SecondaryViews.swift` | Minimal timer surface |

## Primary dashboard

| Component | Responsibility |
| --- | --- |
| `TimerConsole` | Session title, countdown, progress ring, primary start/pause control |
| `DepthGauge` | Current depth and ascent status |
| Mission field | Captures the task attached when a focus session starts |
| `RightRail` | Queue, weekly profile, reset/skip/stop controls |
| `SessionQueueCard` | Four-item focus and break sequence |
| `WeeklyDepthProfile` | Completed dives across the last seven days |
| `StreakCard` | Recent daily consistency |
| `FocusEnergyCard` | Lightweight daily effort indicator |
| `DiscoveryCard` | Every-third-dive collectible reward |

## Secondary surfaces

| Component | Responsibility |
| --- | --- |
| `SettingsView` | Duration and automatic-break settings; reserved sound controls |
| `LogbookView` | Completed focus-session history |
| Menu-bar extra | Countdown and essential controls outside the main window |

## Visual primitives

| Component | Responsibility |
| --- | --- |
| `OceanBackground` | Animated gradient, light rays, particles, and terrain |
| `BubbleField` | Decorative timer bubbles |
| `DivePanelModifier` / `divePanel()` | Shared translucent panel surface |
| `SectionLabel` | Shared uppercase instrument label |
| `Color.dive*` | Semantic ocean palette |

## Core model

| Type | Responsibility |
| --- | --- |
| `DiveTimer` | Deterministic countdown state and depth/progress calculation |
| `SessionCoordinator` | Session sequencing, completion, and log-entry creation |
| `DurationSettings` | Validated durations and behavior flags |
| `SessionKind` | Focus, short break, and long break identity |
| `DiveLogEntry` | Persisted completed-focus record |
| `AppSnapshot` | Persisted settings and history payload |
| `JSONDiveStore` | Atomic JSON load and save in Application Support |

## Accessibility contracts

- Primary timer control label changes between start and pause.
- Timer display exposes formatted remaining time.
- Depth gauge exposes current meters.
- UI tests depend on `timer-display`, `primary-timer-control`, and `reset-timer-control` identifiers.
- New animation must honor the system Reduce Motion setting.
