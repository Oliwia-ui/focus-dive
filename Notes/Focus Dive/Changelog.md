# Changelog

All notable project changes are recorded here.

## 2026-09-25 — Local task foundation

### Added

- Added a local task model with create, edit, complete, reopen, and delete operations.
- Persisted tasks in the existing JSON snapshot without changing the app architecture.
- Added backward-compatible decoding so existing user snapshots without tasks continue to load.
- Added view-model task operations so the upcoming task interface uses the same guarded persistence path as timer settings and history.

### Verified

- Added lifecycle, validation, persistence round-trip, and legacy-snapshot migration tests.

## 2026-09-25 — Editable session durations

### Changed

- Made every session queue row interactive with an accessible duration editor.
- Added bounded one-minute adjustments and useful presets for focus, short-break, and long-break sessions.
- Applied duration changes immediately while preserving an active countdown instead of resetting it.
- Refined dashboard panels with restrained native glass treatment on macOS 26 and a material fallback on macOS 14–15.

### Verified

- Added regression coverage for duration changes while idle and while running.
- `swift test` passes all 13 tests.

## 2026-09-25 — MVP documentation baseline

### Added

- Native SwiftUI dashboard with ocean depth, ascent progress, session queue, weekly profile, streak, energy, and discoveries
- Focus, short-break, and long-break sequencing with configurable durations
- Mission naming, dive log, compact timer, menu-bar controls, keyboard commands, and local notifications
- Local JSON persistence for settings and completed focus history
- Swift Testing coverage for timer, settings, session completion, and persistence
- XCTest UI smoke coverage for start, pause, and reset
- Swift Package and XcodeGen build paths
- README, engineering handoff, and Obsidian project vault

### Known limitations

- Sound controls are reserved and disabled.
- Distribution signing, notarization, packaging, and publishing are not automated.
- Persistence errors are not surfaced in the UI.
- UI tests require a generated Xcode project.
