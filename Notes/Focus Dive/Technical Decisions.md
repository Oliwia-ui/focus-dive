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

## TD-010 — Edit durations without interrupting active work

**Status:** Accepted

Expose bounded duration editors directly from the visible session queue. Updating settings refreshes an idle session immediately, while a running or paused countdown keeps its original duration and elapsed-time anchor. New settings apply when the next session is created.

## TD-011 — Use one deployment-compatible glass treatment

**Status:** Accepted

Use ultra-thin material, a restrained navy tint, soft cyan edge reflection, and the same panel shape across the supported macOS 14+ range. Avoid compile-time dependencies on newer SwiftUI-only glass APIs so SwiftPM and Xcode 16 CI remain valid while preserving the intended layered-glass direction.

## TD-012 — Extend the existing snapshot for local tasks

**Status:** Accepted

Persist task records alongside settings and dive history in the existing local JSON snapshot. Decode a missing `tasks` key as an empty collection so snapshots created by earlier builds remain readable. Keep task lifecycle rules in `FocusDiveCore`; the SwiftUI view model exposes thin persistence-backed operations.

## TD-013 — Link sessions to tasks without removing free-form missions

**Status:** Accepted

Keep the existing mission field as the human-readable activity description and add an optional task identifier to completed dive records. Selecting an open task fills the mission title, but users can still refine the activity description before starting. This satisfies task/session traceability without forcing every focus dive into a task.

## TD-014 — Append events to date-based Obsidian Markdown logs

**Status:** Accepted

Use one Markdown file per date and event category inside the selected vault. Create the file once with a heading, then seek to the end and append immutable event blocks with unique event identifiers. This keeps logs readable in Obsidian, prevents silent replacement of older records, and avoids generating a large number of single-event files.

## Open decisions

- Persistence migration and recovery behavior
- App Sandbox and hardened runtime configuration
- Developer ID signing, notarization, and distribution channel
- Sound implementation and user-facing audio policy
- History editing, export, retention, and sync
