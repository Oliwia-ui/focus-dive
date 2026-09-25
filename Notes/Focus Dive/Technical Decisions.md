# Technical Decisions

## TD-001 — Native SwiftUI macOS app

**Status:** Accepted

Use SwiftUI with a macOS 14 deployment target. This supports the visual dashboard, menu-bar extra, command system, accessibility environment, and a small native distribution footprint.

## TD-002 — Separate core behavior from the app layer

**Status:** Accepted

Keep timer, sequencing, settings, and persistence in `FocusDiveCore`. Keep SwiftUI, AppKit, Combine, and UserNotifications in `FocusDiveApp`. Core behavior remains deterministic and testable without launching an application.

## TD-003 — Anchor timer calculations to dates

**Status:** Accepted

`DiveTimer` derives elapsed time from an anchor `Date`; the UI ticker only requests refreshes. This prevents accumulated drift from treating timer callbacks as elapsed-time truth.

## TD-004 — Persist one local JSON snapshot

**Status:** Accepted

Store settings and completed focus history in `~/Library/Application Support/FocusDive/focus-dive.json` using ISO 8601 dates and atomic writes. This is sufficient for the MVP and keeps data inspectable and local.

**Consequence:** Codable model changes need an explicit migration strategy before breaking schema compatibility.

## TD-005 — Swift Package Manager is the source of truth

**Status:** Accepted

Use `Package.swift` for the executable, core library, and unit tests. Use XcodeGen only when an Xcode project is required for app and UI testing. Do not commit the generated project.

## TD-006 — Build a local app bundle with a script

**Status:** Accepted

`scripts/build-app.sh` builds the package, assembles `dist/Focus Dive.app`, copies app metadata, and ad-hoc signs the bundle.

**Consequence:** External distribution still requires Developer ID signing, notarization, stapling, packaging, and release automation.

## TD-007 — Keep the MVP silent

**Status:** Accepted

Retain future sound flags in settings while presenting disabled sound controls. Completion feedback uses visual state and a local notification without audio.

## TD-008 — Derive lightweight rewards

**Status:** Accepted

Compute discoveries from completed history count and derive weekly profile, streak, and focus energy from history. Avoid additional persistence until reward state needs independent user control.

## TD-009 — Respect system motion preferences

**Status:** Accepted

Pass Reduce Motion into continuous visual effects and progress animation. With reduced motion enabled, decorative drift is effectively frozen and progress transitions are not animated.

## Open decisions

- Persistence migration and recovery behavior
- App Sandbox and hardened runtime configuration
- Developer ID signing, notarization, and distribution channel
- Sound implementation and user-facing audio policy
- History editing, export, retention, and sync
